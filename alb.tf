resource "aws_lb" "ingress" {
  name               = "alb-${module.env.envName}"
  internal           = false
  load_balancer_type = "application"
  security_groups = [module.security.alb_sg_id]
  subnets            = aws_subnet.public.*.id
}

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.ingress.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ingress_to_http.arn
  }
}

resource "aws_lb_target_group" "ingress_to_http" {
  name     = "http-${module.env.envName}"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id
  target_type = "ip"

  health_check {
    path = "/"
    matcher = 200
  }
}
