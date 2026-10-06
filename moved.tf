moved {
  from = google_artifact_registry_repository.shophub
  to   = module.app_runtime.google_artifact_registry_repository.shophub
}
moved {
  from = google_secret_manager_secret.database_url
  to   = module.app_runtime.google_secret_manager_secret.database_url
}
moved {
  from = google_service_account.shophub_run
  to   = module.app_runtime.google_service_account.shophub_run
}
moved {
  from = google_secret_manager_secret_iam_member.run_can_read
  to   = module.app_runtime.google_secret_manager_secret_iam_member.run_can_read
}
moved {
  from = google_cloud_run_v2_service.shophub
  to   = module.app_runtime.google_cloud_run_v2_service.shophub
}
moved {
  from = google_cloud_run_v2_service_iam_member.public
  to   = module.app_runtime.google_cloud_run_v2_service_iam_member.public
}

moved {
  from = google_project_service.ci_apis
  to   = module.github_cicd.google_project_service.ci_apis
}
moved {
  from = google_service_account.github_deployer
  to   = module.github_cicd.google_service_account.github_deployer
}
moved {
  from = google_iam_workload_identity_pool.github
  to   = module.github_cicd.google_iam_workload_identity_pool.github
}
moved {
  from = google_iam_workload_identity_pool_provider.github
  to   = module.github_cicd.google_iam_workload_identity_pool_provider.github
}
moved {
  from = google_service_account_iam_member.github_can_impersonate
  to   = module.github_cicd.google_service_account_iam_member.github_can_impersonate
}
moved {
  from = google_artifact_registry_repository_iam_member.deployer_push
  to   = module.github_cicd.google_artifact_registry_repository_iam_member.deployer_push
}
moved {
  from = google_cloud_run_v2_service_iam_member.deployer_run
  to   = module.github_cicd.google_cloud_run_v2_service_iam_member.deployer_run
}
moved {
  from = google_service_account_iam_member.deployer_acts_as_runtime
  to   = module.github_cicd.google_service_account_iam_member.deployer_acts_as_runtime
}
