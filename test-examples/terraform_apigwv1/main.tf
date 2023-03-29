terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.45"
    }
  }

  backend "s3" {
    bucket = "tfstate-3ea6z45i"
    key    = "terraform-deploy-authenticated-apigwv1/key"
    region = "us-east-2"
    dynamodb_table = "app-state"
    encrypt = true
  }
}

provider "aws" {
  region = "us-east-2"
}

module "authenticated_api_gateway"{
  source = "../../"
  account_id = "048962136615"
  api_gateway_name  = "TestAuthApiV1"
  region            = var.region
  gateway_version = 1
}

module "Deployer" {
  source = "git::git@github.com:ProgramGrader/terraform-aws-kotlin-image-deploy-lambda.git"
  account_id                      = var.account_id
  ecr_tags = {
    Type    = "lambda"
    Version = "latest"
    }
  lambda_file_name                = ["GreetingLambdaV1"]
  region                          = var.region
}


resource "aws_lambda_permission" "allow_apigw_to_trigger_Greeting_lambda" {
  statement_id = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = "GreetingLambda"
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${module.authenticated_api_gateway.apigateway_name}/*/*"
}

resource "aws_api_gateway_resource" "greeting_resource" {
  depends_on = [module.authenticated_api_gateway]
  parent_id   = module.authenticated_api_gateway.apiv1_gateway_root_resource_id
  path_part   = "name"
  rest_api_id = module.authenticated_api_gateway.api_gateway_id
}

resource "aws_api_gateway_method" "GET" {
  depends_on = [module.authenticated_api_gateway]
  authorization = "Custom"
  authorizer_id = module.authenticated_api_gateway.authorizer_id
  http_method   = "GET"
  resource_id   = aws_api_gateway_resource.greeting_resource.id
  rest_api_id   = module.authenticated_api_gateway.api_gateway_id

  request_parameters = {
    "method.request.path.proxy" = true
  }
}

resource "aws_api_gateway_integration" "integrate_get" {
  depends_on              = [module.authenticated_api_gateway]
  http_method             = aws_api_gateway_method.GET.http_method
  integration_http_method = "POST"
  resource_id             = aws_api_gateway_resource.greeting_resource.id
  rest_api_id             = module.authenticated_api_gateway.api_gateway_id
  type                    = "AWS_PROXY"
  uri                     = module.Deployer.lambda_invoke_arn["GreetingLambda"]
}

resource "aws_api_gateway_deployment" "deploy" {
  depends_on = [aws_api_gateway_integration.integrate_get]
  rest_api_id = module.authenticated_api_gateway.api_gateway_id

  lifecycle {
    create_before_destroy = true
  }

  description = "Deployed endpoint at ${timestamp()}"
}

resource "aws_api_gateway_stage" "dev"{
  deployment_id = aws_api_gateway_deployment.deploy.id
  rest_api_id= module.authenticated_api_gateway.api_gateway_id
  stage_name    = "dev"
  xray_tracing_enabled = true
}
resource "aws_api_gateway_method_settings" "general_settings" {
  rest_api_id = module.authenticated_api_gateway.api_gateway_id
  stage_name  = aws_api_gateway_stage.dev.stage_name
  method_path = "*/*"

  settings {
    # Enable CloudWatch logging and metrics
    metrics_enabled    = true
    data_trace_enabled = true
    logging_level      = "INFO"

    # Limit the rate of calls to prevent abuse and unwanted charges
    throttling_rate_limit  = 100
    throttling_burst_limit = 50
  }
}

resource "aws_api_gateway_account" "demo" {
  cloudwatch_role_arn = data.aws_iam_role.cloudwatch.arn
}

data "aws_iam_role" "cloudwatch" {
  name               = "api_gateway_cloudwatch_global"
}


resource "aws_iam_role_policy" "cloudwatch" {
  name = "default"
  role = data.aws_iam_role.cloudwatch.id

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:DescribeLogGroups",
                "logs:DescribeLogStreams",
                "logs:PutLogEvents",
                "logs:GetLogEvents",
                "logs:FilterLogEvents"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}



