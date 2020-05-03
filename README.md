# AWS ECS Service

This module provides AWS ECS Service resources:
- ECS Service
- ECS Task defenition
- AWS App Autoscaling target (CPU and RAM)
- IAM Instance profile
- IAM Execution role

# Input variables
- `name` - Name that will be used in resources names and tags
- `cluster` - AWS ECS cluster data where tasks will be deployed
- `aws_sm_key_arns` - AWS Secrets Manager secret ARNs for container defenitions
- `desired_count` - The number of instances of the task definition to place and keep running
- `scheduling_strategy` - The scheduling strategy to use for the service
- `ecs_task` - Parameters for ECS task: load_balancer options, container_definitions options and volumes options
- `network_mode` - The Docker networking mode to use for the containers in the task

# Output variables
- `ecs_service`
    - `id` - The Amazon Resource Name (ARN) that identifies the service
    - `name` - The name of the service
    - `cluster` - The Amazon Resource Name (ARN) of cluster which the service runs on
    - `desired_count` - The number of instances of the task definition
