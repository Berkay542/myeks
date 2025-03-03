variable "vpc_id" {}
variable "bastion_cidr" {}
variable "env" {}
variable "eks_name" {} 
variable "project" {}
variable "public_subnet_ids" {}
variable "private_subnet_ids" {}

variable "k8s-version" {
   default="1.29"
}
variable "endpoint_private_access" {
  default = true
}
variable "endpoint_public_access" {
  default = false
}
variable "kubernetes_network_config-sevice-ipv4-cidr" {
 default = "172.20.0.0/16"
 }

variable "nodegroups-name" {}
