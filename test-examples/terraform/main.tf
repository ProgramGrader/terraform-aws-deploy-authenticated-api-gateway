terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.45"
    }
  }

  backend "s3" {
    bucket = "tfstate-3ea6z45i"
    key    = "TerraformModules/key"
    region = "us-east-2"
    dynamodb_table = "app-state"
    encrypt = true
  }
}

provider "aws" {
  region = "us-east-2"
}

module "openapi_authenticated_api_gateway"{
  source = "../../"
  account_id        = "048962136615"
  api_gateway_name  = "us-east-2"
  region            = "us-east-2"
  openapi_spec_json = jsonencode({
    openapi = "3.0.1"
    // The info Object defines metadata about the API, we can add more metadata like contact, version and license.
    info = {
      title   = "test-example"
      description = "This is an example api that creates a rest api gateway using OpenApi Spec"
      version = "1.0"
    }
    //The servers section enables you to define API servers base URLs
    servers = {
      url = "{protocol}://{environment}.example.com/v1"
      variables = {
        environment = {
          default = "api" // Production server
          enum    = ["api", "api.dev", "api.staging"]
        }
        protocol    = {
          default = "https"
          enum    = ["http", "https"]
        }
      }
    }
    // The paths section defines relative individual endpoints in your API
    paths = {
      "/greeting/{name}" = {
        get = {
          tags =["GetGreeting"],
          summary="Given a name returns a Greeting with the name included in it"
          description = "Given name in url path returns a Greeting with the name included in it is returned"
          parameters = [
            {
              in = "path",
              name = "name",
              schema = {
                type = "string"
              },
              required = true,
              description = "The Users chosen name"

            }
          ]
        }

      }
    }
  })
}

module "Deployer" {
  source = "git::git@github.com:ProgramGrader/terraform-aws-kotlin-image-deploy-lambda.git"
  account_id                      = "048962136615"
  application_properties_location = "../src/main/resources"
  docker_path                     = "../src/main/docker/Dockerfile.native"
  ecr_tags = {
    Type    = "lambda"
    Version = "latest"
  }
  lambda_file_name                = ["GreetingLambdaChris"]
  lambda_project_directory        = "../"
  region                          = "us-east-2"
}

resource "aws_api_gateway_resource" "schedule_resource" {
  parent_id   = module.openapi_authenticated_api_gateway.api_gateway_root_resource_id
  path_part   = "schedule"
  rest_api_id = module.openapi_authenticated_api_gateway.api_gateway_id
}

resource "aws_api_gateway_method" "GET" {
  authorization = "NONE"
  http_method   = "GET"
  resource_id   = aws_api_gateway_resource.schedule_resource.id
  rest_api_id   = module.openapi_authenticated_api_gateway.api_gateway_id

  request_parameters = {
    "method.request.path.proxy" = true
  }
}

resource "aws_api_gateway_integration" "integrate_deleteAssignment" {
  depends_on = [module.openapi_authenticated_api_gateway]
  http_method = aws_api_gateway_method.GET.http_method
  integration_http_method = "GET"
  resource_id = aws_api_gateway_resource.schedule_resource.id
  rest_api_id = module.openapi_authenticated_api_gateway.api_gateway_id
  type        = "AWS_PROXY"
  uri = module.Deployer.lambda_invoke_arn["GreetingLambdaChris"]
}