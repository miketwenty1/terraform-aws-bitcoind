#### RPC and ZMQ ACCESS SG
resource "aws_security_group" "rpc_zmq_access" {
  name   = "${var.env}_rpc_zmq_access${var.alias}"
  vpc_id = data.aws_vpc.env.id

  tags = merge(local.common_tags, tomap(
    { Name = "${var.env}_rpc_zmq_access${var.alias}" }
  ))
}
#### BITCOIND base sg Rules
resource "aws_security_group" "sg" {
  name   = "${var.env}_sg${var.alias}"
  vpc_id = data.aws_vpc.env.id

  tags = merge(local.common_tags, tomap(
    { Name = "${var.env}_sg${var.alias}" }
  ))
}

resource "aws_security_group_rule" "rule_for_ssh" {
  count             = var.cidr_block_ssh_access_rule == "" ? 0 : 1
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = [var.cidr_block_ssh_access_rule]
  security_group_id = aws_security_group.sg.id
  description       = "cidr block for ssh access"
}

resource "aws_security_group_rule" "outbound" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = -1
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.sg.id
  description       = "outbound everything"
}

resource "aws_security_group_rule" "rule_ssh_sg_access" {
  count = var.sg_for_ssh_access_id == "" ? 0 : 1

  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  security_group_id        = aws_security_group.sg.id
  source_security_group_id = var.sg_for_ssh_access_id
  description              = "sg source for ssh access"
}
# INGRESS
resource "aws_security_group_rule" "zmq_28333" {
  type                     = "ingress"
  from_port                = 28333
  to_port                  = 28333
  protocol                 = "tcp"
  security_group_id        = aws_security_group.sg.id
  source_security_group_id = aws_security_group.rpc_zmq_access.id
  description              = "zmq ingress 28333"
}
resource "aws_security_group_rule" "zmq_28332" {
  type                     = "ingress"
  from_port                = 28332
  to_port                  = 28332
  protocol                 = "tcp"
  security_group_id        = aws_security_group.sg.id
  source_security_group_id = aws_security_group.rpc_zmq_access.id
  description              = "zmq ingress 28332"
}
resource "aws_security_group_rule" "rpc_8332" {
  type                     = "ingress"
  from_port                = 8332
  to_port                  = 8332
  protocol                 = "tcp"
  security_group_id        = aws_security_group.sg.id
  source_security_group_id = aws_security_group.rpc_zmq_access.id
  description              = "rpc ingress 8332"
}
