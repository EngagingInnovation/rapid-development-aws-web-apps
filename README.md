# Rapid Development Starter Templates for Online Apps
This guide introduces a set of starter templates designed to streamline the process of web-based project development, deployed to AWS. By leveraging these templates, engineering teams can bypass the repetitive setup tasks and dive straight into what truly matters: innovation! 

## Why use these templates?
These starter templates serve as the foundational building blocks for new infrastructure. They are opinionated, designed with specific tools and platforms, like Terraform and serverless resources on AWS. These allow you to:

* **Accelerate Development**: Jump past boilerplate code and configuration to focus on developing the core functionalities of each unique application
* **Ensure Best Practices**: Designed with best practices in mind, ensuring your project is set up for success from the start

Each template in this series is created to address the common needs of web-based projecs while remaining flexible enough to accommodate your project's specific requirements. Highlights include:

* Pre-configured AWS environments, including essential services such as Lambda, API Gateway, Cloudfront, and IAM Roles and Policies
* Sample code and detailed instructions in each sub-project for customizing and extending the templates to fit your project needs
* Strategies for implementing authentication, logging and best practices for security and scalability

## Getting started
To begin with, ensure you have the necessary [dependencies](#dependencies) installed. Then, follow the step-by-step instructions provided within each template (in the How To section of the README.md files) to deploy your AWS infrastructure and start focusing on your unique application. 

### Website
The `Website` directory includes code for deploying a React-based website on AWS cloud. This sub-project is designed to host your front-end, built with the popular React.js library, through AWS CloudFront - a fast, highly secure, and programmable CDN. Every bit of code is fully customizable to your needs, ensuring that your website aligns with your project's look and feel, functionality, and branding. For instructions on deploying and customizing the template, refer to the [README.md](./Website/README.md) file within the `Web` directory.

### API
The `API` directory encompasses code tailored to deploy an API Gateway that interfaces with AWS Lambda functions, acting as the backbone of your back-end infrastructure. It features pre-configured settings streamlined for setting up serverless APIs, reducing the time spent on configurations and coding. Additional code and instructions in the API sub-project come pre-configured with a BasicAuth, providing a degree of access control to the API. 

### Can we combine project templates?
Yes! These two template projects can be combined into a single project that includes both the code and AWS resources to have a frontend React web application hosted with CloudFront and also a backend component fronted by API Gateway. The resources defined in the terraform files between projects are independently named such that they could live within the same terraform project without much reconfiguration. 

## Custom Domains for Each Template 
### domain name
If you want to attach a domain name to your website, this can achieved through Terraform configuration variables. There are a number of configuration variables that can be set (see the file `terraform/variables.tf` in each sub-project to see what can be configured). The most commonly set variable would be for `domain_name`. When this is set (in concert with a `hostedzone_id`), an additional 5 AWS resources will be created to connect the domain name to CloudFront.

1. Route53 "A" Record - for your requested domain name
2. Route53 Validation - two records to validate that you control the domain name, using CNAME
3. ACM Certificate - a certificate to serve your domain from https
4. ACM Cert Validation - check that you can create the cert for this domain name 

### bring your own Hosted Zone 
If you are building with a domain name, you must first create an AWS Route53 Hosted Zone in your account. This isn't done automatically in this Terraform template. Typically the type of data you need to create a Hosted Zone is coordinated between a domain name registrar and includes Name Space (NS) records that have values that can only be derived from the registrar. AWS has its own registrar, which is pretty convenient. However, if you wanted to create a new domain name with AWS, you have a one-time payment required for the registration which is beyond the scope of this particular starter kit. Once you have the Route53 Hosted Zone Id at the ready, this template project will create the A records and CNAME records as part of the build processes. 

## Dependencies
This project is built with the assumption that there are common command line tools already available on your machine or environment. Please ensure that you've installed these dependencies before running this project for the first time.

### [AWS account](https://aws.amazon.com)
First and foremost, without an AWS account, this project goes nowhere. And, in order to push the changes from your machine to AWS, you need to have AWS credentials (typically an Access Key and Secret Key) available to the application. These credentials can be created in your AWS account and are often stored in a common location like `~/.aws/config` or `~/.aws/credentials`. For simplicity, without additional configuration this template is reads the defaults for these key and secret values. You can read more about setting up your credentials using the AWS command line tool [here](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-files.html).

### [aws cli](https://aws.amazon.com/cli/) 
The AWS command line tool is used in this project to sync the files from the local drive to the S3 bucket during the deploy phase of the Web project. During the destroy phase, it is used to empty the bucket of all files prior to the Terraform command that deletes the bucket on AWS. 

### [jq](https://jqlang.github.io/jq/) 
Infrastructure state is shared between Terraform and AWS using encoded json objects. The command line tool `jq` is used to pull those state values out and provide minor modifications where needed.

### [make](https://www.gnu.org/software/make/)
Make has been used as an aid to compile software for years. In this template, it's being used for build orchestration between multiple language tool sets, like a wrapper for simple one-line shell commands. The Makefile includes some file checks to prevent deploying code before it's been built. 

### [node](https://nodejs.org/en/download/current)
The Web template uses a React website, which is built using Node.js. This was built and tested with Node version 21, but would likely work with older versions as well. The API template creates Lambda functions written in Typescript that also use Node tools for compiling and optimization. 

### [terraform](https://developer.hashicorp.com/terraform/install)
My teams have been using Terraform to manage AWS resources for years. In the time since Terraform arrived, there have been other Infrastructure as Code applications available, including a couple from AWS (CDK, SAM). There are times the Terraform syntax can feel constraining, but because it's been around so long there is plenty of example code on the web to help work around the road blocks.

### bash
This was built and tested with Bash. I'm sure there are syntax differences with the Z Shell, but I haven't looked. 

## Next Steps
If you wanted to take this a step further, beyond just a proof of concept, here are some considerations on your path towards productionization. 

### continuous integration
Apps like Jenkins and features like GitHub Actions and GitLab Runners can listen for events in the git lifecycle. Upon check-in of your code, a continuous integration process could execute the proper Make steps and depending on the AWS environment settings, can deploy the changes to the proper runtime environments, such as those for testing or Production. 

### logging
Some logs are captured in the API sub-project for the two Lambda functions as well as access logs for the API Gateway. The Web sub-project could be configured to capture logs from CloudFront, but would require more work. Even small projects like these can benefit from strategic logging. Properly implemented logging can improve error tracking during development, and once deployed can offer insights into user behavior, and enhance security measures. 

### alerting 
With AWS CloudWatch, you can create "Alarms" which trigger based on metrics like error rates or response times. These alarms can be tied directly to services like SNS (Simple Notification Service) to notify your team via email, SMS, or even trigger AWS Lambda functions for automated responses.

If you have implemented AWS X-Ray in your application, it also provides useful insights into the behavior of your application, helping in understanding how requests are handled and where bottlenecks are originating. With X-Ray, you can set up anomaly detection to get alerted when irregularities are noticed.

### testing
React provides various tools for local unit testing. These test hooks could even be built into the build phase. If the automated test were to fail, the build operation could halt until the bugs were fixed. Often React will read in data from APIs, and during integration testing, there could be additional tests with mock data to confirm the site will work. 

### security
Security checks should be done during early parts of application development. AWS (configured through Terraform) can provide extremely narrow access controls via policy documents, IAM roles, and principles. In the same way you would do a code review, an independent team should analyze your code and Terraform for access vulnerabilities.

### terraform state in S3
In this template, the Terraform state is stored in a local directory. When this project is shared with a team or when deployment is controlled by a Continuous Integration process, the state should be stored in a central place. A bucket in S3 makes sense for this purpose. I'd suggest a generic team bucket like `<company>-<dept>-tfstate`, and then sub folders with the name of the project and environment like `/<project-name>/<env>/terraform.tfstate`. 

Once in place, the terraform block can be modified like this, in the file `terraform/main.tf` 
```hcl
terraform {
   backend "s3" {
     bucket  = "mycompany-sales-tfstate"
     key     = "support/sales-tracker/test/terraform.tfstate"
     region  = var.aws_region
     encrypt = true
   }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
```

## Contributing to Innovation
Collaboration is key to innovation. If you have suggestions for improving these templates or wish to share how you've used them to accelerate your projects, please reach out or submit a pull request. It's exciting to make these resources even more beneficial for the engineering community. Let's innovate swiftly and smartly. Dive into the templates now and transform your ideas into reality!