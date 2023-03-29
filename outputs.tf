
output "api_gateway_id" {
  value = var.gateway_version == 1 ? aws_api_gateway_rest_api.apiv1[0].id : aws_apigatewayv2_api.apiv2[0].id
}

output "apiv1_gateway_root_resource_id" {
  value = var.gateway_version == 1 ? aws_api_gateway_rest_api.apiv1[0].root_resource_id : null
}

output "api_gateway_execution_arn" {
  value = var.gateway_version == 1 ? aws_api_gateway_rest_api.apiv1[0].execution_arn: aws_apigatewayv2_api.apiv2[0]
}

output "authorizer_id" {
  value = var.gateway_version == 1 ? aws_api_gateway_authorizer.Token_Authorizer_V1[0].id : aws_apigatewayv2_authorizer.Token_Authorizer_V2[0].id
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