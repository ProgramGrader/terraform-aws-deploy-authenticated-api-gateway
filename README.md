<!-- markdownlint-disable -->
# terraform-aws-deploy-authenticated-openapi-gateway

---
This module is responsible for creating and authenticating a aws rest api gateway
it uses a lambda authorizer which simply intercepts each request that hits your api gateway and compares a api key saved in aws secret manager with the token provided
in request (The request token is placed in the header with the key Authentication e.g Authentication:value)


## Introduction
In this repo you'll find an implementation of a token based lambda authorizer (which needs to be deployed before 
the authenticated api gateway) and an example demoing the use case of this module  

## Vars

| Component                          | Description                         |
|------------------------------------|-------------------------------------|
| region (REQUIRED)                  | AWS region to deploy api gateway to |
| api_gateway_name (REQUIRED)        | API gateway name                    |
| api_gateway_description (OPTIONAL) | API gateway description             |

## Outputs

| Component                    | Description                                                                                                              |
|------------------------------|--------------------------------------------------------------------------------------------------------------------------|
| api_gateway_id               | Used to define resources and integrations                                                                                |
| api_gateway_root_resource_id | Used in integrations                                                                                                     |
| api_gateway_execution_arn    | Used to trigger certain resources                                                                                      |
| config_output (local_file)   | Saves API_ARN & AWS REGION to a json file so that the lambda Authenticator function can be paired with a specific API GW |



