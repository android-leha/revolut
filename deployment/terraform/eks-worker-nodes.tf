#
# EKS Worker Nodes Resources
#  * IAM role allowing Kubernetes actions to access other AWS services
#  * EKS Node Group to launch worker nodes
#

resource "aws_iam_role" "revolut-node" {
  name = "eks-revolut-node"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "revolut-node-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.revolut-node.name
}

resource "aws_iam_role_policy_attachment" "revolut-node-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.revolut-node.name
}

resource "aws_iam_role_policy_attachment" "revolut-node-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.revolut-node.name
}

resource "aws_eks_node_group" "revolut" {
  cluster_name    = aws_eks_cluster.revolut.name
  node_group_name = "revolut"
  node_role_arn   = aws_iam_role.revolut-node.arn
  subnet_ids      = aws_subnet.revolut[*].id

  scaling_config {
    desired_size = 1
    max_size     = 1
    min_size     = 1
  }

  depends_on = [
    aws_iam_role_policy_attachment.revolut-node-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.revolut-node-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.revolut-node-AmazonEC2ContainerRegistryReadOnly,
  ]
}
