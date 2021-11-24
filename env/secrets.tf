data "aws_ssm_parameter" "SECRET" {
    name = "/Project/${local.environment.envName}/Secret"
}
