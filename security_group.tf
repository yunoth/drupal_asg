resource "aws_security_group" "alb-sg" {
  name        = "alb-sg"
  description = "Allow TLS inbound traffic"
  vpc_id      = module.vpc.vpc_id
  tags = {
    Name = "alb-sg"
  }
}
resource "aws_security_group" "instance-sg" {
  name        = "instance-sg"
  description = "Allow TLS inbound traffic"
  vpc_id      = module.vpc.vpc_id

  tags = {
    Name = "instance-sg"
  }
}
resource "aws_security_group" "db-sg" {
  name        = "db-sg"
  description = "Allow TLS inbound traffic"
  vpc_id      = module.vpc.vpc_id

  tags = {
    Name = "db-sg"
  }
}
resource "aws_security_group_rule" "alb-rule" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.alb-sg.id
}
resource "aws_security_group_rule" "instance-rule" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  source_security_group_id = aws_security_group.alb-sg.id
  security_group_id = aws_security_group.instance-sg.id
}
resource "aws_security_group_rule" "efs-rule" {
  type              = "ingress"
  from_port         = 2049
  to_port           = 2049
  protocol          = "tcp"
  security_group_id = aws_security_group.instance-sg.id
  self = true
}
resource "aws_security_group_rule" "db-rule" {
  type              = "ingress"
  from_port         = 3306
  to_port           = 3306
  protocol          = "tcp"
  source_security_group_id = aws_security_group.instance-sg.id
  security_group_id = aws_security_group.db-sg.id
}
resource "aws_security_group_rule" "instance-rule_out" {
  type              = "egress"
  from_port         = 0
  to_port           = 65535
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.instance-sg.id
}
resource "aws_security_group_rule" "alb-rule_out" {
  type              = "egress"
  from_port         = 0
  to_port           = 65535
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.alb-sg.id
}