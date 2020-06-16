variable "s3_origin_id" {
  type = string
  default = "S3-jamiejohnstone.com"
}

variable "domains" {
    type    = set(string)
    description = "List of domains to generate records for"
    default = [
    "jamesjohnstone.co",
    "www.jamesjohnstone.co",
    "jamiejohnstone.com",
    "www.jamiejohnstone.com",
    "mesj.co",
    "www.mesj.co",
    "miej.co",
    "www.miej.co"
    ]
}