.PHONY: all plan apply destroy

all: help

export AWS_PROFILE := iesawsna-sandbox
export ENV := dev
export BACKEND_CONFIG := ../backend-config/${ENV}.tfvars
export TFVARS := ../env-config/${ENV}.tfvars
export AWS_DEFAULT_REGION := us-east-1
export S3_BUCKET := terraform-state-fuse-dev-bucket
export DYNAMODB_TABLE := terraform-dev-statelock 

# Add the following 'help' target to your Makefile
# And add help text after each target name starting with '\#\#'
help:			## Show this help
	@fgrep -h "##" $(MAKEFILE_LIST) | fgrep -v fgrep | sed -e 's/\\$$//' | sed -e 's/##//'

clean:			## clean
	@echo "[INFO] Make Clean"
	rm -rf .terraform
.PHONY: clean

deploy-terraform:	 get fmt init validate plan refresh apply output	## Deploy Terraform.
	@echo "[INFO] Deploying Terraform"
.PHONY: get fmt init validate plan refresh apply output

get:			## Get the Terraform modules.
	@echo "[INFO] Geting Terraform modules"
	terraform get
.PHONY: get

fmt:			## Format Terraform configuration files.
	@echo "[INFO] Formatting terraform configuration files"
	terraform fmt
.PHONY: fmt

init:			## Initialize remote S3 backend.cd 
	@echo "[INFO] Initiliazing remote state management"
	terraform init -backend-config ${BACKEND_CONFIG}
.PHONY: init

validate:		## Validate Terraform configuration.
	@echo "[INFO] Validating terraform configuration files"
	terraform validate
.PHONY: validate

plan:			## Plan changes to infrastructure.
	@echo "[INFO] Planning changes to infrastructure"
	terraform plan -var-file=${TFVARS}
.PHONY: plan

refresh:		## Refresh the remote state with existing AWS infrastructure.
	@echo "[INFO] Refreshing remote state file with existing AWS infrastructure"
	terraform refresh -var-file=${TFVARS}
.PHONY: refresh

apply:			## Apply the changes in plan.
	@echo "[INFO] Applying changes"
	terraform apply -var-file=${TFVARS}
.PHONY: apply

output:			## See the output.
	@echo "[INFO] See output"
	terraform output -json
.PHONY: output

destroy:		## Destroy the infrastructure.
	@echo "[INFO] Destroying infrastructure"
	terraform destroy -var-file=${TFVARS}
.PHONY: destroy

destroy-backend: ## Destroy S3 bucket and DynamoDB table
	@if ! aws --profile $(AWS_PROFILE) dynamodb delete-table \
		--region $(REGION) \
		--table-name $(DYNAMODB_TABLE) > /dev/null 2>&1 ; then \
			echo "$(BOLD)$(RED)Unable to delete DynamoDB table $(DYNAMODB_TABLE)$(RESET)"; \
	 else
		echo "$(BOLD)$(RED)DynamoDB table $(DYNAMODB_TABLE) does not exist.$(RESET)"; \
	 fi
	@if ! aws --profile $(AWS_PROFILE) s3api delete-objects \
		--region $(REGION) \
		--bucket $(S3_BUCKET) \
		--delete "$$(aws --profile $(AWS_PROFILE) s3api list-object-versions \
						--region $(REGION) \
						--bucket $(S3_BUCKET) \
						--output=json \
						--query='{Objects: Versions[].{Key:Key,VersionId:VersionId}}')" > /dev/null 2>&1 ; then \
			echo "$(BOLD)$(RED)Unable to delete objects in S3 bucket $(S3_BUCKET)$(RESET)"; \
	 fi
	@if ! aws --profile $(AWS_PROFILE) s3api delete-objects \
		--region $(REGION) \
		--bucket $(S3_BUCKET) \
		--delete "$$(aws --profile $(AWS_PROFILE) s3api list-object-versions \
						--region $(REGION) \
						--bucket $(S3_BUCKET) \
						--output=json \
						--query='{Objects: DeleteMarkers[].{Key:Key,VersionId:VersionId}}')" > /dev/null 2>&1 ; then \
			echo "$(BOLD)$(RED)Unable to delete markers in S3 bucket $(S3_BUCKET)$(RESET)"; \
	 fi
	@if ! aws --profile $(AWS_PROFILE) s3api delete-bucket \
		--region $(REGION) \
		--bucket $(S3_BUCKET) > /dev/null 2>&1 ; then \
			echo "$(BOLD)$(RED)Unable to delete S3 bucket $(S3_BUCKET) itself$(RESET)"; \
	 fi
.PHONY: destroy-backend

all: create-dynamodb get fmt init validate plan refresh apply output		## Run all
.PHONY: create-dynamodb get fmt init validate plan refresh apply output