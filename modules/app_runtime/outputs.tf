output "service_url" {
  value = var.deploy_service ? google_cloud_run_v2_service.shophub[0].uri : "not deployed yet"
}

output "service_name" {
  value = google_cloud_run_v2_service.shophub[0].name
}

output "runtime_service_account_name" {
  value = google_service_account.shophub_run.name
}

output "registry_location" {
  value = google_artifact_registry_repository.shophub.location
}

output "registry_name" {
  value = google_artifact_registry_repository.shophub.name
}
