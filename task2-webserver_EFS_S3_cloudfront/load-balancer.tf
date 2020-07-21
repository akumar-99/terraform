# Load balancer for the instances
resource "aws_lb_target_group" "test" {
  depends_on = [
    aws_instance.webserver_1,
    aws_instance.webserver_2
  ]
  name        = "webserver-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = data.aws_vpc.selected.id
  target_type = "instance"
}

resource "aws_lb_target_group_attachment" "web1" {
  depends_on = [
    aws_lb_target_group.test
  ]
  target_group_arn = aws_lb_target_group.test.arn
  target_id        = aws_instance.webserver_1.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "web2" {
  depends_on = [
    aws_lb_target_group.test
  ]
  target_group_arn = aws_lb_target_group.test.arn
  target_id        = aws_instance.webserver_2.id
  port             = 80
}

resource "aws_lb" "test" {
  depends_on = [
    aws_lb_target_group.test
  ]
  name               = "webserver-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.webserver_sg.id]
  subnets            = data.aws_subnet_ids.example.ids
}

resource "aws_lb_listener" "front_end" {
  depends_on = [
    aws_lb.test
  ]
  load_balancer_arn = aws_lb.test.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.test.arn
  }
}
