variable "name" {}
variable "environment" {}
variable "cluster_id" {}
variable "ecs_service_desired_count" {}
variable "ecs_service_deployment_maximum_percent" {}
variable "ecs_service_deployment_minimum_healthy_percent" {}
variable "container_port" {}
variable "target_group_arn" {}
variable "container_name" {}
variable "vpc_id" {}
variable "alb_security_group_id" {}
variable "private_subnet_ids" {
  type = list
}
variable "cloudwatch_log_retention_in_days" {
  default = 3
}
