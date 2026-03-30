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