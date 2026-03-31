resource "aws_s3_bucket" "images_bucket" {
  bucket = var.bucket_name

  tags = var.tags
}

data "aws_iam_policy_document" "bucket_policy" {
  statement {
    effect    = "Allow"
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.images_bucket.arn}/*"]
    
    condition {
      variable = "aws:SourceIP"
      test     = "IpAddress"
      values   = var.whitelist_cidrs 
    }
    
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
  }
}

resource "aws_s3_bucket_policy" "main" {
  bucket = aws_s3_bucket.images_bucket.id
  policy = data.aws_iam_policy_document.bucket_policy.json
}

resource "aws_lambda_permission" "allow_bucket" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = var.catalog-writer-arn
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.images_bucket.arn
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.images_bucket.id

  lambda_function {
    lambda_function_arn = var.catalog-writer-arn
    events              = ["s3:ObjectCreated:*"]
    filter_suffix       = ".png"
  }

  depends_on = [aws_lambda_permission.allow_bucket]
}
