variable "user_pool_name" {
  type        = string
  description = "O nome do pool de usuários"
  default     = "${var.prefix}-user-pool"
}

variable "user_pool_client_name" {
  type        = string
  description = "The name of the user pool client"
  default     = "${var.prefix}-app-client"
}

variable "lambda_exec_role_name" {
  type        = string
  description = "The secret of the user pool client"
  default     = "${var.prefix}-lambda-role"
}

variable "lambda_function_name" {
  type        = string
  description = "The name of the lambda function"
  default     = "authCpfLambda"
}

variable "lambda_function_handler" {
  type        = string
  description = "The handler of the lambda function"
  default     = "handler.hello"
}

variable "lambda_function_runtime" {
  type        = string
  description = "The runtime of the lambda function"
  default     = "nodejs22.x"
}

variable "gateway_name" {
  type        = string
  description = "The name of the gateway"
  default     = "${var.prefix}-gateway"
}