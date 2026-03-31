#tfsec:ignore:aws-s3-enable-bucket-logging
#tfsec:ignore:aws-s3-enable-versioning
resource "aws_s3_bucket" "tf_states_bucket" {
  bucket = var.bucket_name

  force_destroy = true

  tags = {
    Name    = "Dev"
    Project = "AWS Solutions Architect"
  }
}

resource "aws_s3_bucket_public_access_block" "tf_states_bucket_bucket_public_access_block" {
  bucket = aws_s3_bucket.tf_states_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

#tfsec:ignore:aws-kms-auto-rotate-keys
resource "aws_kms_key" "tf_states_bucket_key" {
  description             = "This key is used to encrypt bucket objects"
  deletion_window_in_days = 10
}

resource "aws_s3_bucket_server_side_encryption_configuration" "tf_states_bucket_server_side_encryption_configuration" {
  bucket = aws_s3_bucket.tf_states_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.tf_states_bucket_key.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

data "aws_caller_identity" "current" {}

locals {
  identifiers = [
    "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/jorge",
    "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/laptop"
  ]
}

data "aws_iam_policy_document" "bucket_policy" {
  statement {
    sid    = "AllowListBucket"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = local.identifiers
    }

    actions   = ["s3:ListBucket"]
    resources = [aws_s3_bucket.tf_states_bucket.arn]

    condition {
      variable = "s3:prefix"
      test     = "StringEquals"
      values   = ["${var.bucket_name}"]
    }
  }

  statement {
    sid    = "AllowStateReadWriteObjects"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = local.identifiers
    }

    actions   = ["s3:GetObject", "s3:PutObject"]
    resources = ["${aws_s3_bucket.tf_states_bucket.arn}/*"]
  }

  statement {
    sid    = "AllowStateLockObjects"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = local.identifiers
    }

    actions   = ["s3:GetObject", "s3:PutObject", "s3:DeleteObject"]
    resources = ["${aws_s3_bucket.tf_states_bucket.arn}/*.tflock"]
  }
}

resource "aws_s3_bucket_policy" "main" {
  bucket = aws_s3_bucket.tf_states_bucket.id
  policy = data.aws_iam_policy_document.bucket_policy.json
}

data "aws_iam_policy_document" "dynamodb_policy" {
  statement {
    sid    = "AllowDynamoDBLocking"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = local.identifiers
    }

    actions = [
      "dynamodb:DescribeTable",
      "dynamodb:GetItem",
      "dynamodb:PutItem",
      "dynamodb:DeleteItem"
    ]

    resources = [aws_dynamodb_table.terraform_locks.arn]
  }
}

#tfsec:ignore:aws-kms-auto-rotate-keys
resource "aws_kms_key" "terraform_locks_key" {
  description             = "This key is used to encrypt DynamoDB items"
  deletion_window_in_days = 10
}

#tfsec:ignore:aws-dynamodb-enable-recovery
resource "aws_dynamodb_table" "terraform_locks" {
  name           = var.dynamo_db_name
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "LockID"

  server_side_encryption {
    enabled = true
    kms_key_arn = aws_kms_key.terraform_locks_key.arn  
  }

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name    = "Terraform State Locks"
    Project = "AWS Solutions Architect"
  }
}