data "aws_ami" "this" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
}

data "aws_iam_policy_document" "assume_esc_task" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"

    principals {
      identifiers = ["ecs-tasks.amazonaws.com"]
      type        = "Service"
    }
  }
}

data "aws_iam_policy_document" "policy_esc_task" {
  statement {
    actions = [
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogStreams"
    ]
    effect    = "Allow"
    resources = ["arn:aws:logs:${data.aws_region.this.name}:${data.aws_caller_identity.this.account_id}:*"]
  }
}

data "aws_iam_policy_document" "execution_policy_esc_task" {
  statement {
    actions = [
      "secretsmanager:GetSecretValue"
    ]
    effect    = "Allow"
    resources = var.aws_sm_key_arns
  }

  statement {
    actions = [
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogStreams"
    ]
    effect    = "Allow"
    resources = ["arn:aws:logs:${data.aws_region.this.name}:${data.aws_caller_identity.this.account_id}:*"]
  }
}

data "aws_iam_role" "ecs_service" {
  name = "AWSServiceRoleForApplicationAutoScaling_ECSService"
}

data "aws_caller_identity" "this" {}

data "aws_region" "this" {}
