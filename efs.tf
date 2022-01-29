resource "aws_efs_file_system" "efs" {
  creation_token = "efs"
  performance_mode = "generalPurpose"
  throughput_mode = "bursting"
  encrypted = "true"
  tags = {
    Name = "EFS"
  }
}

resource "aws_efs_mount_target" "efs-mt" {
  count = length([module.vpc.private_subnets[0],module.vpc.private_subnets[1]])
  file_system_id  = aws_efs_file_system.efs.id
  subnet_id = module.vpc.private_subnets[count.index]
  security_groups = [aws_security_group.instance-sg.id]
}

output "efs_id" {
  value = aws_efs_mount_target.efs-mt[0].dns_name
}