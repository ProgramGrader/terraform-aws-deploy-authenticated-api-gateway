module "Deployer"{
  source = "git::git@github.com:ProgramGrader/terraform-aws-kotlin-image-deploy-lambda.git"
  account_id= "048962136615"
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
  policy_arn = aws_iam_policy.secrets-manager-policy.arn
  role       = module.Deployer.lambda_role_name["LambdaAuthorizer"]
}
