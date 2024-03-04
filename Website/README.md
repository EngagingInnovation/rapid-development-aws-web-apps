# Host React Web Application on AWS Using CloudFront and S3

## What does this do?
This template lets us quickly build the AWS resources needed to host a React website. This template is focused on two primary components; an AWS CloudFront resource to handle the HTTP protocols and caching, and an S3 bucket to hold the static web files (HTML, CSS, and Javascript). 

## What is being created?
Without any additional configuration, and assuming all the command line [dependencies](../README.md#dependencies) are in place, running the `make` command will create these 4 resources in your AWS account

1. CloudFront Distribution - this is the front door to the application. All incoming HTTP requests hit this resource first
2. S3 Bucket - a private bucket, this is where we put all of our static React web content.
3. IAM Policy - allows the CloudFront distro to use the private S3 bucket as the origin for the website 
4. CloudFront Origin Access Control - defines the way in which CloudFront will read the files from the S3 bucket. 

The `make` process will also build your React app using the common node building tools, then push the static files (index.html, css, javascript, and others) into the newly created S3 bucket. And that's it, voila, website! \*

\* one caveat: it can take UP TO 25 MINUTES for the initial creation of the CloudFront distribution to get pushed to all of the edge locations needed to actually serve your site. In my own experience, it's less than 5 minutes, but be patient as it may take longer. 

### React and caching 
The magic with CloudFront is its function as a web cache. When web resources are held within the cache, CloudFront doesn't need to check in with the origin (the S3 bucket) until the Time To Live (TTL) has expired. This makes the website feel extra snappy when the files are returned from memory in only a few milliseconds. With React, we can set really long TTL values on the cache (like 24 hours or longer) because any time we rebuild our React app, the application files will be rebuilt with new names. Since the new files are not yet in the cache, CloudFront will call the S3 origin for the newly requested file - no need to invalidate the cache, since the cache doesn't know about these files. There is one exception that needs to be handled. The root website file is named `index.html` and will not change file names between builds. So, depending on how often you build your site or how quickly you want to see your changes reflected, we'd need to set our TTL so that its much shorter. In this template, we set the default to 1 second for the path `/index.html`

Another React specific CloudFront configuration has been made for common error pages. For the HTTP errors `403` and `404`, we have our root document `/index.html` handle the request. The reason for this is that Single Page Apps (SPA) will often create URLs that appear to request resources on the server that don't exist. A request made to `/home/about-us` would have CloudFront check the S3 origin for a resource located exactly at 's3://\<your-bucket\>/home/about-us'. If that doesn't exist, CloudFront would return a 404 to be captured by React and then used to generate a page using code from within the browser.  

### bucket name 
Domain names need to be globally unique. S3 bucket names also need to be globally unique. So, when you pass a `domain_name` variable, Terraform will attempt to create an S3 bucket with the unique name of the domain you are using to host the React web files. Without the 'domain_name' var, this template will create a bucket with a unique name for you. You can override this logic and provide the name of the bucket that should be created using a Terraform variable if you wish. 

### domain name
Make sure to check the [README in the parent directory](../README.md#custom-domains-for-each-template) for further information about attaching a custom domain name to this project. If you happen to be creating a website for a domain that doesn't include a sub-domain, there is a variable you can set to add 'www' as a secondary alias to your website. 

### logging
For this template, we are _not_ creating logs. CloudFront does provide a hook for logging. The logs are written to an S3 bucket. There isn't a convenient way to read these files in real-time without creating a lot of additional component parts. For a development or testing phase, a system could be built that forwards the logs from S3 into a CloudWatch Logging group, in which the logs could then be read and searched conveniently. Once a project gets into a production stage, often there are enterprise systems like Splunk, Data Dog or other observability tools that come into play. 

## How To
Once you have downloaded this template to your local workspace, and have confirmed you have the proper command line tools in place, we're ready to run this! Using the Command Line / Terminal application on your computer, locate the this directory (specifically the one that includes the Makefile) and you can execute the following commands.

### build
Run `make build` to compile the React website and to run the initial Terraform commands. Terraform checks for an existing state file, with the current infrastructure state on AWS, and creates a plan for the resources that need to be added, modified or deleted. The React build compiles the components into web optimized files, complete with proper linking between files. 

### deploy
Run `make deploy` to execute the Terraform plan, which updates the AWS environment according to the plan created in the 'build' phase. This deploy step also pushes the React web files into the S3 bucket

### build + deploy
Run `make` to run the 'build' command followed immediately by the 'deploy' command. When creating a proof of concept project, often it's good practice to run these commands independent of each other to see what will be changing prior to deployment. There is no confirmation step otherwise.

### destroy
Run `make destroy` to remove all resources from AWS. This step empties the S3 bucket of all files, and then removes all resources created by Terraform during earlier 'deploy' phases. You are prompted twice to confirm that you want to destroy these components -- the only 'undo' action is to recreate the resources with make build/deploy again. 

### local web development
Run `cd web`, followed by `npm run start` to test your React website from localhost during development. 

