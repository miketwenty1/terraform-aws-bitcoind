data "aws_vpc" "env" {
  filter {
    name   = "tag:bitcoin_terraform"
    values = ["enabled"]
  }
}

# Used if you want ec2 to push ssm parameter
data "aws_iam_policy_document" "ec2_sts" {
  version = "2012-10-17"
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "ssm" {
  version = "2012-10-17"
  statement {
    actions = [
      "ssm:SendCommand",
      "ssm:PutParameter",
      "ssm:AddTagsToResource"
    ]
    resources = [
      "arn:aws:ec2:*:*:instance/*",
      "arn:aws:ssm:us-east-1::document/AWS-ConfigureAWSPackage",
      "arn:aws:ssm:us-east-1::document/AmazonCloudWatch-ManageAgent"
    ]
  }
}