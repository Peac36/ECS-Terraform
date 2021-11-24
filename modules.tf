module "env" {
    source = "./env"

    workspace = local.workspace
}

module "security" {
    source = "./security"

    vpc_id = aws_vpc.main.id
    envName = module.env.envName
}