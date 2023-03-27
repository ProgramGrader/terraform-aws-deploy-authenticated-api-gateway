# Depending on the gateway version passed to the module is the api that is created

resource "aws_apigatewayv2_api" "apiv2"{
  count = var.gateway_version == 2 ? 1 : 0
  name          = var.api_gateway_name
  protocol_type = "HTTP"
}

resource "aws_api_gateway_rest_api" "apiv1" {
  count = var.gateway_version == 1 ? 1 : 0
  name          = var.api_gateway_name
  description = var.api_gateway_description
  endpoint_configuration {
    types = ["REGIONAL"]
  }
}


# Determining which authenticator to use depending on version
data "aws_lambda_function" "lambda_auth" {
  function_name = var.gateway_version == 1 ? "APIGatewayV1Authorizer" : "APIGatewayV2Authorizer"
}

data "aws_iam_role" "invocation_role" {
  name = "gateway_auth_invocation"
}

resource "aws_api_gateway_authorizer" "Token_Authorizer_V1" {
  count = var.gateway_version == 1 ? 1 : 0
  name                   = "APIGatewayV1Authorizer"
  rest_api_id            =  aws_api_gateway_rest_api.apiv1[count.index].id
  authorizer_uri         = data.aws_lambda_function.lambda_auth.invoke_arn
  authorizer_credentials = data.aws_iam_role.invocation_role.arn
#  identity_source                  = "method.request.header.Authorizer"
  //type = "TOKEN"
}

resource "aws_apigatewayv2_authorizer" "Token_Authorizer_V2" {
  count =  var.gateway_version == 2 ? 1 : 0
  api_id          = aws_apigatewayv2_api.apiv2[count.index].id
  authorizer_type = "REQUEST"
  identity_sources = ["$request.header.Authorization"]
  authorizer_credentials_arn = data.aws_iam_role.invocation_role.arn
  name            = "APIGatewayV2Authorizer"
  enable_simple_responses = true
  authorizer_uri = data.aws_lambda_function.lambda_auth.invoke_arn
  authorizer_payload_format_version = "2.0"
}

// giving authenticator permission to be called by the api
#resource "aws_lambda_permission" "allow_apigw_to_trigger_Auth_lambda" {
#  statement_id = "AllowExecutionFromAPIGateway"
#  action        = "lambda:InvokeFunction"
#  function_name = var.gateway_version == 2? "APIGatewayV2Authorizer" : "APIGatewayV1Authorizer"
#  principal     = "apigateway.amazonaws.com"
#  source_arn    = var.gateway_version == 2 ? "${aws_apigatewayv2_api.apiv2[0].execution_arn}/*/*/*" : "${aws_api_gateway_rest_api.apiv1[0].execution_arn}/*/*/*"
#}