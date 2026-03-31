init:
	terraform init -reconfigure

zip:
	zip catalog-writer.zip code.py

plan: init zip
	terraform plan

apply: init zip
	terraform apply -auto-approve

destroy: init
	terraform destroy -auto-approve
	rm -rf .terraform .terraform.lock.hcl terraform.tfstate terraform.tfstate.backup catalog-writer.zip