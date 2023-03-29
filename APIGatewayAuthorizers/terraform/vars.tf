variable "aws_account_id" {
  default = "048962136615"
}

variable "primary_aws_region" {
  default = "us-east-2"
}

variable "secondary_aws_region" {
  default = "us-east-1"
}

variable "api_key_name" {
  type = string
  default = ""
  sensitive = true
}

variable "api_key_value" {
  type = string
  default = ""
  sensitive = true
}