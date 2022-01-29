resource "aws_autoscaling_policy" "add" {
  name                   = "addnode"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = module.asg.autoscaling_group_name
}

resource "aws_cloudwatch_metric_alarm" "add" {
  alarm_name          = "highmemusage"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "mem_used_percent"
  namespace           = "CWAgent"
  period              = "30"
  statistic           = "Average"
  threshold           = "70"

  dimensions = {
    AutoScalingGroupName = module.asg.autoscaling_group_name
  }

  alarm_description = "This metric monitors ec2 mem utilization"
  alarm_actions     = [aws_autoscaling_policy.add.arn]
}

resource "aws_autoscaling_policy" "remove" {
  name                   = "removenode"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = module.asg.autoscaling_group_name
}

resource "aws_cloudwatch_metric_alarm" "remove" {
  alarm_name          = "lowmemusage"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "mem_used_percent"
  namespace           = "CWAgent"
  period              = "30"
  statistic           = "Average"
  threshold           = "70"

  dimensions = {
    AutoScalingGroupName = module.asg.autoscaling_group_name
  }

  alarm_description = "This metric monitors ec2 mem utilization"
  alarm_actions     = [aws_autoscaling_policy.remove.arn]
}