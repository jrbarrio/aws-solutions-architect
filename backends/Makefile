init:
	terraform init -reconfigure

plan: init
	terraform plan

apply: init
	terraform apply -auto-approve

destroy: init
	terraform destroy -auto-approve
	rm -rf .terraform .terraform.lock.hcl terraform.tfstate terraform.tfstate.backup