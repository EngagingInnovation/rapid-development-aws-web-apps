.PHONY: all build deploy destroy terraform_plan build_js

all: build deploy

build:
	$(MAKE) build_js
	$(MAKE) terraform_plan

deploy: terraform/tfplan
	cd terraform && terraform apply -input=false tfplan 
	cd terraform && terraform output -json > tfoutput.json
	BUCKET=$$(jq -r '.s3_bucket_id.value' terraform/tfoutput.json); \
	aws s3 sync web/build "s3://$${BUCKET}"
	rm terraform/tfplan
	@URL=$$(jq -r '.web_url.value' terraform/tfoutput.json); \
	echo "Visit $${URL} to see your site. It may take up to 25 minutes to be accessible"

destroy:
	@echo "Destroys this project on AWS. Proceed? [y/N] " && read ans && [ $${ans:-N} = y ]
	BUCKET=$$(jq -r '.s3_bucket_id.value' terraform/tfoutput.json); \
	aws s3api delete-objects \
  	--bucket $${BUCKET} \
  	--delete "$$(aws s3api list-object-versions \
  	--bucket "$${BUCKET}" \
  	--output=json \
  	--query='{Objects: Versions[].{Key:Key,VersionId:VersionId}}' | jq '. + {"Quiet": true}')"
	cd terraform && terraform apply -destroy

build_js: web/package.json
	cd web/ && \
		npm install && \
		npm run build

terraform_plan: terraform/*.tf
	cd terraform && terraform init -input=false
	cd terraform && terraform plan -out=tfplan -input=false