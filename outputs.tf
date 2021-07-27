output "bitcoind_priv_dns" {
  value = aws_instance.i.private_dns
}
output "instance" {
  value = aws_instance.i
}
output "bitcoind_access_sg" {
  value = aws_security_group.rpc_zmq_access.id
}
