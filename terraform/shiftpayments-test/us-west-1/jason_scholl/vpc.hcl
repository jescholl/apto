locals {
  global = read_terragrunt_config(find_in_parent_folders("global.hcl")).locals
  region = read_terragrunt_config(find_in_parent_folders("region.hcl")).locals

  vpc_name = "jason_scholl"
  vpc_cidr = local.global.vpc_cidrs[local.vpc_name]

  public_cidr  = cidrsubnet(local.vpc_cidr, 2, 0)
  private_cidr = cidrsubnet(local.vpc_cidr, 1, 1)

  private_subnets = cidrsubnets(local.private_cidr, 2, [for az in range(1, length(local.region.availability_zones)): 2]...)
  public_subnets = cidrsubnets(local.public_cidr, 2, [for az in range(1, length(local.region.availability_zones)): 2]...)
}
