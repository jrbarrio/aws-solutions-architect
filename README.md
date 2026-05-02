# tfenv
Follow mannual installation instructions from: https://github.com/tfutils/tfenv.

Execute:

```
tfenv install latest
echo "1.14.8" > .terraform-version
terraform version
```

Install AWS Terraform provider: https://registry.terraform.io/providers/hashicorp/aws/latest

```
cd s3-bucket
make plan
make apply

make destroy
```

# tfsec

Install tfsec from https://github.com/aquasecurity/tfsec

# infracost

Install following instructions at https://oneuptime.com/blog/post/2026-01-26-infracost-iac-cost/view

# Localstack

Examples can be deployed on you AWS account or locally with Localstack.
Just select the right provider configuration on `provider.tf`.

If you areworking with Localstack, start the Lockalstack docker image:
```
docker compose start
```