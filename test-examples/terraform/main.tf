terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.45"
    }
  }

  backend "s3" {
    bucket = "tfstate-3ea6z45i"
    key    = "terraform-deploy-authenticated-apigw/key"
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
  api_gateway_name  = "TestAuthApi"
  region            = var.region
}

module "Deployer" {
  source = "git::git@github.com:ProgramGrader/terraform-aws-kotlin-image-deploy-lambda.git"
  account_id                      = var.account_id
  application_properties_location = "../src/main/resources"
  docker_path                     = "../src/main/docker/Dockerfile.native"
  ecr_tags = {
    Type    = "lambda"
    Version = "latest"
  }
  lambda_file_name                = ["GreetingLambda"]
  lambda_project_directory        = "../"
  region                          = var.region
}

resource "aws_api_gateway_resource" "greeting_resource" {
  depends_on = [module.authenticated_api_gateway]
  parent_id   = module.authenticated_api_gateway.api_gateway_root_resource_id
  path_part   = "name"
  rest_api_id = module.authenticated_api_gateway.api_gateway_id
}

resource "aws_api_gateway_method" "GET" {
  depends_on = [module.authenticated_api_gateway]
  authorization = "None"
  http_method   = "GET"
  resource_id   = aws_api_gateway_resource.greeting_resource.id
  rest_api_id   = module.authenticated_api_gateway.api_gateway_id

  request_parameters = {
    "method.request.path.proxy" = true
  }
}

resource "aws_api_gateway_integration" "integrate_deleteAssignment" {
  depends_on              = [module.authenticated_api_gateway]
  http_method             = aws_api_gateway_method.GET.http_method
  integration_http_method = "GET"
  resource_id             = aws_api_gateway_resource.greeting_resource.id
  rest_api_id             = module.authenticated_api_gateway.api_gateway_id
  type                    = "AWS_PROXY"
  uri                     = module.Deployer.lambda_invoke_arn["GreetingLambda"]
}
