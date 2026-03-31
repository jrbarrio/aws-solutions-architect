init:
	terraform init -reconfigure

validate: init
	terraform validate
	tfsec . --tfvars-file=terraform.tfvars

cost:
	infracost breakdown --path . --terraform-plan-flags="-var-file=terraform.tfvars"

plan: validate cost
	terraform plan

apply: validate
	terraform apply -auto-approve

destroy: init
	terraform destroy -auto-approve
	rm -rf .terraform .terraform.lock.hcl terraform.tfstate terraform.tfstate.backup