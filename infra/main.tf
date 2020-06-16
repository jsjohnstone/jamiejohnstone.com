# Terraform
terraform {
    backend "s3" {
        bucket = "jamiejohnstone-com-infra"
        key = "tf-state"
        region = "eu-west-2"
    }
}

# Providers
# Default to London, N Virginia included for ACM
provider "aws" {
    region = "eu-west-2"
}

provider "aws" {
    region = "us-east-1"
    alias = "us-east-1"
}

# S3 Bucket
resource "aws_s3_bucket" "s3-jamiejohnstone-com" {
    bucket = "jamiejohnstone.com"
    acl = "public-read"
    website {
        index_document = "index.html"
    }
}

resource "aws_s3_bucket_policy" "s3-jamiejohnstone-com" {
    bucket = aws_s3_bucket.s3-jamiejohnstone-com.id
    policy = <<POLICY
    {
        "Version": "2012-10-17",
        "Statement": [
            {
                "Sid": "PublicReadGetObject",
                "Effect": "Allow",
                "Principal": "*",
                "Action": "s3:GetObject",
                "Resource": "arn:aws:s3:::jamiejohnstone.com/*"
            }
        ]
    } 
    POLICY
}

# CloudFront SSL Certificate
resource "aws_acm_certificate" "acm-jamiejohnstone-com" {
    provider = aws.us-east-1
    domain_name = "jamiejohnstone.com"
    validation_method = "DNS"

    subject_alternative_names = var.domains

    tags = {
        Environment = "Production"
    }
    lifecycle {
       ignore_changes = [ subject_alternative_names, domain_validation_options ]
       create_before_destroy = true
    }
}

# CloudFront Distribution
resource "aws_cloudfront_distribution" "cf-jamiejohnstone-com" {
    origin {
        domain_name = aws_s3_bucket.s3-jamiejohnstone-com.bucket_regional_domain_name
        origin_id = var.s3_origin_id
    }

    enabled = true
    is_ipv6_enabled = true
    comment = "jamiejohnstone.com"
    default_root_object = "index.html"

    aliases = setunion(var.domains, formatlist("www.%s", var.domains))

    default_cache_behavior {
        target_origin_id = var.s3_origin_id
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
        Environment = "production"
    }

    viewer_certificate {
        acm_certificate_arn = aws_acm_certificate.acm-jamiejohnstone-com.arn
        ssl_support_method = "sni-only"
        minimum_protocol_version = "TLSv1.1_2016"
    }
}

# Route 53
# Define Zones
resource "aws_route53_zone" "r53-zones" {
    for_each = var.domains
    name = each.key
}

# Route 53 Record pointing domain and www. at CloudFront
resource "aws_route53_record" "r53-A-FQDN" {
    for_each = var.domains
    zone_id = aws_route53_zone.r53-zones[each.key].zone_id
    name = each.key
    type = "A"

    alias {
        name = aws_cloudfront_distribution.cf-jamiejohnstone-com.domain_name
        zone_id = aws_cloudfront_distribution.cf-jamiejohnstone-com.hosted_zone_id
        evaluate_target_health = false
    }
}

resource "aws_route53_record" "r53-A-WWW" {
    for_each = var.domains
    zone_id = aws_route53_zone.r53-zones[each.key].zone_id
    name = "www.${each.key}"
    type = "A"

    alias {
        name = aws_cloudfront_distribution.cf-jamiejohnstone-com.domain_name
        zone_id = aws_cloudfront_distribution.cf-jamiejohnstone-com.hosted_zone_id
        evaluate_target_health = false
    }
}
