resource "aws_api_gateway_rest_api" "api" {
  name          = var.api_gateway_name
  description = var.api_gateway_description
  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

module "Deployer"{
  source = "git::git@github.com:ProgramGrader/terraform-aws-kotlin-image-deploy-lambda.git"
  account_id                      = "048962136615"
  ecr_tags = {
    Type    = "lambda"
    Version = "latest"
  }

  lambda_file_name                = ["LambdaAuthorizer"]
  region                          = "us-east-2"
}

resource "aws_iam_role" "invocation_role" {
  name = "gateway_auth_invocation"
  path = "/"
lifecycle {
  create_before_destroy = true
}
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "apigateway.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "invocation_policy" {
  name = "default"
  role = aws_iam_role.invocation_role.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "lambda:InvokeFunction",
      "Effect": "Allow",
      "Resource": "${module.Deployer.lambda_arn["LambdaAuthorizer"]}"
    }
  ]
}
EOF
}

#data "aws_iam_role" "invocation_policy" {
#  name = "gateway_auth_invocation"
#}

resource "aws_iam_role" "lambda" {
 // count = var.authenticator_exists == false ? 0 : 1
  name = "LambdaAuthorizer"

      assume_role_policy = <<EOF
    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Action": "sts:AssumeRole",
          "Principal": {
            "Service": "lambda.amazonaws.com"
          },
          "Effect": "Allow",
          "Sid": ""
        }
      ]
    }
    EOF
  lifecycle {
    create_before_destroy = true
  }
}

#data "aws_iam_role" "lambda"{
#  count = var.authenticator_exists == false ? 1 : 0
#  name = aws_iam_role.lambda.name
#}

resource "aws_iam_policy" "secrets-manager-policy" {
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [{
      "Action": [
        "secretsmanager:GetSecretValue",
        "ssm:GetParameter"

      ],
      "Effect": "Allow",
      "Resource": "*"
    }
    ]})

}

resource "aws_iam_role_policy_attachment" "attach_Lambda_auth_sm_perm"{
  depends_on = [module.Deployer["LambdaAuthorizer"]]
  policy_arn = aws_iam_policy.secrets-manager-policy.arn
  role       = module.Deployer.lambda_role_name["LambdaAuthorizer"]
}

resource "aws_api_gateway_authorizer" "Token_Authorizer" {
  depends_on = [module.Deployer]
  name                   = "APITokenAuthorizer"
  rest_api_id            = aws_api_gateway_rest_api.api.id
  authorizer_uri         = module.Deployer.lambda_invoke_arn["LambdaAuthorizer"]
  authorizer_credentials = aws_iam_role. invocation_role.arn
  //type = "TOKEN"
}

// Api key who's value is generated by aws on creation
// TODO migrate all deployment to terraform cloud
resource "random_id" "api_auth" {
 // count = var.authenticator_exists == false ? 0 : 1
  byte_length = 8
}

# TODO needs to rotate
resource "aws_secretsmanager_secret" "secret" {
  //count = var.authenticator_exists == false ? 0 : 1
  name = "AuthenticatorGateway"
  recovery_window_in_days = 0
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_secretsmanager_secret_version" "version" {
  //count = var.authenticator_exists == false ? 0 : 1
  secret_id = aws_secretsmanager_secret.secret.id
  secret_string = random_id.api_auth.id
  lifecycle {
    create_before_destroy = true
  }
}

#data "aws_secretsmanager_secret" "version" {
#  count = var.authenticator_exists == false ? 1 : 0
#  name = "AuthenticatorGateway"
#}