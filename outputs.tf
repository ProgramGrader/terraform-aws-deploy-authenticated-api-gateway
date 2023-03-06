resource "local_file" "config_output" {
  depends_on = [module.Deployer]
  filename = "LambdaAuthorizer/main/resources/application.conf"
  content = jsonencode(
    {
      "API_ARN"= aws_api_gateway_rest_api.api.arn
      "REGION"=var.region
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