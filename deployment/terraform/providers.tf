

provider "aws" {
  region     = "us-west-2"
  access_key = var.access_key
  secret_key = var.secret_key
  version    = ">= 2.38.0"
}


data "aws_region" "current" {}

data "aws_availability_zones" "available" {}

provider "http" {}
