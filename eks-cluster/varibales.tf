variable "EnvironmentName" {
  default = "EKS"
}

variable "VpcCIDR" {
  default = "192.168.0.0/16"
}
variable "aws_profile" {
  default = "sh-stage"
}
variable "aws_region" {
  default = "us-east-1"
}