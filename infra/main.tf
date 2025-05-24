resource "aws_cognito_user_pool" "cpf_pool" {
  name = var.user_pool_name

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
  name         = var.user_pool_client_name
  user_pool_id = aws_cognito_user_pool.cpf_pool.id

  generate_secret = false

  explicit_auth_flows = [
    "ALLOW_ADMIN_USER_PASSWORD_AUTH"
  ]

  prevent_user_existence_errors = "ENABLED"
}
