locals {
  whitelist_cidrs = ["176.83.52.247/32"]

  tags = {
    Name    = "Dev"
    Project = "Images Storage"
  }
}

module "s3" {
  source = "./s3"

  bucket_name = var.bucket_name
  whitelist_cidrs = local.whitelist_cidrs
  catalog-writer-arn = module.lambda.catalog-writer-arn
  tags = local.tags
}

module "dynamodb" {
  source = "./dynamodb"

  dynamodb_name = var.dynamodb_name
  tags = local.tags
}

module "lambda" {
  source = "./lambda"

  bucket_name = var.bucket_name
  dynamodb_table_id = module.dynamodb.dynamodb_table_id
  dynamodb_table_arn = module.dynamodb.dynamodb_table_arn
  tags = local.tags
}