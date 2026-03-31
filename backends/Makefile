init:
	terraform init -reconfigure

validate: init
	terraform validate
	tfsec . --tfvars-file=terraform.tfvars

plan: validate
	terraform plan

apply: validate
	terraform apply -auto-approve

destroy: init
	terraform destroy -auto-approve
	rm -rf .terraform .terraform.lock.hcl terraform.tfstate terraform.tfstate.backup