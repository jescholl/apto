locals {
  global = try(read_terragrunt_config(find_in_parent_folders("global.hcl")).locals, {})
  account = try(read_terragrunt_config(find_in_parent_folders("account.hcl")).locals, {})
  region = try(read_terragrunt_config(find_in_parent_folders("region.hcl")).locals, {})
  vpc = try(read_terragrunt_config(find_in_parent_folders("vpc.hcl")).locals, {})

  defaults = {
    terraform_version = ">= 1.0.4"
    terragrunt_version = ">= 0.31.3"
    aws_region = "us-west-1"
  }

  merged = merge(
    local.global,
    local.account,
    local.vpc,
    local.region,
    local.defaults
  )
}

remote_state {
  backend = "s3"

  generate = {
    path = "terragrunt_state.tf"
    if_exists = "overwrite"
  }

  config = {
    bucket = local.merged.statefile_bucket
    key    = "${path_relative_to_include()}/terraform.state"
    region = local.merged.aws_region
    encrypt = true
    #dynamodb_table = "tf_lock_table"
  }
}

terraform_version_constraint = local.merged.terraform_version
terragrunt_version_constraint = local.merged.terragrunt_version


generate "provider" {
  path      = "terragrunt_provider.tf"
  if_exists = "overwrite"
  contents = <<EOF
provider "aws" {
  region              = "${local.merged.aws_region}"
  allowed_account_ids = ["${local.merged.account_id}"]
  default_tags {
    tags = {
      candidate = "Jason Scholl"
      created_by = "Terraform"
      terragrunt_repo_path = "https://github.com/jescholl/apto/${path_relative_to_include()}"
    }
  }
}
EOF
}

inputs = local.merged
