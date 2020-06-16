# Origin Name for S3 in Cloudfront
variable "s3_origin_id" {
  type = string
  default = "S3-jamiejohnstone.com"
}

# Domains listed below will generate Route 53 entries (for FQDN and www.), add the name to SSL certs
# and add as an alias to CloudFront
variable "domains" {
    type = set(string)
    description = "List of domains to generate records for"
    default = [
    "jamesjohnstone.co",
    "jamiejohnstone.com",
    "mesj.co",
    "miej.co"
    ]
}