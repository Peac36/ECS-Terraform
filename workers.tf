data "template_file" "worker" {
  template = file("./templates/worker.taskdef.json.tpl")

  vars = merge(
    module.env.WORKER_SETTINGS,
    module.env.APP_ENVIRONMENT,
    module.env.APP_SECRETS,
    {
      envName: module.env.envName,
      image: var.appImage,
      region: data.aws_region.current.name,
      SQS_URL :aws_sqs_queue.project.url
    }
  )
}


module main-worker {
    source = "./worker"

    worker_name = "main-worker"
    rendered_definition = data.template_file.worker.rendered
    security = module.security
    env = module.env
    cluster = aws_ecs_cluster.Project
    queue_name = aws_sqs_queue.project.name
    private_networks = aws_subnet.private
    cpu  = module.env.WORKER_SETTINGS.INSTANCE_CPU
    memory  = module.env.WORKER_SETTINGS.INSTANCE_MEMORY
    desire_count = module.env.WORKER_SETTINGS.DESIRED_INSTANCE_COUNT
    autoscale_max_instances_count = module.env.WORKER_SETTINGS.MAX_INSTANCE_COUNT
    autoscale_min_instances_count = module.env.WORKER_SETTINGS.MIN_INSTANCE_COUNT
}