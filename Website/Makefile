AWS_PROFILE_ENV=default
-include .makerc

all: build deploy

build: build_js terraform_plan

deploy: terraform/tfplan
	cd terraform && AWS_PROFILE=${AWS_PROFILE_ENV} terraform apply -input=false tfplan 
	cd terraform && AWS_PROFILE=${AWS_PROFILE_ENV} terraform output -json > tfoutput.json
	BUCKET=$$(jq -r '.s3_bucket_id.value' terraform/tfoutput.json); \
	AWS_PROFILE=${AWS_PROFILE_ENV} \
	aws s3 sync web/build "s3://$${BUCKET}"
	rm terraform/tfplan
	@URL=$$(jq -r '.web_url.value' terraform/tfoutput.json); \
	echo "Visit $${URL} to see your site. It may take up to 25 minutes to be accessible after initial deployment."

destroy:
	@echo "Destroys this project on AWS. Proceed? [y/N] " && read ans && [ $${ans:-N} = y ]
	BUCKET=$$(jq -r '.s3_bucket_id.value' terraform/tfoutput.json); \
	AWS_PROFILE=${AWS_PROFILE_ENV} \
	aws s3api delete-objects \
  	--bucket $${BUCKET} \
  	--delete "$$(aws s3api list-object-versions \
  	--bucket "$${BUCKET}" \
	--profile ${AWS_PROFILE_ENV} \
  	--output=json \
  	--query='{Objects: Versions[].{Key:Key,VersionId:VersionId}}' | jq '. + {"Quiet": true}')"
	cd terraform && AWS_PROFILE=${AWS_PROFILE_ENV} terraform apply -destroy

build_js: web/package.json
	cd web/ && \
		npm install && \
		npm run build

terraform_plan: terraform/*.tf
	cd terraform && AWS_PROFILE=${AWS_PROFILE_ENV} terraform init -input=false
	cd terraform && AWS_PROFILE=${AWS_PROFILE_ENV} terraform plan -out=tfplan -input=false

.PHONY: all build deploy destroy terraform_plan build_js
