terraform {
  experiments = [variable_validation]
}

variable "name" {
  type        = string
  description = "Name that will be used in resources names and tags."
  default     = "terraform-aws-ecs-service"
}

variable "cluster" {
  type        = any
  description = "AWS ECS cluster data where tasks will be deployed."
}

variable "aws_sm_key_arns" {
  type        = list(string)
  description = "AWS Secrets Manager secret ARNs for container defenitions"
}

variable "desired_count" {
  type        = number
  description = "The number of instances of the task definition to place and keep running."
  default     = 0
}

variable "scheduling_strategy" {
  type        = string
  description = "The scheduling strategy to use for the service."
  default     = "REPLICA"

  validation {
    condition     = contains(["REPLICA", "DAEMON"], var.scheduling_strategy)
    error_message = "The valid values are REPLICA and DAEMON."
  }
}

variable "ecs_task" {
  type = object({
    load_balancer         = list(any)
    container_definitions = list(any)
    volumes               = list(any)
  })
  description = "Parameters for ECS task: load_balancer options, container_definitions options and volumes options."
}

variable "network_mode" {
  type        = string
  description = "The Docker networking mode to use for the containers in the task."
  default     = "bridge"

  validation {
    condition     = contains(["none", "bridge", "awsvpc", "host"], var.network_mode)
    error_message = "The valid values are none, bridge, awsvpc, and host."
  }
}

