# zip file our our local Node lambda app code
data "archive_file" "lambda_api_zip" {
  type        = "zip"
  source_dir  = "${local.parent_directory}/fn-api/dist"
  output_path = "${path.module}/deploy/function-api-lambda.zip"
}

data "archive_file" "lambda_auth_zip" {
  type        = "zip"
  source_dir  = "${local.parent_directory}/fn-auth/dist"
  output_path = "${path.module}/deploy/function-auth-lambda.zip"
}

# Lambda Role + Policies + Code
# Role
resource "aws_iam_role" "lambda_api_role" {
  name = "LambdaAPIRole${local.app_env}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

# Policy
data "aws_iam_policy_document" "lambda_api_policy" {
  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    effect = "Allow"
    resources = [
      "${aws_cloudwatch_log_group.lambda_log_auth.arn}*",
      "${aws_cloudwatch_log_group.lambda_logs_api.arn}*",
    ]
  }
}

# Attach Policy to Role
resource "aws_iam_role_policy" "lambda_api_role_policy" {
  role   = aws_iam_role.lambda_api_role.id
  policy = data.aws_iam_policy_document.lambda_api_policy.json
}


# Lambda: Content for API
resource "aws_lambda_function" "fn_api" {
  function_name = "${var.lambda_api_name}-${local.app_env}"
  handler       = "index.handler"
  runtime       = "nodejs20.x"
  role          = aws_iam_role.lambda_api_role.arn
  architectures = ["arm64"]

  filename         = data.archive_file.lambda_api_zip.output_path
  source_code_hash = data.archive_file.lambda_api_zip.output_base64sha256

  timeout = 30
}

# Lambda: Auth for API
resource "aws_lambda_function" "fn_auth" {
  function_name = "${var.lambda_auth_name}-${local.app_env}"
  handler       = "index.handler"
  runtime       = "nodejs20.x"
  role          = aws_iam_role.lambda_api_role.arn
  architectures = ["arm64"]

  environment {
    variables = {
      "ALLOWED_USERS" = var.auth_allowed_users
    }
  }

  filename         = data.archive_file.lambda_auth_zip.output_path
  source_code_hash = data.archive_file.lambda_auth_zip.output_base64sha256

  timeout = 30
}

# CloudWatch Log Groups
resource "aws_cloudwatch_log_group" "lambda_logs_api" {
  name              = "/aws/lambda/${var.lambda_api_name}-${local.app_env}"
  retention_in_days = 30
}

resource "aws_cloudwatch_log_group" "lambda_log_auth" {
  name              = "/aws/lambda/${var.lambda_auth_name}-${local.app_env}"
  retention_in_days = 30
}
