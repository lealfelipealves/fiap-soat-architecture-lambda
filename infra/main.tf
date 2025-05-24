resource "aws_cognito_user_pool" "cpf_pool" {
  name = local.user_pool_name

  lifecycle {
    ignore_changes = [
      schema,
    ]
  }

  schema {
    name                     = "cpf"
    attribute_data_type      = "String"
    required                 = false
    mutable                  = false
    developer_only_attribute = false
  }

  admin_create_user_config {
    allow_admin_create_user_only = true
  }

  username_configuration {
    case_sensitive = false
  }
}

resource "aws_cognito_user_pool_client" "cpf_client" {
  name         = local.user_pool_client_name
  user_pool_id = aws_cognito_user_pool.cpf_pool.id

  generate_secret = false

  explicit_auth_flows = [
    "ALLOW_ADMIN_USER_PASSWORD_AUTH"
  ]

  prevent_user_existence_errors = "ENABLED"
}

resource "aws_iam_role" "lambda_exec" {
  name = local.lambda_exec_role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy" "lambda_cognito" {
  role = aws_iam_role.lambda_exec.name

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Action = [
          "cognito-idp:ListUsers",
          "cognito-idp:AdminCreateUser",
          "cognito-idp:AdminGetUser",
          "cognito-idp:AdminDeleteUser",
          "cognito-idp:AdminUpdateUserAttributes",
          "cognito-idp:AdminInitiateAuth"
        ],
      Resource = aws_cognito_user_pool.cpf_pool.arn
    }]
  })
}

resource "aws_lambda_function" "auth_lambda" {
  filename         = "lambda.zip"
  function_name    = var.lambda_function_name
  role             = aws_iam_role.lambda_exec.arn
  handler          = var.lambda_function_handler
  runtime          = var.lambda_function_runtime
  source_code_hash = filebase64sha256("lambda.zip")

  environment {
    variables = {
      COGNITO_POOL_ID = aws_cognito_user_pool.cpf_pool.id
    }
  }
}

resource "aws_apigatewayv2_api" "cpf_api" {
  name          = local.gateway_name
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_integration" "lambda_integration" {
  api_id                  = aws_apigatewayv2_api.cpf_api.id
  integration_type        = "AWS_PROXY"
  integration_uri         = aws_lambda_function.auth_lambda.invoke_arn
  integration_method      = "POST"
  payload_format_version  = "2.0"
}

resource "aws_apigatewayv2_route" "cpf_route" {
  api_id    = aws_apigatewayv2_api.cpf_api.id
  route_key = "POST /auth"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.cpf_api.id
  name        = "$default"
  auto_deploy = true
}

output "api_endpoint" {
  value = aws_apigatewayv2_api.cpf_api.api_endpoint
}