
// This file needs to be in the same directory as the lambda, for simplicity

output "apiv1_gateway_id" {
  value = var.gateway_version == 1 ? aws_api_gateway_rest_api.apiv1[0].id : null
}

output "apiv2_gateway_id" {
  value =var.gateway_version == 2 ? aws_apigatewayv2_api.apiv2[0].id : null
}

output "apiv1_gateway_root_resource_id" {
  value = var.gateway_version == 1 ? aws_api_gateway_rest_api.apiv1[0].root_resource_id : null
}

output "apiv1_gateway_execution_arn" {
  value = var.gateway_version == 1 ?  aws_api_gateway_rest_api.apiv1[0].execution_arn: null
}

output "apiv2_gateway_execution_arn" {
  value = var.gateway_version ==2 ? aws_apigatewayv2_api.apiv2[0].execution_arn : null
}

output "v1authorizer_id" {
  value = var.gateway_version == 1 ? aws_api_gateway_authorizer.Token_Authorizer_V1[0].id : null
}

output "v2authorizer_id" {
  value = var.gateway_version == 2 ? aws_apigatewayv2_authorizer.Token_Authorizer_V2[0].id : null
}

output "apigateway_name" {
  value = var.api_gateway_name
}

resource "aws_ssm_parameter" "region" {
  name  = "csgrader-REGION"
  type  = "String"
  value = var.region
  overwrite = true
}