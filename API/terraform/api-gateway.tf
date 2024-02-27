# API Gateway Logs Role/Policy
resource "aws_iam_role" "api_gateway_cloudwatch" {
  name = "ApiGatewayCloudWatchRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "apigateway.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy" "api_gateway_cloudwatch" {
  name = "ApiGatewayCloudWatchPolicy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams",
          "logs:PutLogEvents",
          "logs:GetLogEvents",
          "logs:FilterLogEvents"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "api_gateway_cloudwatch" {
  policy_arn = aws_iam_policy.api_gateway_cloudwatch.arn
  role       = aws_iam_role.api_gateway_cloudwatch.name
}

resource "aws_apigatewayv2_api" "http_api" {
  name          = local.api_name
  protocol_type = "HTTP"
  body = templatefile("${local.parent_directory}/openapi.yml", {
    hello_lambda_invoke      = aws_lambda_function.fn_api.invoke_arn
    authorizer_lambda_invoke = aws_lambda_function.fn_auth.invoke_arn
  })
  cors_configuration {
    allow_credentials = true
    allow_origins     = var.cors_allowed_origins
    allow_methods     = ["POST", "GET", "OPTIONS", "HEAD"]
    allow_headers     = ["content-type", "x-amz-date", "authorization", "x-apigateway-header"]
    expose_headers    = ["content-type", "x-amz-date", "x-apigateway-header"]
    max_age           = 300
  }
}

resource "aws_apigatewayv2_stage" "default_stage" {
  api_id      = aws_apigatewayv2_api.http_api.id
  name        = "api"
  auto_deploy = true

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_gateway_logs.arn
    format = jsonencode({
      requestId               = "$context.requestId"
      sourceIp                = "$context.identity.sourceIp"
      requestTime             = "$context.requestTime"
      protocol                = "$context.protocol"
      httpMethod              = "$context.httpMethod"
      resourcePath            = "$context.resourcePath"
      routeKey                = "$context.routeKey"
      status                  = "$context.status"
      responseLength          = "$context.responseLength"
      integrationErrorMessage = "$context.integrationErrorMessage"
      }
    )
  }
}

# DOMAIN NAME
# Create the API Gateway V2 domain name
resource "aws_apigatewayv2_domain_name" "api" {
  count       = length(aws_acm_certificate.api) > 0 ? 1 : 0
  domain_name = var.domain_name
  domain_name_configuration {
    certificate_arn = aws_acm_certificate.api[0].arn
    security_policy = "TLS_1_2"
    endpoint_type   = "REGIONAL"
  }
}

# attach the domain name to the stage
resource "aws_apigatewayv2_api_mapping" "api" {
  count       = var.domain_name != "" ? 1 : 0
  api_id      = aws_apigatewayv2_api.http_api.id
  domain_name = aws_apigatewayv2_domain_name.api[0].domain_name
  stage       = aws_apigatewayv2_stage.default_stage.name
}

resource "aws_cloudwatch_log_group" "api_gateway_logs" {
  name              = "/aws/apigw/${local.api_name}"
  retention_in_days = 30
}

resource "aws_lambda_permission" "apigw_lambda_api" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.fn_api.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.http_api.execution_arn}/*/*"
}

resource "aws_lambda_permission" "apigw_lambda_auth" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.fn_auth.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.http_api.execution_arn}/*/*"
}

output "base_url" {
  description = "Base URL for our API Gateway Stage"
  value       = aws_apigatewayv2_stage.default_stage.invoke_url
}
