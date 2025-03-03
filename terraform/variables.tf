variable "cidr_block" {}
variable "env" {}
variable "eks_name" {}
variable "zone1" {}
variable "zone2" {}
variable "region" {}
variable "availability_zones" {}
variable "public_subnet_cidrs" {}
variable "private_subnet_cidrs" {}  
variable "project" {}
variable "bastion_cidr" {}
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

variable "k8sV" {
}

variable "terraform_remote_state_bucket" {
}

variable "tf_s3_bucket_folder" {
}


####### nodegroup vars#######
variable "nodegroups-ami-type" {}
variable "nodegroups-capacity-type" {}
variable "nodegroups-disk-size" {}
variable "nodegroups-name" {}
variable "nodegroups-instance-type" {}
variable "nodegroups-desired-size" {}
variable "nodegroups-min-size" {}
variable "nodegroups-max-size" {}
variable "instance_keypair" {}
variable "nodegroups-update-config-max_unavailable" {}
variable "nodegroups-sb-id" {}
variable "terraform_remote_state_bucket" {}
variable "policies_to_attach" {}
variable "required_policies_to_attach" {}
variable "tf_s3_bucket_folder" {}
variable "log_files_bucket" {}
