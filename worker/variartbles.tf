variable worker_name {
    description = "worker name"
}

variable rendered_definition{
    description = "rendered template for ecs task"
}

variable env  {
    description = "a list of env variables and settings"
}

variable security {
    description = "security module output"
}

variable cluster {
    description = "ecs cluster object"
}

variable queue_name {
    description = "the name of the queue used by this worker"
}

variable private_networks {
    description = "a list of private networks"
}

variable cpu  {
    default = "1024"
    description = "the task cpu"
}

variable memory  {
    default = "2048"
    description = "the task memory"
}

variable desire_count  {
    default = 1
    description = "desired count of instance at init"
}

variable autoscale_max_instances_count {
    description = "maximum number of instances"
    default = 1
}

variable autoscale_min_instances_count {
    description = "minimun number of instances"
    default = 0
}

variable autoscale_up_policy_cooldown {
    description = "Cooldown of the up policy in seconds"
    default = 60
}

variable autoscale_down_policy_cooldown {
    description = "Cooldown of the down policy in seconds"
    default = 60
}