
#Deploying api gateway authorizers
module "Deployer"{
  source = "git::git@github.com:ProgramGrader/terraform-aws-kotlin-image-deploy-lambda.git"
  account_id= "048962136615"
  ecr_tags = {
    Type    = "lambda"
    Version = "latest"
  }
  lambda_file_name                = ["APIGatewayV1Authorizer", "APIGatewayV2Authorizer"]
  region                          = "us-east-2"
}


resource "aws_iam_role" "invocation_role" {
  name = "gateway_auth_invocation"
  path = "/"
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

  lifecycle {
    create_before_destroy = true
  }
}



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


resource "aws_iam_role_policy" "invocation_policy_APIGatewayV1Authorizer" {
  #  for_each = module.Deployer[]
  name = "invocation_policy_APIGatewayV1Authorizer"
  role = aws_iam_role.invocation_role.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "lambda:InvokeFunction",
      "Effect": "Allow",
      "Resource": "${module.Deployer.lambda_arn["APIGatewayV1Authorizer"]}"
    }
  ]
}
EOF
}


resource "aws_iam_role_policy" "invocation_policy_APIGatewayV2Authorizer" {
  #  for_each = module.Deployer[]
  name = "invocation_policy_APIGatewayV2Authorizer"
  role = aws_iam_role.invocation_role.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "lambda:InvokeFunction",
      "Effect": "Allow",
      "Resource": "${module.Deployer.lambda_arn["APIGatewayV2Authorizer"]}"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "attach_api_gw_v1_sm_perm"{
  policy_arn = aws_iam_policy.secrets-manager-policy.arn
  role       = module.Deployer.lambda_role_name["APIGatewayV1Authorizer"]
}


resource "aws_iam_role_policy_attachment" "attach_api_gw_v2_sm_perm"{
  policy_arn = aws_iam_policy.secrets-manager-policy.arn
  role       = module.Deployer.lambda_role_name["APIGatewayV2Authorizer"]
}


resource "aws_iam_policy" "api_gateway_policy" {
  name        = "api_gateway_policy"
  policy      = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = ["lambda:InvokeFunction"]
        Resource = ["*"]
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "api_gateway_role" {
  policy_arn = aws_iam_policy.api_gateway_policy.arn
  role       = module.Deployer.lambda_role_name["APIGatewayV2Authorizer"]
}


resource "aws_secretsmanager_secret" "secret" {

  name = "APIAuthenticationToken"
  recovery_window_in_days = 0
  force_overwrite_replica_secret = true

}


resource "aws_ssm_parameter" "auth_key" {
  name  = "csgrader-AUTHENTICATION_KEY"
  type  = "String"
  value = aws_secretsmanager_secret.secret.name
  overwrite = true
}

resource "random_id" "api_auth" {
  // count = var.authenticator_exists == false ? 0 : 1
  byte_length = 8
}

resource "aws_secretsmanager_secret_version" "version" {
  //count = var.authenticator_exists == false ? 0 : 1
  secret_id = aws_secretsmanager_secret.secret.id
  secret_string = random_id.api_auth.id
}


