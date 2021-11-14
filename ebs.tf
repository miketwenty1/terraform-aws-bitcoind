resource "aws_ebs_volume" "v" {
  availability_zone = "${var.region}${var.az_letter}"
  size              = var.bitcoin_volume_size
  type              = "gp3"
  
  tags = merge(local.common_tags,tomap(
    { Name = "${var.env}_${var.alias}_volume" }
  ))
}

resource "aws_volume_attachment" "ebs_att" {
  device_name = "/dev/sdf" # will end up being /dev/nvme1n1 in cloudinit
  volume_id   = aws_ebs_volume.v.id
  instance_id = aws_instance.i.id
}

