resource "aws_iam_role" "miro-node" {
  name = "eks-miro-node"

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

resource "aws_iam_role_policy_attachment" "miro-node-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role = aws_iam_role.miro-node.name
}

resource "aws_iam_role_policy_attachment" "miro-node-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role = aws_iam_role.miro-node.name
}

resource "aws_iam_role_policy_attachment" "miro-node-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role = aws_iam_role.miro-node.name
}

resource "aws_eks_node_group" "miro" {
  cluster_name = aws_eks_cluster.miro.name
  node_group_name = "miro"
  node_role_arn = aws_iam_role.miro-node.arn
  subnet_ids = aws_subnet.miro-app[*].id

  scaling_config {
    desired_size = 3
    max_size = 5
    min_size = 3
  }

  tags = {
    "kubernetes.io/cluster/eks-miro" = "owned"
  }


  depends_on = [
    aws_iam_role_policy_attachment.miro-node-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.miro-node-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.miro-node-AmazonEC2ContainerRegistryReadOnly,
  ]
}
