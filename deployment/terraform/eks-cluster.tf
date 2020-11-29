resource "aws_iam_role" "miro-cluster" {
  name = "eks-miro-cluster"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "miro-cluster-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role = aws_iam_role.miro-cluster.name
}

resource "aws_iam_role_policy_attachment" "miro-cluster-AmazonEKSServicePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role = aws_iam_role.miro-cluster.name
}

resource "aws_security_group" "miro-cluster" {
  name = "eks-miro-cluster"
  vpc_id = aws_vpc.miro.id
  description = "Cluster communication with worker nodes"

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [
      "0.0.0.0/0"]
  }

  ingress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [
      "0.0.0.0/0"]
  }

}

resource "aws_security_group_rule" "miro-cluster-ingress-workstation-https" {
  cidr_blocks = [
    local.workstation-external-cidr]
  description = "Allow workstation to communicate with the cluster API Server"
  from_port = 443
  protocol = "tcp"
  security_group_id = aws_security_group.miro-cluster.id
  to_port = 443
  type = "ingress"
}

resource "aws_eks_cluster" "miro" {
  name = "eks-miro"
  role_arn = aws_iam_role.miro-cluster.arn

  vpc_config {
    security_group_ids = [
      aws_security_group.miro-cluster.id]
    subnet_ids = aws_subnet.miro-app[*].id
  }

  depends_on = [
    aws_iam_role_policy_attachment.miro-cluster-AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.miro-cluster-AmazonEKSServicePolicy,
  ]
}
