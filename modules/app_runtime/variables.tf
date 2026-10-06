variable "project_id" {
  type = string
}

variable "region" {
  type = string
}

variable "container_port" {
  type    = number
  default = 8080
}

variable "deploy_service" {
  type    = bool
  default = true
}

variable "image_tag" {
  type = string
}
