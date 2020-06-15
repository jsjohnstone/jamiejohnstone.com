# Terraform
terraform {
  backend "s3" {
    bucket = "jamiejohnstone-com-infra"
    key    = "tf-state"
    region = "eu-west-2"
  }
}

# Providers
provider "aws" {
  region  = "eu-west-2"
}

# Locals
locals {
  s3_origin_id = "S3-jamiejohnstone.com"
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
    bucket = "${aws_s3_bucket.s3-jamiejohnstone-com.id}"
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

# CloudFront Distribution
resource "aws_cloudfront_distribution" "cf-jamiejohnstone-com" {
  origin {
    domain_name = "${aws_s3_bucket.s3-jamiejohnstone-com.bucket_regional_domain_name}"
    origin_id   = "${local.s3_origin_id}"
  }

    enabled             = true
    is_ipv6_enabled     = true
    comment             = "jamiejohnstone.com"
    default_root_object = "index.html"

    aliases = [ "www.jamesjohnstone.co",
                "jamiejohnstone.com",
                "www.mesj.co",
                "www.jamiejohnstone.com",
                "jamesjohnstone.co",
                "miej.co",
                "mesj.co",
                "www.miej.co"
            ]

  default_cache_behavior {
    target_origin_id = "${local.s3_origin_id}"
    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 86400
    max_ttl                = 31536000
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]

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
    acm_certificate_arn         = "arn:aws:acm:us-east-1:913976950049:certificate/b72c31a7-21e1-4a16-85d5-17b068ca4bd9"
    ssl_support_method          = "sni-only"
    minimum_protocol_version    = "TLSv1.1_2016"
  }
}

# Route 53 Record pointing domain and www. at CloudFront
resource "aws_route53_record" "jamiejohnstone-com-A" {
    zone_id = "Z4NVW4V8EWN1T"
    name    = "jamiejohnstone.com"
    type    = "A"

    alias {
        name    = "${aws_cloudfront_distribution.cf-jamiejohnstone-com.domain_name}"
        zone_id = "${aws_cloudfront_distribution.cf-jamiejohnstone-com.hosted_zone_id}"
        evaluate_target_health = false
    }
}

resource "aws_route53_record" "www-jamiejohnstone-com-A" {
    zone_id = "Z4NVW4V8EWN1T"
    name    = "www.jamiejohnstone.com"
    type    = "A"

    alias {
        name    = "${aws_cloudfront_distribution.cf-jamiejohnstone-com.domain_name}"
        zone_id = "${aws_cloudfront_distribution.cf-jamiejohnstone-com.hosted_zone_id}"
        evaluate_target_health = false
    }
}
