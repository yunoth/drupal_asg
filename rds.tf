module "drupal-db" {
  source = "terraform-aws-modules/rds/aws"

  identifier = "drupal-db"

  create_db_option_group    = false
  create_db_parameter_group = false

  # All available versions: http://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_MySQL.html#MySQL.Concepts.VersionMgmt
  engine               = "mysql"
  engine_version       = "8.0.20"
  family               = "mysql8.0" # DB parameter group
  major_engine_version = "8.0"      # DB option group
  instance_class       = "db.t3.micro"
  subnet_ids             = [module.vpc.private_subnets[2],module.vpc.private_subnets[3]]
  vpc_security_group_ids = [aws_security_group.db-sg.id]
  allocated_storage = 20

  name                   = "completeMysql"
  username               = "complete_mysql"
  create_random_password = true
  random_password_length = 12
  port                   = 3306

  maintenance_window = "Mon:00:00-Mon:03:00"
  backup_window      = "03:00-06:00"

  backup_retention_period = 0

  tags = {
    "Name" = "drupal-db"
  }
}
