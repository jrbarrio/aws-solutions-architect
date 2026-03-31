data "aws_iam_policy_document" "dynamodb_policy" {
  statement {
    sid    = "AllowDynamoDBLocking"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = var.identifiers
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

  tags = var.tags
}