.PHONY: all build deploy destroy terraform_plan build_lambda_js

all: build deploy

build:
	$(MAKE) build_lambda_js
	$(MAKE) terraform_plan

deploy: terraform/tfplan
	cd terraform && terraform apply -input=false tfplan 
	cd terraform && terraform output -json > tfoutput.json
	rm terraform/tfplan

destroy:
	@echo "Destroys this project on AWS. Proceed? [y/N] " && read ans && [ $${ans:-N} = y ]
	cd terraform && terraform apply -destroy

build_lambda_js: fn-*/package.json
	cd fn-api/ && \
		npm install && \
		npm run build
	cd fn-auth/ && \
		npm install && \
		npm run build

terraform_plan: terraform/*.tf
	cd terraform && terraform init -input=false
	cd terraform && terraform plan -out=tfplan -input=false