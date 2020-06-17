# Terraform
terraform {
    backend "s3" {
        bucket = "jamiejohnstone-com-infra"
        key = "tf-jamiejohnstone-com"
        region = "eu-west-2"
    }
}

# Using this module
module "main" {
    source = "../resources/webapp"

    app = "jamiejohnstone.com"
    region = "eu-west-2"
    app-indexfile = "index.html"
    domains = [ 
        "jamiejohnstone.com",
        "jamesjohnstone.co",
        "mesj.co",
        "miej.co",
        "miej.co.uk"
     ]
}