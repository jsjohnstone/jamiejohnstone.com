# Application Name
variable "app" {
  type = string
  default = "jamiejohnstone.com"
}

# Application Region
variable "region" {
  type = string
  default = "eu-west-2"
}

# Application Index File
variable "app-indexfile" {
  type = string
  default = "index.html"
}

# Environment
variable "env-prefix" {
  type = string
  default = null
}

# Domains listed below will generate Route 53 entries (for FQDN and www.), add the name to SSL certs
# and add as an alias to CloudFront
variable "domains" {
    type = list(string)
    description = "List of domains to generate records for"
    default = [
      "jamiejohnstone.com",
      "jamesjohnstone.co",
      "mesj.co",
      "miej.co",
      "miej.co.nz",
      "miej.co.uk",
      "jamiejohnstone.co.uk",
      "jamiejohnstone.co.nz"
    ]
}