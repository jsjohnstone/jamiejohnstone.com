# jamiejohnstone.com :wave:
Personal Website, hosted on AWS, built using Terraform and Github actions
This is really the simplest website ever, and more of a learning playground.

## Infrastructure Diagram
![Infra Diagram](docs/infradiagram.png)

## Code Deployment
Pushing to the [src/](src/) directory will trigger a [Github Action](.github/workflows/main.yml) that:
* checks out the current codebase
* timestamps the index.html file
* uploads the contents of src/ to S3
* triggers a cache invalidation in CloudFront

For more information on the upload script, check out [jsjohnstone/s3-site-deploy](https://github.com/jsjohnstone/s3-site-deploy/).

## Infrastructure Deployment
The [infra/](infra/) folder contains terraform scripts to deploy (most) of the infrastructure for this site:
* CloudFront Distribution for CDN
* ACM Certificates for SSL certificate management
* Route 53 Zones and Records for DNS Management
* ...and S3 Buckets for code storage

## Files
    .
    ├── .github/workflows/       # CI/CD Workflows
    ├── docs/                    # Additional files used in the project
    ├── infra/                   # Infrastructure Code
    |   ├── prod/                # Production Environment
    |   ├── staging/             # Staging Environment 
    |   └── resources/           # Terraform Modules for generic web app
    ├── src/                     # Website source
    └── README.md
