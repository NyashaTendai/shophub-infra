terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.0"
    }
  }
}

variable "project_id" {
  default = "project-45cfe394-2aee-40ec-a9a"
}

variable "region" {
  default = "us-central1"
}

variable "container_port" {
  default = 8080
}

variable "deploy_service" {
  type    = bool
  default = true
}

variable "image_tag" {
  default = "1.2"
}

provider "google" {
  project = var.project_id
  region  = var.region
}

# Image registry, with automatic cleanup to stay under the 0.5 GiB free tier
resource "google_artifact_registry_repository" "shophub" {
  location      = var.region
  repository_id = "shophub"
  format        = "DOCKER"
  description   = "ShopHub container images"

  cleanup_policy_dry_run = false

  cleanup_policies {
    id     = "keep-latest-2"
    action = "KEEP"
    most_recent_versions {
      keep_count = 2
    }
  }

  cleanup_policies {
    id     = "delete-old"
    action = "DELETE"
    condition {
      older_than = "86400s"
    }
  }
}

# Secret container only. The value is added with gcloud so it never enters Terraform state.
resource "google_secret_manager_secret" "database_url" {
  secret_id = "database-url"
  replication {
    auto {}
  }
}

# Dedicated runtime identity for the service (least privilege)
resource "google_service_account" "shophub_run" {
  account_id   = "shophub-run"
  display_name = "ShopHub Cloud Run runtime"
}

resource "google_secret_manager_secret_iam_member" "run_can_read" {
  secret_id = google_secret_manager_secret.database_url.id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.shophub_run.email}"
}

resource "google_cloud_run_v2_service" "shophub" {
  count    = var.deploy_service ? 1 : 0
  name     = "shophub"
  location = var.region
  ingress  = "INGRESS_TRAFFIC_ALL"

  deletion_protection = false

  template {
    service_account = google_service_account.shophub_run.email

    scaling {
      min_instance_count = 0
      max_instance_count = 2
    }

    containers {
      image = "${var.region}-docker.pkg.dev/${var.project_id}/shophub/shophub:${var.image_tag}"

      ports {
        container_port = var.container_port
      }

      env {
        name = "DATABASE_URL"
        value_source {
          secret_key_ref {
            secret  = google_secret_manager_secret.database_url.secret_id
            version = "latest"
          }
        }
      }

      resources {
        limits = {
          cpu    = "1"
          memory = "512Mi"
        }
        cpu_idle = true
      }
    }
  }

  depends_on = [google_secret_manager_secret_iam_member.run_can_read]
}

resource "google_cloud_run_v2_service_iam_member" "public" {
  count    = var.deploy_service ? 1 : 0
  project  = var.project_id
  location = var.region
  name     = google_cloud_run_v2_service.shophub[0].name
  role     = "roles/run.invoker"
  member   = "allUsers"
}

output "service_url" {
  value = var.deploy_service ? google_cloud_run_v2_service.shophub[0].uri : "not deployed yet"
}