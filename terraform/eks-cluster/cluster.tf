resource "aws_eks_cluster" "nr_sandbox" {
  name     = var.cluster_name
  version  = var.kubernetes_version
  role_arn = aws_iam_role.nr_sandbox-cluster.arn

  vpc_config {
    subnet_ids = aws_subnet.nr_sandbox.*.id
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Cluster handling.
  # Otherwise, EKS will not be able to properly delete EKS managed EC2 infrastructure such as Security Groups.
  depends_on = [
    aws_iam_role_policy_attachment.nr_sandbox-AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.nr_sandbox-AmazonEKSVPCResourceController,
  ]
}

resource "aws_security_group" "cluster_nodes_security_group" {
  name        = "terraform-eks-${var.cluster_name}-cluster-nodes-security-group"
  description = "Allow HTTP traffic from the load balancer and within the group"
  vpc_id      = aws_vpc.nr_sandbox.id

  ingress {
    description      = "TLS from Load Balancer"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    security_groups  = [aws_security_group.alb_security_group.id]
  }
  
  ingress {
    description      = "HTTP from Load Balancer"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    security_groups  = [aws_security_group.alb_security_group.id]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_launch_template" "cluster_nodes" {
  name = "terraform-eks-${var.cluster_name}-cluster-nodes-launch-template"
  vpc_security_group_ids = [aws_security_group.cluster_nodes_security_group.id]
}

resource "aws_eks_node_group" "nr_sandbox" {
  cluster_name    = aws_eks_cluster.nr_sandbox.name
  node_group_name = var.cluster_name
  node_role_arn   = aws_iam_role.nr_sandbox-node.arn
  subnet_ids      = aws_subnet.nr_sandbox.*.id

  scaling_config {
    desired_size = 3
    max_size     = 3
    min_size     = 2
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_iam_role_policy_attachment.nr_sandbox-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.nr_sandbox-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.nr_sandbox-AmazonEC2ContainerRegistryReadOnly,
  ]
}
