resource "aws_iam_role" "ProjectMainRole" {
  name = "ProjectMainRole-${var.envName}"

  assume_role_policy = data.aws_iam_policy_document.ecs-assume-role-policy.json
  managed_policy_arns = [aws_iam_policy.S3.arn,aws_iam_policy.SSHAccess.arn]
}

resource "aws_iam_role" "ProjectExecutionRole" {
  name = "ProjectExecutionRole-${var.envName}"

  assume_role_policy = data.aws_iam_policy_document.ecs-assume-role-policy.json
  managed_policy_arns = [aws_iam_policy.ExecutionPolicy.arn]
}

