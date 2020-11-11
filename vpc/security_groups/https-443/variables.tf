variable "name" {}
variable "vpc_id" {}
variable "ingress_cidr_blocks" {
  type = list(string)
  default = []
}