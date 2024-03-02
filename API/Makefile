AWS_PROFILE_ENV=default
-include .makerc

all: build deploy

build: build_js terraform_plan

deploy: terraform/tfplan
	cd terraform && AWS_PROFILE=${AWS_PROFILE_ENV} terraform apply -input=false tfplan 
	cd terraform && AWS_PROFILE=${AWS_PROFILE_ENV} terraform output -json > tfoutput.json
	rm terraform/tfplan

destroy:
	@echo "Destroys this project on AWS. Proceed? [y/N] " && read ans && [ $${ans:-N} = y ]
	cd terraform && AWS_PROFILE=${AWS_PROFILE_ENV} terraform apply -destroy

build_lambda_js: fn-*/package.json
	cd fn-api/ && \
		npm install && \
		npm run build
	cd fn-auth/ && \
		npm install && \
		npm run build

terraform_plan: terraform/*.tf
	cd terraform && AWS_PROFILE=${AWS_PROFILE_ENV} terraform init -input=false
	cd terraform && AWS_PROFILE=${AWS_PROFILE_ENV} terraform plan -out=tfplan -input=false


.PHONY: all build deploy destroy terraform_plan build_lambda_js