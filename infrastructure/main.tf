provider "aws" {
  region = "us-west-2"
}

// Seems acm cert for root domain must be provisioned in us-east-1?
provider "aws" {
  alias  = "east"
  region = "us-east-1"
}

// Terraform state managed remotely.
terraform {
  backend "s3" {
    // WARNING  -- Couldn't read from variables.tf in this block!!
    bucket         = "jscom-tf-backend"
    key            = "project/sosoka-com/state/terraform.tfstate"
    region         = "us-west-2"
    dynamodb_table = "terraform-state"
  }
}

// Defining some values that will be utilized throughout.
locals {

  // johnsosoka.com
  root_domain_name = "${var.domain_name}.${var.domain}"
  // www.johnsosoka.com
  www_domain_name = "www.${local.root_domain_name}"

  project_name = "sosoka-com"
}

// access shared jscom resources..just incase :)
data "terraform_remote_state" "jscom_common_data" {
  backend = "s3"
  config = {
    bucket = "jscom-tf-backend"
    key = "project/jscom-core-infra/state/terraform.tfstate"
    region = "us-west-2"
  }
}