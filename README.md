# jubilant-octo-tribble

Just a showcase of my learnings about Terraform and Google Cloud Platform.

## How to use this repository

0/ Install Terraform : https://learn.hashicorp.com/tutorials/terraform/install-cli

1/ Create a Google Cloud account : https://cloud.google.com/

2/ Create a project, and a GCP service account key : https://learn.hashicorp.com/tutorials/terraform/google-cloud-platform-build?in=terraform/gcp-get-started

3/ Clone this repository

4/ In the `terraform` directory, create a `terraform.tfvars` file using the
`terraform.tfvars.example` file, and add a credentials JSON file (retrieved
from Google Cloud)

5/ In the `terraform` directory, run `terraform init -upgrage`, then `terraform
apply`

