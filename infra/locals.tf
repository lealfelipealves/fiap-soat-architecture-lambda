locals {
  user_pool_name        = "${var.prefix}-user-pool"
  user_pool_client_name = "${var.prefix}-app-client"
  lambda_exec_role_name = "${var.prefix}-lambda-role"
  gateway_name          = "${var.prefix}-gateway"
}