variable "github_repo" {
  default = "NyashaTendai/shophub-ecommerce"
}

resource "google_project_service" "ci_apis" {
  for_each           = toset(["iamcredentials.googleapis.com", "sts.googleapis.com"])
  service            = each.key
  disable_on_destroy = false
}

# Identity the pipeline acts as
resource "google_service_account" "github_deployer" {
  account_id   = "github-deployer"
  display_name = "GitHub Actions deployer"
}

# Trust link: only your repo, only the main branch
resource "google_iam_workload_identity_pool" "github" {
  workload_identity_pool_id = "github-pool"
  display_name              = "GitHub Actions"
  depends_on                = [google_project_service.ci_apis]
}

resource "google_iam_workload_identity_pool_provider" "github" {
  workload_identity_pool_id          = google_iam_workload_identity_pool.github.workload_identity_pool_id
  workload_identity_pool_provider_id = "github-provider"
  display_name                       = "GitHub"

  attribute_mapping = {
    "google.subject"       = "assertion.sub"
    "attribute.repository" = "assertion.repository"
    "attribute.ref"        = "assertion.ref"
  }

  attribute_condition = "assertion.repository == \"${var.github_repo}\" && assertion.ref == \"refs/heads/main\""

  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
  }
}

resource "google_service_account_iam_member" "github_can_impersonate" {
  service_account_id = google_service_account.github_deployer.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.github.name}/attribute.repository/${var.github_repo}"
}

# Least privilege: push images, update this one service, act as the runtime account
resource "google_artifact_registry_repository_iam_member" "deployer_push" {
  location   = google_artifact_registry_repository.shophub.location
  repository = google_artifact_registry_repository.shophub.name
  role       = "roles/artifactregistry.writer"
  member     = "serviceAccount:${google_service_account.github_deployer.email}"
}

resource "google_cloud_run_v2_service_iam_member" "deployer_run" {
  project  = var.project_id
  location = var.region
  name     = google_cloud_run_v2_service.shophub[0].name
  role     = "roles/run.developer"
  member   = "serviceAccount:${google_service_account.github_deployer.email}"
}

resource "google_service_account_iam_member" "deployer_acts_as_runtime" {
  service_account_id = google_service_account.shophub_run.name
  role               = "roles/iam.serviceAccountUser"
  member             = "serviceAccount:${google_service_account.github_deployer.email}"
}