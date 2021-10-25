resource "aws_lb" "application_lb" {
  name               = "appelb"
  internal           = false
  load_balancer_type = "application"
  subnets            = ["${var.public_subnet}", "${var.public_subnet_2}"]
  security_groups    = ["${var.elb_sg}"]
}


resource "aws_lb_listener" "listen_port_8080" {
  load_balancer_arn = "${aws_lb.application_lb.arn}"
  port              = "8080"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.app_elb_tg1.arn}"
  }
}

resource "aws_lb_listener" "listen_port_80" {
  load_balancer_arn = "${aws_lb.application_lb.arn}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.app_elb_tg2.arn}"
  }
}

resource "aws_lb_target_group" "app_elb_tg1" {
  name     = "MyTargetGroup1"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = "${var.vpc_id}"
}

resource "aws_lb_target_group" "app_elb_tg2" {
  name     = "MyTargetGroup2"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "${var.vpc_id}"
}

# resource "aws_lb_cookie_stickiness_policy" "elb_ss_policy_2" {
#   name                     = "sspolicy2"
#   load_balancer            = "${aws_lb.application_lb.id}"
#   lb_port                  = 8080
#   cookie_expiration_period = 3600
# }
# resource "aws_lb_cookie_stickiness_policy" "elb_ss_policy_3" {
#   name                     = "sspolicy3"
#   load_balancer            = "${aws_lb.application_lb.id}"
#   lb_port                  = 80
#   cookie_expiration_period = 3600
# }
