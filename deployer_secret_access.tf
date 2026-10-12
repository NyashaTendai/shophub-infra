# Lets the GitHub deploy account read the database URL so the pipeline can run migrations.
resource "google_secret_manager_secret_iam_member" "deployer_reads_database_url" {
  project   = var.project_id
  secret_id = "projects/${var.project_id}/secrets/database-url"
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:github-deployer@${var.project_id}.iam.gserviceaccount.com"
}