# Autoscaling launch configuration

resource "aws_launch_configuration" "custom_launch_config_app_servers" {
  name            = "custom_launch_config_app_servers"
  image_id        = "${var.chatter_api_ami}"
  instance_type   = "t2.micro"
  security_groups = ["${var.intranet_sg}"]
  key_name        = var.key_pair_name
}

resource "aws_autoscaling_group" "app_servers_asg" {
  name                      = "app_servers_asg"
  max_size                  = 2
  min_size                  = 1
  health_check_grace_period = 100
  health_check_type         = "EC2"
  target_group_arns         = ["${aws_lb_target_group.app_elb_tg1.arn}"]
  desired_capacity          = 1
  force_delete              = true
  launch_configuration      = aws_launch_configuration.custom_launch_config_app_servers.name
  vpc_zone_identifier       = ["${var.private_subnet}", "${var.private_subnet_2}"]
  tag {
    key                 = "Name"
    value               = "App_Server"
    propagate_at_launch = true
  }
    depends_on = [
    aws_lb.application_lb,
  ]
}

# Autoscaling Configuration Policy

resource "aws_autoscaling_policy" "cpu_policy_app" {
  name                   = "cpu_policy_app"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 100
  autoscaling_group_name = aws_autoscaling_group.app_servers_asg.name
  policy_type            = "SimpleScaling"
}

# CloudWatch Monitoring

resource "aws_cloudwatch_metric_alarm" "cpu_alarm_app" {
  alarm_name          = "cpu_alarm_app"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "80"

  dimensions = {
    AutoScalingGroupName = "${aws_autoscaling_group.app_servers_asg.name}"
  }

  alarm_description = "This metric monitors ec2 cpu utilization to scale up by one instance"
  alarm_actions     = ["${aws_autoscaling_policy.cpu_policy_app.arn}"]
}

# Descaling Policy

resource "aws_autoscaling_policy" "cpu_policy_descaling_app" {
  name                   = "cpu_policy_descaling_app"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 60
  autoscaling_group_name = aws_autoscaling_group.app_servers_asg.name
  policy_type            = "SimpleScaling"
}

# Descaling Cloudwatch Alarm

resource "aws_cloudwatch_metric_alarm" "cpu_alarm_descaling_app" {
  alarm_name          = "cpu_alarm_descale_app"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "30"

  dimensions = {
    AutoScalingGroupName = "${aws_autoscaling_group.app_servers_asg.name}"
  }

  alarm_description = "This metric monitors ec2 cpu utilization to descale by one instance"
  alarm_actions     = ["${aws_autoscaling_policy.cpu_policy_descaling_app.arn}"]
}
