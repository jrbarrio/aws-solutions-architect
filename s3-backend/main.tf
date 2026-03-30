resource "aws_s3_bucket" "tf_states_bucket" {
  bucket = var.bucket_name

  tags = {
    Name    = "Dev"
    Project = "AWS Solutions Architect"
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

resource "aws_dynamodb_table" "terraform_locks" {
  name           = var.dynamo_db_name
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name    = "Terraform State Locks"
    Project = "AWS Solutions Architect"
  }
}