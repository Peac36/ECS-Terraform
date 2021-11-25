data "aws_iam_policy_document" "ecs-assume-role-policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_policy" "S3"{
  name = "S3-Project-${var.envName}"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "s3",
        "Effect" : "Allow",
        "Action" : [
          "s3:PutObject",
          "s3:GetObject",
          "s3:GetObjectTagging",
          "s3:DeleteObject",
          "s3:PutObjectAcl",
          "s3:PutObjectTagging",
          "s3:GetObjectAcl"
        ],
        "Resource" : "arn:aws:s3:::project-bucket/*"
      },
      {
        "Sid" : "s3List",
        "Effect" : "Allow",
        "Action" : [
          "s3:ListBucket",
          "s3:GetBucketAcl"
        ],
        "Resource" : "arn:aws:s3:::project-bucket",
      }
    ]
  })
}

resource "aws_iam_policy" "SSHAccess"{
  name = "SSH-Project-${var.envName}"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
     {
        "Sid" : "ContainerSSHAccess",
        "Effect": "Allow",
        "Action": [
            "ssmmessages:CreateControlChannel",
            "ssmmessages:CreateDataChannel",
            "ssmmessages:OpenControlChannel",
            "ssmmessages:OpenDataChannel"
        ],
        "Resource": "*"
      },
    ]
  })
}

resource "aws_iam_policy" "ExecutionPolicy" {
    name = "ExecutionPolicy-${var.envName}"

    policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        "Resource" : "*"
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "ssm:GetParametersByPath",
          "ssm:GetParameters",
          "ssm:GetParameter"
        ],
        "Resource" : [
          "arn:aws:ssm:*:*:parameter/*",
        ]
      }
    ]
  })
}


