resource "aws_instance" "i" {
  ami                    = lookup(local.ubuntu20_04, var.region, "ami not defined for this region. Please make a PR")
  availability_zone      = "${var.region}${var.az_letter}"
  instance_type          = var.instance_size
  key_name               = var.ssh_key_name
  vpc_security_group_ids = [aws_security_group.sg.id]
  subnet_id              = var.subnet_id
  user_data              = data.template_cloudinit_config.cloud-init.rendered
  iam_instance_profile   = aws_iam_instance_profile.iip.id

  root_block_device {
    volume_type = "gp2"
    volume_size = var.root_volume_size
  }

  tags = merge(local.common_tags, tomap(
    { Name = "bitcoind-${var.alias}" }
  ))
}
