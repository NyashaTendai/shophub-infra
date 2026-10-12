# ShopHub infrastructure

Terraform for the ShopHub API on Google Cloud. The application code and the CI/CD pipeline live in the companion repo: https://github.com/NyashaTendai/shophub-ecommerce

## What it creates

| Area | Resources |
|---|---|
| Container registry | Artifact Registry repository `shophub`, with a cleanup policy that keeps the 2 newest images |
| Runtime | Cloud Run service `shophub` (1 vCPU, 512Mi, maximum 2 instances, startup CPU boost), public access, and a runtime service account |
| Secrets | A Secret Manager secret `database-url`, readable by the runtime service account and by the deploy account |
| Keyless CI/CD | A Workload Identity Pool and provider for GitHub, a deploy service account, and the permissions it needs |

## Layout

```
main.tf                      root: provider and the two modules
variables.tf                 project, region, image tag, minimum instances
moved.tf                     moved blocks used when the code was split into modules
deployer_secret_access.tf    lets the deploy account read the database URL secret
modules/app_runtime/         registry, secret, runtime account, Cloud Run service
modules/github_cicd/         Workload Identity Federation and the deploy account
```

## How to use it

```powershell
terraform init
terraform fmt -recursive
terraform validate
terraform plan
terraform apply
```

Read the plan before you apply. After an apply, the service URL is printed as `service_url`.

## Decisions and trade-offs

- **No stored cloud keys.** GitHub authenticates through Workload Identity Federation with short-lived tokens. The trust rule only accepts the `NyashaTendai/shophub-ecommerce` repository.
- **Least privilege.** The deploy account can push to one registry, update one service and read one secret. The runtime account can read one secret.
- **Image tag outside Terraform's control.** The pipeline deploys a new image for every commit, so Terraform ignores changes to the image and does not fight the pipeline.
- **Modules.** The code is split into `app_runtime` and `github_cicd`. The `moved` blocks in `moved.tf` let existing resources change address without being destroyed and recreated.
- **Secret value kept out of Terraform.** Terraform creates the secret, and the database URL itself is added separately, so it never appears in Terraform state or in Git.

## Always-on instance

`min_instances` defaults to 1, so one Cloud Run instance stays warm. The first request after idle takes under a second instead of about 7 to 9 seconds. It costs roughly $10 a month. To scale to zero instead, run `terraform apply -var="min_instances=0"`.

## Pipeline access to the database URL

`deployer_secret_access.tf` lets the GitHub deploy account read the `database-url` secret, and only that secret, so the pipeline can run database migrations before each deploy.

## Cost controls

Maximum 2 instances, 512Mi memory, and a registry cleanup policy so storage stays inside the free allowance. The only recurring cost is the always-on instance.

## Not done yet

- Terraform state is stored locally. Moving it to a Cloud Storage bucket with locking is the next step.
