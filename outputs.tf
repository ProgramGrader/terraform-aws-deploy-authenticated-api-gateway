
// This file needs to be in the same directory as the lambda, for simplicity
resource "local_file" "config_output" {
  filename = "${path.module}/LambdaAuthorizer/src/main/kotlin/application.conf"
  content = jsonencode(
    {
      "API_ARN"= aws_api_gateway_rest_api.api.arn
      "SECRET_KEY" = aws_secretsmanager_secret.secret.name
      "REGION"=var.region
      "ACCOUNT_ID"= var.account_id
    })
}

output "api_gateway_id" {
  value = aws_api_gateway_rest_api.api.id
}
output "api_gateway_root_resource_id" {
  value = aws_api_gateway_rest_api.api.root_resource_id
}
output "api_gateway_execution_arn" {
  value = aws_api_gateway_rest_api.api.execution_arn
}