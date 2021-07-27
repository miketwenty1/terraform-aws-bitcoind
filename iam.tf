# only needed if you want to pull/push SSM from ec2 host

resource "aws_iam_role" "role" {
  name                = "${var.env}-role-for-${var.alias}"
  description         = "${var.env}-role"
  assume_role_policy  = data.aws_iam_policy_document.ec2_sts.json
  tags                = local.common_tags
}

resource "aws_iam_role_policy" "ssm_policy" {
  name   = "ssm-${var.alias}"
  role   = aws_iam_role.role.id
  policy = data.aws_iam_policy_document.ssm.json
}

resource "aws_iam_role_policy_attachment" "a1" {
  role       = aws_iam_role.role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentAdminPolicy"
}
resource "aws_iam_role_policy_attachment" "a2" {
  role       = aws_iam_role.role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}
resource "aws_iam_role_policy_attachment" "a3" {
  role       = aws_iam_role.role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "iip" {
  name_prefix = "${var.alias}"
  role        = aws_iam_role.role.id
}