##############
## REQUIRED ##
##############

variable "account_id" {
  type = string
}

variable "region" {
  type = string
}

variable "api_gateway_name" {
  type = string
}

##################
## NON-REQUIRED ##
##################

variable "api_gateway_description" {
  type = string
  default = ""
}