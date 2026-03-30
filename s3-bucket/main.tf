resource "aws_s3_bucket" "example_bucket" {
  bucket = var.bucket_name

  tags = {
    Name    = "Dev"
    Project = "Codely Course"
  }
}

resource "aws_s3_object" "object" {
  bucket = aws_s3_bucket.example_bucket.id
  key    = "hello-world"
  source = "hello-world.html"
  content_type = "text/html"
}

locals {
  whitelist_cidrs = ["176.83.52.247/32"]
}

data "aws_iam_policy_document" "bucket_policy" {
  statement {
    effect    = "Allow"
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.example_bucket.arn}/*"]
    
    condition {
      variable = "aws:SourceIP"
      test     = "IpAddress"
      values   = local.whitelist_cidrs 
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