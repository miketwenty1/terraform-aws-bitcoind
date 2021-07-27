resource "aws_eip" "i" {
  count = var.enable_external_ip == null ? 1 : 0
  vpc                       = true
  associate_with_private_ip = aws_instance.i.private_ip
  tags = merge(local.common_tags,tomap(
    { Name = "${var.alias}-ip" }
  ))
  provider = aws.env
}
resource "aws_eip_association" "eip_assoc" {
  count = var.enable_external_ip == null ? 1 : 0
  instance_id   = aws_instance.i.id
  allocation_id = aws_eip.i[0].id
  provider = aws.env
}