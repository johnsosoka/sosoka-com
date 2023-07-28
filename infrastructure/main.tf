provider "aws" {
  region = "us-west-2"
}
//TODO remove
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



// access shared jscom resources.
data "terraform_remote_state" "jscom_common_data" {
  backend = "s3"
  config = {
    bucket = "jscom-tf-backend"
    key = "project/jscom-core-infra/state/terraform.tfstate"
    region = "us-west-2"
  }
}

// Defining some values that will be utilized throughout.
locals {
  project_name = "sosoka-com"
  deployer_user_name = "scom-github-deployer-user"
  root_zone_id = data.terraform_remote_state.jscom_common_data.outputs.root_sosokacom_zone_id
  acm_cert_id = data.terraform_remote_state.jscom_common_data.outputs.scom_acm_cert
}
