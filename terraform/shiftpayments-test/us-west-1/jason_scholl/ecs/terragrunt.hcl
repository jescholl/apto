#terraform {
#  source = "git@github.com:terraform-aws-modules/terraform-aws-ecs//.?ref=v3.3.0"
#}

dependency "vpc" {
  config_path = "../vpc"
}

inputs = {
  name = "jason_scholl"
  max_size = 2

  subnet_ids = dependency.vpc.outputs.private_subnets

  #ingress_rules = [
  #  {
  #    description = "Allow HTTP in"
  #    from_port = 80
  #    to_port = 80
  #    protocol = "tcp"
  #    cidr_blocks = ["0.0.0.0/0"]
  #  }
  #]
}

include {
  path = find_in_parent_folders("base.hcl")
}
