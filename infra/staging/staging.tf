# Terraform
terraform {
    backend "s3" {
        bucket = "jamiejohnstone-com-infra"
        key = "tf-jamiejohnstone-com-staging"
        region = "eu-west-2"
    }
}

# Using this module
module "webapp" {
    source = "github.com/jsjohnstone/s3-webapp-tf"

    app = "jamiejohnstone.com"
    region = "eu-west-2"
    app-indexfile = "index.html"
    env-prefix = "staging"
    domains = [ "jamiejohnstone.com" ]
}
