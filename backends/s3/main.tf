#tfsec:ignore:aws-s3-enable-bucket-logging
#tfsec:ignore:aws-s3-enable-versioning
resource "aws_s3_bucket" "tf_states_bucket" {
  bucket = var.bucket_name

  force_destroy = true

  tags = var.tags
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

data "aws_iam_policy_document" "bucket_policy" {
  statement {
    sid    = "AllowListBucket"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = var.identifiers
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
      identifiers = var.identifiers
    }

    actions   = ["s3:GetObject", "s3:PutObject"]
    resources = ["${aws_s3_bucket.tf_states_bucket.arn}/*"]
  }

  statement {
    sid    = "AllowStateLockObjects"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = var.identifiers
    }

    actions   = ["s3:GetObject", "s3:PutObject", "s3:DeleteObject"]
    resources = ["${aws_s3_bucket.tf_states_bucket.arn}/*.tflock"]
  }
}

resource "aws_s3_bucket_policy" "main" {
  bucket = aws_s3_bucket.tf_states_bucket.id
  policy = data.aws_iam_policy_document.bucket_policy.json
}