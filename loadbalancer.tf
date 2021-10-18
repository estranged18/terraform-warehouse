# __________________________________LOAD BALANCER__________________________________
resource "aws_lb" "wrs_lb" {
  name               = "tfwrslb"
  load_balancer_type = "application"
  security_groups    = [aws_security_group.wrs_sg.id]
  subnets            = [aws_subnet.wrs_public_subnet.id, aws_subnet.wrs_private_subnet.id]
  
  tags = {
    Name        = "terraform-alb"
    Environment = "${var.environment_tag}"
  }
}

# _____________________________________LISTENER_____________________________________
resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.wrs_lb.arn 
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
}

# ____________________________________TARGET GROUP____________________________________
resource "aws_lb_target_group" "tg" {
  name                 = "terraform-wrs-tg"
  port                 = "8080"
  protocol             = "HTTP"
  vpc_id               = "${aws_vpc.vpc.id}"
  deregistration_delay = "30"
  stickiness {
    type            = "lb_cookie"
    cookie_duration = "86400"
  }
  health_check {
    timeout            = "4" # deve essere minore di 5
    path               = "/"
    protocol           = "HTTP"
    healthy_threshold   = "5"
    unhealthy_threshold = "5"
    interval           = "15"
    matcher            = "200"
  }
  # il target group viene creato dopo il load balancer
  depends_on = [aws_lb.wrs_lb]
}

# associo il target group all'istanza EC2
resource "aws_alb_target_group_attachment" "tga" {
  target_group_arn = aws_lb_target_group.tg.arn
  target_id        = aws_instance.terraform_wrs_dev.id
  port             = 8080

  # a questo punto il load balancer e' pronto per gestire il traffico
  # sulla mia applicazione
}
