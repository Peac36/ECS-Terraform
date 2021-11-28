variable "workspace" {
    type = string
}

variable environments {
    type = map

    default = {
        dev = {
            envName: "Dev"
            CIRD: "10.5.0.0/16"
            AvailabilityZoneCount: 2,
            appEnv: {
                ENVIRONMENT_HERE: "Test"
            }
            appSiteSettings: {
                INSTANCE_PORT: 80
                INSTANCE_CPU: 1024
                INSTANCE_MEMORY: 2048
                MIN_INSTANCE_COUNT: 1
                MAX_INSTANCE_COUNT: 4
                DESIRED_INSTANCE_COUNT: 1
            }
            workerSettings: {
                INSTANCE_PORT: 80
                INSTANCE_CPU: 2048
                INSTANCE_MEMORY: 4096
                MIN_INSTANCE_COUNT: 1
                MAX_INSTANCE_COUNT: 4
                DESIRED_INSTANCE_COUNT: 2
            }
        }

        prod = {
            envName: "Prod"
            CIRD: "10.10.0.0/16"
            AvailabilityZoneCount: 2,
            appEnv: {
                ENVIRONMENT_HERE: "Test"
            }
            appSiteSettings: {
                INSTANCE_PORT: 80
                INSTANCE_CPU: 1024
                INSTANCE_MEMORY: 2048
                MIN_INSTANCE_COUNT: 1
                MAX_INSTANCE_COUNT: 4
                DESIRED_INSTANCE_COUNT: 1
            }
            workerSettings: {
                INSTANCE_PORT: 80
                INSTANCE_CPU: 2048
                INSTANCE_MEMORY: 4096
                MIN_INSTANCE_COUNT: 1
                MAX_INSTANCE_COUNT: 4
                DESIRED_INSTANCE_COUNT: 2
            }
        }
    }
}

locals {
    environment = var.environments[var.workspace]
}
output envName {
    value = local.environment.envName
}
output CIDR {
    value = local.environment.CIRD
}
output AvailabilityZoneCount {
    value = local.environment.AvailabilityZoneCount
}
output APP_ENVIRONMENT {
    value = local.environment.appEnv
}
output APP_SECRETS {
    value = {
        SECRET: data.aws_ssm_parameter.SECRET.arn

    }
}
output APP_SETTINGS {
    value  = local.environment.appSiteSettings
}
output WORKER_SETTINGS {
    value = local.environment.workerSettings
}