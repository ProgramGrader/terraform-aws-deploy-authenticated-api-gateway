
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

resource "aws_ssm_parameter" "auth_key" {
  name  = "csgrader-AUTHENTICATION_KEY"
  type  = "String"
  value = aws_secretsmanager_secret.secret.name
}

resource "aws_ssm_parameter" "region" {
  name  = "csgrader-REGION"
  type  = "String"
  value = var.region
}