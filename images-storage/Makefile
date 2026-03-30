init:
	terraform init -reconfigure

plan: init
	zip catalog-writer.zip code.py
	terraform plan

apply: init
	terraform apply -auto-approve

destroy: init
	terraform destroy -auto-approve
	rm -rf .terraform .terraform.lock.hcl terraform.tfstate terraform.tfstate.backup catalog-writer.zip