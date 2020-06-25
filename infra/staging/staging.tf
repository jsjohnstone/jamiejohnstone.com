# Terraform
terraform {
    backend "s3" {
        bucket = "jamiejohnstone-com-infra"
        key = "tf-jamiejohnstone-com-staging"
        region = "eu-west-2"
    }
}

# Using this module
module "main" {
    source = "github.com/jsjohnstone/infra-shared/webapp"

    app = "jamiejohnstone.com"
    region = "eu-west-2"
    app-indexfile = "index.html"
    env-prefix = "staging"
    domains = [ "jamiejohnstone.com" ]
}