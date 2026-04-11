terraform {
  backend "s3" {
    bucket         = "aws-solutions-architect-tf-states"
    key            = "s3-bucket/terraform.tfstate"
    encrypt        = true
    dynamodb_table = "aws-solutions-architect-tf-states-locks"

    #  Configure AWS backend
    # region = "eu-west-1"

    # Configure LocalStack backend
    region            = "us-east-1"
    iam_endpoint      = "http://localhost:4566"
    endpoint          = "http://s3.localhost.localstack.cloud:4566"
    sts_endpoint      = "http://localhost:4566"
    dynamodb_endpoint = "http://localhost:4566"
  }
}
