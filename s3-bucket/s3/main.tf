resource "aws_s3_bucket" "example_bucket" {
  bucket = var.bucket_name

  tags = var.tags
}

resource "aws_s3_object" "object" {
  bucket = aws_s3_bucket.example_bucket.id
  key    = "hello-world"
  source = "hello-world.html"
  content_type = "text/html"
}

data "aws_iam_policy_document" "bucket_policy" {
  statement {
    effect    = "Allow"
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.example_bucket.arn}/*"]
    
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
  bucket = aws_s3_bucket.example_bucket.id
  policy = data.aws_iam_policy_document.bucket_policy.json
}