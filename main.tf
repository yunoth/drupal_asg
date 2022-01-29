provider "aws" {
  access_key = var.access_key
  secret_key = var.secret_key
  region     = var.region
}


module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "demo-vpc"
  cidr = "10.0.0.0/16"

  azs             = var.az
  private_subnets = var.private_subnets
  public_subnets  =  var.public_subnets

  enable_nat_gateway = true
  #enable_vpn_gateway = true
  enable_dns_hostnames = true

  tags = {
    Terraform = "true"
    Environment = "dev"
  }
}


data "http" "myip" {
  url = "http://ifconfig.me"
}

resource "tls_private_key" "example" {
  algorithm = "RSA"
}

resource "aws_key_pair" "generated_key" {
  key_name   = "pemkey"
  public_key = "${tls_private_key.example.public_key_openssh}"
}

resource "local_file" "public_key_openssh" {
  content         = tls_private_key.example.private_key_pem
  filename        = "/tmp/demo.pem"
  file_permission = "0400"
}

data "template_file" "user_data" {
  count    = 1
  template = "${file("${path.module}/userdata.tpl")}"
  vars = {
    efs_target = aws_efs_mount_target.efs-mt[0].dns_name
  }
}

module "asg" {
  source  = "terraform-aws-modules/autoscaling/aws"
  version = "~> 4.0"
  name = "drupal-asg"
  min_size                  = 0
  max_size                  = 1
  desired_capacity          = 1
  wait_for_capacity_timeout = 0
  health_check_type         = "EC2"
  vpc_zone_identifier       = [module.vpc.private_subnets[0],module.vpc.private_subnets[1]]
  target_group_arns         = module.alb.target_group_arns
  instance_refresh = {
    strategy = "Rolling"
    preferences = {
      min_healthy_percentage = 50
    }
    triggers = ["tag"]
  }
  # Launch template
  lc_name                = "drupal-asg-1"
  description            = "Launch config example"
  #update_default_version = true
  use_lc    = true
  create_lc = true
  image_id          = "ami-0ed9277fb7eb570c9"
  instance_type     = "t3.micro"
  security_groups = [aws_security_group.instance-sg.id,]
  user_data       =  data.template_file.user_data.0.rendered
  ebs_optimized     = true
  enable_monitoring = true
  iam_instance_profile_name = aws_iam_instance_profile.ec2_profile.name
  tags = [
    {
      key                 = "Environment"
      value               = "dev"
      propagate_at_launch = true
    },
    {
      key                 = "Project"
      value               = "Demo"
      propagate_at_launch = true
    },
  ]
}


module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 6.0"
  name = "demo-alb"
  load_balancer_type = "application"
  vpc_id             = module.vpc.vpc_id
  subnets            = module.vpc.public_subnets
  security_groups    = [aws_security_group.alb-sg.id]

  target_groups = [
    {
      name             = "demo-app"
      backend_protocol = "HTTP"
      backend_port     = 80
      target_type      = "instance"
    }
  ]
  http_tcp_listeners = [
    {
      port               = 80
      protocol           = "HTTP"
      #certificate_arn    = "arn:aws:acm:us-east-1:333113274611:certificate/1e178862-7dd8-4cf0-b7b6-42da85643b14"
      target_group_index = 0
    }
  ]
  tags = {
    Environment = "Test"
  }
}