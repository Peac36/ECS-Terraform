locals {
    FourteenDaysInSeconds = 1209600
    FourDaysInSeconds = 345600
    FourteenMinutesInSeconds = 2400
}

resource "aws_sqs_queue" "project-dead-letter" {
  name                      = "${module.env.envName}-project-dead-letter"
  message_retention_seconds = local.FourteenDaysInSeconds
}

resource "aws_sqs_queue" "project" {
  name                       = "${module.env.envName}-project"
  visibility_timeout_seconds = local.FourteenMinutesInSeconds
  message_retention_seconds  = local.FourDaysInSeconds
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.project-dead-letter.arn
    maxReceiveCount     = 4
  })
}