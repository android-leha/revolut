#
# Outputs
#

locals {
    config_map_aws_auth = <<CONFIGMAPAWSAUTH
apiVersion: v1
kind: ConfigMap
metadata:
  name: aws-auth
  namespace: kube-system
data:
  mapRoles: |
    - rolearn: ${aws_iam_role.miro-node.arn}
      username: system:node:{{EC2PrivateDNSName}}
      groups:
        - system:bootstrappers
        - system:nodes
CONFIGMAPAWSAUTH

    kubeconfig = <<KUBECONFIG
apiVersion: v1
clusters:
- cluster:
    server: ${aws_eks_cluster.miro.endpoint}
    certificate-authority-data: ${aws_eks_cluster.miro.certificate_authority.0.data}
  name: kubernetes
contexts:
- context:
    cluster: kubernetes
    user: aws
  name: aws
current-context: aws
kind: Config
preferences: {}
users:
- name: aws
  user:
    exec:
      apiVersion: client.authentication.k8s.io/v1alpha1
      command: aws-iam-authenticator
      args:
        - "token"
        - "-i"
        - "${aws_eks_cluster.miro.name}"
KUBECONFIG

    helmvalues = <<HELMVALUES
db:
  host: ${aws_db_instance.miro_db.address}
  password: ${random_password.password.result}
HELMVALUES

}

output "config_map_aws_auth" {
    value = local.config_map_aws_auth
}

output "kubeconfig" {
    value = local.kubeconfig
}

output "values" {
    value = local.helmvalues
}
