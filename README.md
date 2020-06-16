# jamiejohnstone.com :wave:
Personal Website Repo hosted at www.jamiejohnstone.com

![Deploy](https://github.com/jsjohnstone/jamiejohnstone.com/workflows/Deploy/badge.svg?branch=master)

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
    ├── infra/                   # Infrastructure Code
    ├── src/                     # Website source
    ├── docs/                    # Additional files used in the project
    └── README.md
