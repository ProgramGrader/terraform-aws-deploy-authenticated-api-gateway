# terraform-aws-deploy-authenticated-api-gateway

---
This module is responsible for creating and authenticating a aws rest api gateway
it uses a lambda authorizer which simply intercepts each request that hits your api gateway and compares a api key saved in aws secret manager with the token provided
in request (The request token is placed in the header with the key Authentication e.g Authentication:value)


## Introduction
In this repo you'll find the implementation of token based lambda authorizers for aws api gateways (v1 and v2, the authorizers themselves needs to be deployed before 
the authenticated api gateway) and an example demoing the use case of this module

