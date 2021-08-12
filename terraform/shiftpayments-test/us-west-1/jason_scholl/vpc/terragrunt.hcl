terraform {
  source = "git@github.com:terraform-aws-modules/terraform-aws-vpc//.?ref=v3.3.0"
}

locals {
  region = read_terragrunt_config(find_in_parent_folders("region.hcl")).locals
  vpc = read_terragrunt_config(find_in_parent_folders("vpc.hcl")).locals
}

inputs = {
  enable_nat_gateway = true
  azs = local.region.availability_zones
  cidr = local.vpc.vpc_cidr
}

include {
  path = find_in_parent_folders("base.hcl")
}
