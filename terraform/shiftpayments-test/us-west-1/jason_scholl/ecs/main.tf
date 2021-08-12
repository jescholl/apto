module "ecs" {
  source = "terraform-aws-modules/ecs/aws"
  version = "3.3.0"

  name = var.name
}

#module "ec2_profile" {
#  source = "terraform-aws-modules/ecs/aws//modules/ecs-instance-profile"
#
#  name = var.name
#}

data "aws_ami" "this" {
  most_recent = true

  owners = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn-ami-*-amazon-ecs-optimized"]
  }
}

module "asg" {
  source  = "terraform-aws-modules/autoscaling/aws"
  version = "~> 4.0"

  name = var.name

  lc_name   = var.name
  use_lc    = true
  create_lc = true

  image_id                  = data.aws_ami.this.id
  instance_type             = var.instance_type
  security_groups           = [] #aws_security_group.this
  #iam_instance_profile_name = module.ec2_profile.iam_instance_profile_id
  user_data                 = data.template_file.user_data.rendered

  # Auto scaling group
  vpc_zone_identifier       = var.subnet_ids
  health_check_type         = "EC2"
  min_size                  = var.min_size
  max_size                  = var.max_size
  #desired_capacity          = var.desired_capacity
  #wait_for_capacity_timeout = var.wait_for_capacity_timeout
}

#aws_security_group "this" {
#  name = var.name
#  description = "ECS ASG security group"
#  ingress = var.ingress_rules
#}

data "template_file" "user_data" {
  template = file("user-data.sh")

  vars = {
    cluster_name = var.name
  }
}

variable "min_size" {
  type = number
  default = 0
}

variable "max_size" {
  type = number
  default = 1
}

variable "instance_type" {
  type = string
  default = "t2.micro"
}

variable "name" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}
