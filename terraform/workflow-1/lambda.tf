data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "iam_for_lambda" {
  name               = "${var.resource_name_prefix}-lambda-s3-kinesis"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

data "aws_iam_policy_document" "lambda_policy_permissions_document" {
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["arn:aws:logs:*:*:*"]
  }

  statement {
    effect  = "Allow"
    actions = ["s3:GetObject"]
    resources = [
      aws_s3_bucket.s3_bucket_cloudfront_logs.arn,
      "${aws_s3_bucket.s3_bucket_cloudfront_logs.arn}/*",
    ]
  }

  statement {
    effect    = "Allow"
    actions   = ["firehose:PutRecord"]
    resources = [var.firehose_arn]
  }
}

resource "aws_iam_policy" "lambda_permissions_policy" {
  name   = "${var.resource_name_prefix}-lambda-policy"
  policy = data.aws_iam_policy_document.lambda_policy_permissions_document.json
}

resource "aws_iam_role_policy_attachment" "lambda_permissions" {
  policy_arn = aws_iam_policy.lambda_permissions_policy.arn
  role       = aws_iam_role.iam_for_lambda.name
}

resource "aws_lambda_permission" "allow_bucket" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.function.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.s3_bucket_cloudfront_logs.arn
}

# For the function logs
resource "aws_cloudwatch_log_group" "function_logs" {
  name              = "/aws/lambda/${aws_lambda_function.function.function_name}"
  retention_in_days = 14
}

resource "aws_lambda_function" "function" {
  filename      = "${path.module}/lambda.zip"
  function_name = "${var.resource_name_prefix}-function"
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "lambda.lambda_handler"
  runtime       = "python3.9"
}


