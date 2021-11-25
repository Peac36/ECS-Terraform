[
  {
    "name": "project-app-${envName}",
    "image": "${image}",
    "cpu": ${INSTANCE_CPU},
    "memory": ${INSTANCE_MEMORY},
    "networkMode": "awsvpc",
    "portMappings": [
      {
        "containerPort": ${INSTANCE_PORT},
        "hostPort": ${INSTANCE_PORT}
      }
    ],
    "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
            "awslogs-group": "ecs/project-app-${envName}",
            "awslogs-region": "${region}",
            "awslogs-stream-prefix": "ecs"
        }
    },
    "environment": [
      {
        "name": "RANDOM_ENVIRONMENT",
        "value": "${ENVIRONMENT_HERE}"
      }

    ],
    "secrets": [
        {
          "name": "SECRET",
          "valueFrom": "${SECRET}"
        }

    ]
  }
]