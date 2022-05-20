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

resource "aws_eks_node_group" "nr_sandbox" {
  cluster_name    = aws_eks_cluster.nr_sandbox.name
  node_group_name = var.cluster_name
  node_role_arn   = aws_iam_role.nr_sandbox-node.arn
  subnet_ids      = aws_subnet.nr_sandbox.*.id
  instance_types  = ["t3.large"]

  scaling_config {
    desired_size = 3
    max_size     = 5
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
