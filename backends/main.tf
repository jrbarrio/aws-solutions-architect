data "aws_caller_identity" "current" {}

locals {
  identifiers = [
    "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/jorge",
    "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/laptop"
  ]

  tags = {
    Name    = "Dev"
    Project = "AWS Solutions Architect"
  }
}

module "s3" {
  source = "./s3"

  bucket_name = var.bucket_name
  identifiers = local.identifiers
  tags = local.tags
}

module "dynamodb" {
  source = "./dynamodb"

  dynamo_db_name = var.dynamo_db_name
  identifiers = local.identifiers
  tags = local.tags
}

