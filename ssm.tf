resource "aws_ssm_parameter" "rpc_user" {
  name        = "/bitcoind/${var.alias}/rpc_user"
  description = "rpc_user for bitcoind"
  type        = "SecureString"
  value       = var.rpc_user

  tags = merge(local.common_tags, tomap(
    { Name = "RPC_User-${var.alias}" }
  ))
}

resource "aws_ssm_parameter" "rpc_password" {
  name        = "/bitcoind/${var.alias}/rpc_password"
  description = "rpc_password for bitcoind"
  type        = "SecureString"
  value       = random_password.rpc.result

  tags = merge(local.common_tags, tomap(
    { Name = "RPC_Password-${var.alias}" }
  ))
}