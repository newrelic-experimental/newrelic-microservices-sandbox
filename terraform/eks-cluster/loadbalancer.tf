resource "aws_lb_target_group" "k8s-acc" {
  name     = "alb-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.k8s-acc.id
  
  tags = {
    "Owner" = "${var.owner}"
  }
}

resource "aws_autoscaling_attachment" "k8s-acc" {
  for_each = toset(aws_eks_node_group.k8s-acc.resources[0].autoscaling_groups[*].name)
  autoscaling_group_name = each.value
  lb_target_group_arn   = aws_lb_target_group.k8s-acc.arn
}

resource "aws_security_group" "alb_security_group" {
  name        = "terraform-eks-${var.cluster_name}-alb-security-group"
  description = "Allow HTTP inbound traffic from everywhere"
  vpc_id      = aws_vpc.k8s-acc.id

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

  tags = {
    Owner = var.owner
  }
}

resource "aws_lb" "k8s-acc" {
  name               = "nr-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_security_group.id]
  subnets            = [for subnet in aws_subnet.k8s-acc : subnet.id]

  tags = {
    Owner = var.owner
  }
}

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.k8s-acc.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.k8s-acc.arn
  }
}