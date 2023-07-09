
variable "region" {}
variable "zone" {}
variable "project" {}
variable "machine_type" {}
variable "image" {}
variable "gce_ssh_user" {}
variable "gce_ssh_pub_key_file" {}
variable "gce_service_account" {}
variable "gce_ssh_pv_key_file" {}
variable "tags" {}
variable "num" {}



variable "fw-k8s-master" {
  default = "gcp-k8s-master-fw"
}

variable "fw-k8s-worker" {
  default = "gcp-k8s-worker-fw"
}


