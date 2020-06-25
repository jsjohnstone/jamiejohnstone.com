# jamiejohnstone.com Infrastructure Code
Code to generate the infrastructure required for deployment of this website to AWS

## Overview
This project consists of three folders: resources/, staging/ and prod/.

## staging/ and prod/
These two folders contain terraform scripts that consume a [webapp module](https://www.github.com/jsjohnstone/infra-shared/webapp), but with specific configuration to deploy a staging or production environment.

The staging/ code will deploy infrastructure for *staging.jamiejohnstone.com* whilst the production/ code will deploy the same with a more complex set of domains (I'm a domain hoarder).

## Deploying Infrastructure
To deploy infrastructure, simply jump into one of the environment folders and run `terraform plan` to see what will be created. You can then run `terraform apply` to deploy everything.

This will not deploy the code - this is managed separately by Github Actions.

## Creating a new environment
You can get started by using one of existing environments as a template - more info to come...

## To Do
To Do items are tracked in Github Issues
