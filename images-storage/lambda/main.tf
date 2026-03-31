resource "aws_lambda_function" "catalog-writer" {
  // If the file is not in the current working directory you will need to include a
  // path.module in the filename.
  filename      = "catalog-writer.zip"
  function_name = "catalog-writer"
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "code.lambda_handler"

  source_code_hash = filebase64sha256("catalog-writer.zip")

  runtime = "python3.9"
}

resource "aws_iam_role" "iam_for_lambda" {
  name = "lambda-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

// dynamodb table Write Policy
data "aws_iam_policy_document" "inline_policy" {
  statement {
    actions = [
      "dynamodb:DeleteItem",
      "dynamodb:DescribeTable",
      "dynamodb:GetItem",
      "dynamodb:GetRecords",
      "dynamodb:ListTables",
      "dynamodb:PutItem",
      "dynamodb:Query",
      "dynamodb:Scan",
      "dynamodb:UpdateItem",
      "dynamodb:UpdateTable",
    ]

    resources = [var.dynamodb_table_arn]

    effect = "Allow"
  }
}

resource "aws_iam_role_policy" "lambda_dynamodb_policy" {
  name   = "policy-dynamodb-writer"
  role   = aws_iam_role.iam_for_lambda.id
  policy = data.aws_iam_policy_document.inline_policy.json
}