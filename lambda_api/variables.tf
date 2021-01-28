locals {
  zip_file = "lambda.zip"
  output   = "output.txt"
}
variable "profile" {
    type = string
    description = "Profile name define in AWS Configure CLI"
}
variable "region" {
    type = string
    description = "AWS Region where you want to create resources"
}