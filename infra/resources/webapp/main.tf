# Providers
provider "aws" {
    region = var.region
    alias = "main"
}

provider "aws" {
    region = "us-east-1"
    alias = "acm"
}

# Local Variables
locals {
    env-webprefix = var.env-prefix == null ? "" : ("${var.env-prefix}.")
    app-ref = var.env-prefix == null ? "webapp-${var.app}" : "webapp-${var.app}-${var.env-prefix}"
}

# S3 Bucket
resource "aws_s3_bucket" "webapp-s3-html" {
    provider = aws.main
    bucket = local.app-ref
    acl = "public-read"
    website {
        index_document = var.app-indexfile
    }
}

resource "aws_s3_bucket_policy" "webapp-s3p-html" {
    provider = aws.main
    bucket = aws_s3_bucket.webapp-s3-html.id
    policy = <<POLICY
{
        "Version": "2012-10-17",
        "Statement": [
            {
                "Sid": "PublicReadGetObject",
                "Effect": "Allow",
                "Principal": "*",
                "Action": "s3:GetObject",
                "Resource": "${aws_s3_bucket.webapp-s3-html.arn}/*"
            }
        ]
    } 
POLICY
}

# CloudFront SSL Certificate
resource "aws_acm_certificate" "webapp-acm-sslcert" {
    provider = aws.acm
    domain_name = "${local.env-webprefix}${var.domains[0]}"
    validation_method = "DNS"

    subject_alternative_names = concat(formatlist("${local.env-webprefix}%s",var.domains), formatlist("www.${local.env-webprefix}%s", var.domains))

    tags = {
        Name = local.app-ref
        Environment = var.env-prefix
    }
    lifecycle {
       ignore_changes = [ subject_alternative_names, domain_validation_options ]
       create_before_destroy = true
    }
}

# CloudFront Distribution
resource "aws_cloudfront_distribution" "webapp-cfd" {
    provider = aws.main
    origin {
        domain_name = aws_s3_bucket.webapp-s3-html.bucket_regional_domain_name
        origin_id = local.app-ref
    }

    enabled = true
    is_ipv6_enabled = true
    comment = local.app-ref
    default_root_object = "index.html"

    aliases = concat(formatlist("${local.env-webprefix}%s",var.domains), formatlist("www.${local.env-webprefix}%s", var.domains))

    default_cache_behavior {
        target_origin_id = local.app-ref
        viewer_protocol_policy = "redirect-to-https"
        min_ttl = 0
        default_ttl = 86400
        max_ttl = 31536000
        allowed_methods = ["GET", "HEAD"]
        cached_methods = ["GET", "HEAD"]

        forwarded_values {
            query_string = false
            cookies {
                forward = "none"
            }
        }
    }

    restrictions {
        geo_restriction {
            restriction_type = "none"
        }
    }

    price_class = "PriceClass_All"

    tags = {
        Name = local.app-ref
        Environment = var.env-prefix
    }

    viewer_certificate {
        acm_certificate_arn = aws_acm_certificate.webapp-acm-sslcert.arn
        ssl_support_method = "sni-only"
        minimum_protocol_version = "TLSv1.1_2016"
    }
}

# Route 53
# Define Zones
resource "aws_route53_zone" "webapp-r53-zones" {
    provider = aws.main
    for_each = toset(var.domains)

    name = each.key
    comment = local.app-ref
}

# Route 53 Record pointing domain and www. at CloudFront
resource "aws_route53_record" "webapp-r53-A" {
    provider = aws.main
    for_each = toset(var.domains)
    zone_id = aws_route53_zone.webapp-r53-zones[each.key].zone_id
    name = "${local.env-webprefix}${each.key}"
    type = "A"

    alias {
        name = aws_cloudfront_distribution.webapp-cfd.domain_name
        zone_id = aws_cloudfront_distribution.webapp-cfd.hosted_zone_id
        evaluate_target_health = false
    }
}

resource "aws_route53_record" "webapp-r53-A-WWW" {
    provider = aws.main
    for_each = toset(var.domains)
    zone_id = aws_route53_zone.webapp-r53-zones[each.key].zone_id
    name = "www.${local.env-webprefix}${each.key}"
    type = "A"

    alias {
        name = aws_cloudfront_distribution.webapp-cfd.domain_name
        zone_id = aws_cloudfront_distribution.webapp-cfd.hosted_zone_id
        evaluate_target_health = false
    }
}
