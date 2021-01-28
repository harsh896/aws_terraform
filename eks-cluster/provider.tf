provider "aws" {
  profile = var.aws_profile
  region = var.aws_region
}

#---------------------------------Data Resources-----------------------------------


data "aws_region" "current" {}                 # data.aws_region.current.name
data "aws_caller_identity" "current" {}        # data.aws_caller_identity.current.account_id
data "aws_availability_zones" "available" {    # data.aws_availability_zones.available.names[0-*]
  state = "available"
}

