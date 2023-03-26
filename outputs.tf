
// This file needs to be in the same directory as the lambda, for simplicity

output "api_gateway_id" {
  value = aws_api_gateway_rest_api.api.id
}
output "api_gateway_root_resource_id" {
  value = aws_api_gateway_rest_api.api.root_resource_id
}
output "api_gateway_execution_arn" {
  value = aws_api_gateway_rest_api.api.execution_arn
}

output "authorizer_id" {
  value = aws_api_gateway_authorizer.Token_Authorizer.id
}


resource "aws_ssm_parameter" "region" {
  name  = "csgrader-REGION"
  type  = "String"
  value = var.region
  overwrite = true
}