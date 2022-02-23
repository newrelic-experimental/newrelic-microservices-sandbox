resource "aws_lb_target_group" "nr_sandbox" {
  name     = "alb-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.nr_sandbox.id
}

resource "aws_autoscaling_attachment" "nr_sandbox" {
  autoscaling_group_name = aws_eks_node_group.nr_sandbox.resources[0].autoscaling_groups[0].name
  lb_target_group_arn   = aws_lb_target_group.nr_sandbox.arn
}

resource "aws_security_group" "alb_security_group" {
  name        = "${var.cluster_name}-alb-security-group"
  description = "Allow HTTP inbound traffic from everywhere"
  vpc_id      = aws_vpc.nr_sandbox.id

  ingress {
    description      = "TLS from everywhere"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  
  ingress {
    description      = "HTTP from everywhere"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_lb" "nr_sandbox" {
  name               = "newrelic-sandbox"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_security_group.id]
  subnets            = [for subnet in aws_subnet.nr_sandbox : subnet.id]
}

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.nr_sandbox.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.nr_sandbox.arn
  }
}