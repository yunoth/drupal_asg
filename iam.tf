resource "aws_iam_role" "ec2instance_role" {
  name = "ec2instance_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

  tags = {
    Name = "ec2instance-role"
  }
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2_profile"
  role = aws_iam_role.ec2instance_role.name
}

resource "aws_iam_policy_attachment" "test-attach" {
  name       = "policy-attachment"
  roles      = [aws_iam_role.ec2instance_role.name]
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_policy_attachment" "cw-attach" {
name       = "policy-attachment"
roles      = [aws_iam_role.ec2instance_role.name]
policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentAdminPolicy"
}