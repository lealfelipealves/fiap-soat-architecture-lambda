variable "user_pool_name" {
  type        = string
  description = "O nome do pool de usuários"
  default     = "fiap-user-pool"
}

variable "user_pool_client_name" {
  type        = string
  description = "The name of the user pool client"
  default     = "fiap-app-client"
}