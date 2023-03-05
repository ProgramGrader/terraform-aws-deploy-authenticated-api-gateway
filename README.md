# terraform-deploy-authenticated-open-api-gateway
This module is responsible for creating and authenticating a aws rest api gateway
it uses a lambda authorizer which simply intercepts each request that hits your api gateway and compares a api key saved in aws secret manager with the token provided
in request
