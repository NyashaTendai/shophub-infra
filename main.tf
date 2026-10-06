terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

module "app_runtime" {
  source         = "./modules/app_runtime"
  project_id     = var.project_id
  region         = var.region
  container_port = var.container_port
  deploy_service = var.deploy_service
  image_tag      = var.image_tag
}

module "github_cicd" {
  source                       = "./modules/github_cicd"
  project_id                   = var.project_id
  region                       = var.region
  github_repo                  = var.github_repo
  registry_location            = module.app_runtime.registry_location
  registry_name                = module.app_runtime.registry_name
  cloud_run_service_name       = module.app_runtime.service_name
  runtime_service_account_name = module.app_runtime.runtime_service_account_name
}

output "service_url" {
  value = module.app_runtime.service_url
}
