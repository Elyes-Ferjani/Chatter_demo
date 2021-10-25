# Autoscaling launch configuration

resource "aws_launch_configuration" "custom_launch_config_web_servers"{
    name = "custom_launch_config_web_servers"
    image_id = "${var.chatter_ui_ami}"
    instance_type = "t2.micro"
    security_groups = ["${var.internet_fc_sg}"]
    key_name = "${var.key_pair_name}"
    user_data = <<-EOF
    #!/bin/bash
    sudo su
    echo $'export const dns_name = "${aws_lb.application_lb.dns_name}"' >> /home/ec2-user/chatterUI/src/utils/endpoint.js
    cd /home/ec2-user/chatterUI/
    npm run build
    cd build/
    cd -r . /usr/share/nginx/html/
    systemctl restart nginx
    EOF
}

resource "aws_autoscaling_group" "web_servers_asg" {
  name                      = "web_servers_asg"
  max_size                  = 2
  min_size                  = 1
  health_check_grace_period = 100
  health_check_type         = "EC2"
  target_group_arns         = ["${aws_lb_target_group.app_elb_tg2.arn}"]
  desired_capacity          = 1
  force_delete              = true
  launch_configuration      = "${aws_launch_configuration.custom_launch_config_web_servers.name}"
  vpc_zone_identifier       = ["${var.public_subnet}", "${var.public_subnet_2}"]

  tag {
    key                 = "Name"
    value               = "Web_Server"
    propagate_at_launch = true
  }
  depends_on = [
    aws_lb.application_lb,
  ]
}

# Autoscaling Configuration Policy

resource "aws_autoscaling_policy" "cpu_policy" {
  name                   = "cpu_policy"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 100
  autoscaling_group_name = "${aws_autoscaling_group.web_servers_asg.name}"
  policy_type = "SimpleScaling"
}

# CloudWatch Monitoring

resource "aws_cloudwatch_metric_alarm" "cpu_alarm" {
  alarm_name          = "cpu_alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "80"

  dimensions = {
    AutoScalingGroupName = "${aws_autoscaling_group.web_servers_asg.name}"
  }

  alarm_description = "This metric monitors ec2 cpu utilization to scale up by one instance"
  alarm_actions     = ["${aws_autoscaling_policy.cpu_policy.arn}"]
}

# Descaling Policy

resource "aws_autoscaling_policy" "cpu_policy_descaling" {
  name                   = "cpu_policy_descaling"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 60
  autoscaling_group_name = "${aws_autoscaling_group.web_servers_asg.name}"
  policy_type = "SimpleScaling"
}

# Descaling Cloudwatch Alarm

resource "aws_cloudwatch_metric_alarm" "cpu_alarm_descaling" {
  alarm_name          = "cpu_alarm_descaling"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "30"

  dimensions = {
    AutoScalingGroupName = "${aws_autoscaling_group.web_servers_asg.name}"
  }

  alarm_description = "This metric monitors ec2 cpu utilization to descale by one instance"
  alarm_actions     = ["${aws_autoscaling_policy.cpu_policy_descaling.arn}"]
}
