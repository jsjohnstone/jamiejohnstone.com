# Terraform
terraform {
    backend "s3" {
        bucket = "jamiejohnstone-com-infra"
        key = "tf-jamiejohnstone-com"
        region = "eu-west-2"
    }
}

# Using this module
module "webapp" {
    source = "github.com/jsjohnstone/infra-shared/modules/webapp"

    app = "jamiejohnstone.com"
    region = "eu-west-2"
    app-indexfile = "index.html"
    domains = [ 
        "jamiejohnstone.com",
        "jamesjohnstone.co",
        "jamiejohnstone.co.uk",
        "mesj.co",
        "miej.co",
        "miej.co.uk",
        "miej.co.nz"
     ]
}