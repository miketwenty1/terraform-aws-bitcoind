# resource "random_string" "name_nonce" {
#   count   = var.ephemeral_name_nonce ? 1 : 0
#   length  = 5
#   special = false
#   upper   = false
#   number  = false
# }

resource "random_password" "rpc" {
  length  = 21
  special = false
  upper   = true
  number  = true
}
