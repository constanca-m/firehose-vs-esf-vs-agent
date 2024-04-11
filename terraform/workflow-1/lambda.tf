data "aws_iam_policy_document" "lambda_policy_role_document" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "lambda_role" {
  name               = "${var.resource_name_prefix}-lambda-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_policy_role_document.json
}

data "aws_iam_policy_document" "lambda_policy_permissions_document" {
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject",
    ]
    resources = [
      aws_s3_bucket.s3_bucket_cloudfront_logs.arn,
      "${aws_s3_bucket.s3_bucket_cloudfront_logs.arn}/*",
    ]
  }
}

resource "aws_iam_policy" "lambda_permissions_policy" {
  name   = "${var.resource_name_prefix}-lambda-policy"
  policy = data.aws_iam_policy_document.lambda_policy_permissions_document.json
}

resource "aws_iam_role_policy_attachment" "lambda_permissions" {
  policy_arn = aws_iam_policy.lambda_permissions_policy.arn
  role       = aws_iam_role.lambda_role.name
}

data "archive_file" "lambda_code" {
  type = "zip"

  source_dir  = "${path.module}/lambda-code"
  output_path = "${path.module}/lambda-code.zip"
}

resource "aws_lambda_function" "lambda_function" {
  function_name = "${var.resource_name_prefix}-lambda"
  role          = aws_iam_role.lambda_role.arn
  runtime       = "python3.8"
  filename      = "${path.module}/lambda-code.zip"
  handler       = "lambda.lambda_handler"
}

resource "aws_lambda_permission" "allow_bucket" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_function.arn
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.s3_bucket_cloudfront_logs.arn
}

