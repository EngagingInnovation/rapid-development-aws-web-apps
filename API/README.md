# Create RESTful App using AWS API Gateway and Lambda Authorizer

## What does this do?
A template project to create a simple, single RESTful web application that is accessed via AWS API Gateway. The project uses Terraform to manage the AWS resources, including two Lambda functions written in Typescript. The project includes a 'hello' endpoint with exposed GET and OPTIONS interfaces, defined in an OpenAPI yaml file. The API returns a basic JSON body. The API will be protected with a simple, home-grown Basic Auth solution. In this case, the Auth is not intended to be all that secure. It is included here as an example of how an authorization request would be made within this framework, intended to be a semi-restrictive road block to your API. 

## What is being created? 
Without any additional configuration, and assuming all the command line [dependencies](../README.md#dependencies) are in place, running the `make` command will create these resources in your AWS account

1. API Gateway v2 (HTTP) Deployment
2. Lambda for Data
3. Lambda for Auth
4. IAM Role & Policy for Lambdas
5. CloudWatch Logs Groups for each Lambda function

The `make` command also runs Node.js commands to compile the TypeScript functions for optimized execution in AWS Lambda. When the process completes its deployment steps, you should be able to access your api with the following command:

`EMAIL=let@me.in; curl -u ${EMAIL}:${EMAIL} https://<API Gateway Invoke URL>/hello`

### domain name
Make sure to [check the README](../README.md#custom-domains-for-each-template) in the parent directory for further information about attaching a custom domain name to this project.

### OpenAPI and CORS
The API is defined in an Open API yaml file at the root of this folder. This document follows the [Open API spec](https://spec.openapis.org/oas/latest.html), as well as [additions for AWS](https://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-swagger-extensions.html) specific functionality. Defining endpoints and configurations in the YAML file is simpler and clearer than using Terraform. The YAML file is more concise and achieves the same output.

If you plan on reading your API from within a web app (like that created in the parent folder named 'Web'), you'll need to configure your CORS settings. The settings itself is a list value defined in the `terraform/variables.tf` file. For local development with React, add the host `http://localhost:3000`. Add any other domains - such as those from test or production environments on the web - to the list.

### logging
Logging is managed by a node library called [Powertools for AWS Lambda](https://docs.powertools.aws.dev/lambda/typescript/latest/core/logger/), maintained by the AWS team. This library offers added benefits over a standard `console.log()` statement, such as providing more Lambda context and generating structured log statements. Having this level of detail available in the logs helps significantly when optimizing your application, when searching for random error patterns, or finding fields without trying to glob with the right pattern matching.  

### what's with the auth?
Creating an API without an authentication layer feels like an anti-pattern. All of the good stuff is behind your API, so why give that away without knowing who is seeking your data? Even with GET requests, your API may be using resources on AWS that could cost you a significant sum if you don't set limits. If you want to start building with AI tools, like Bedrock, costs can add up quickly if you're not careful. 

API Gateway provides us a way to create custom authorizers. In this example we are using Basic Auth, as checked in our `fn-auth` function, to validate that an incoming username/password pair are allowed to access our GET endpoint. The function is using the [Lambda Authorizer response format 2.0](https://docs.aws.amazon.com/apigateway/latest/developerguide/http-api-lambda-authorizer.html), which returns a simple object to the API Gateway with an 'isAuthorized' field set to true/false and a context object. Getting Typescript to accept the syntax was a little tricky, and I owe a lot to [this blog article](https://www.lbogdan.com/implementing-typescript-for-aws-authoriser-lambda-with-apigateway-v2-http-api/) to help navigate the proper interfaces. 

This solution is not highly secure as the key can be shared or guessed. The intent with this solution is: 

1. to build an access pattern to the API that prevents wide-open browsing;
2. an almost no-cost serverless solution;
3. to provide a template that could be modified to provide more hardend user access if your project is bound for production;

### production ready auth
If you do want to take this to the next level, there are plenty of for-cost hosted services that provide authentication (and authorization) solutions. A few:
* Auth0
* WorkOS
* AWS Cognito
* FusionAuth (includes self-hosted options)

## How To
Once you have downloaded this template to your local workspace, and have confirmed you have the proper command line tools in place, we're ready to run this! 

### build
Run `make build` from the same directory as the Makefile to build the Lambda functions and to run the initial Terraform commands. Terraform checks for an existing state file, with the current infrastructure state on AWS, and creates a plan for the resources that need to be added, modified or deleted. The Node build step builds and packages the functions for Lambda.

### deploy
Run `make deploy` to execute the Terraform plan, which updates the AWS environment according to the plan created in the 'build' phase.

### build + deploy
Run `make` to run the 'build' command followed immediately by the 'deploy' command. When creating a proof of concept project, often it's good practice to run these commands independent of each other to see what will be changing prior to deployment. There is no confirmation step otherwise.

### destroy
Run `make destroy` to remove all resources from AWS. This step empties the S3 bucket of all files, and then removes all resources created by Terraform during earlier 'deploy' phases. You are prompted twice to confirm that you want to destroy these components  -- the only 'undo' action is to recreate the resources with make build/deploy again. 