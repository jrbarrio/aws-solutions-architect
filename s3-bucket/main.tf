locals {
  whitelist_cidrs = ["176.83.52.247/32"]

  tags = {
    Name    = "Dev"
    Project = "Codely Course"
  }  
}

module "s3" {
  source = "./s3"

  bucket_name = var.bucket_name
  whitelist_cidrs = local.whitelist_cidrs
  tags = local.tags
}