\# ShopHub infrastructure (Terraform)



Terraform for the Google Cloud side of ShopHub: a Flask + Postgres API on Cloud Run,

deployed by GitHub Actions with no stored keys.



App code and the CI/CD workflow: https://github.com/NyashaTendai/shophub-ecommerce

Local Kubernetes version: https://github.com/NyashaTendai/shophub-k8s



\## Layout

\- `main.tf`: provider and the two module calls

\- `variables.tf`: project, region, image tag, GitHub repo

\- `modules/app\_runtime/`: Artifact Registry (with cleanup policy), Secret Manager secret,

&#x20; runtime service account, Cloud Run service (scale to zero, max 2), public access

\- `modules/github\_cicd/`: Workload Identity Federation pool and provider (restricted to

&#x20; one repo and the `main` branch), deployer service account with least-privilege roles

\- `moved.tf`: records the refactor from flat files to modules, so no resources were recreated



\## Design decisions

\- \*\*Keyless CI/CD:\*\* GitHub Actions authenticates with Workload Identity Federation, so no

&#x20; service account keys exist to leak.

\- \*\*Least privilege:\*\* the deployer can push images, update this one service, and act as the

&#x20; runtime account. Nothing else.

\- \*\*Secrets stay out of state:\*\* Terraform creates the empty secret; the database URL is added

&#x20; with `gcloud`, so it never enters Terraform state or Git.

\- \*\*Low cost:\*\* Cloud Run scales to zero, the registry keeps only 2 images, and a billing

&#x20; budget alert is set.

\- \*\*Image tag ignored by Terraform:\*\* CI deploys new images itself, so Terraform does not

&#x20; fight the pipeline (`lifecycle.ignore\_changes`).



\## Usage

Run `terraform init`, then `terraform plan`, then `terraform apply`.

State and `\*.tfvars` files are not committed (see `.gitignore`).



\## Possible next steps

\- Remote state in a GCS bucket with locking

\- A second environment by calling `app\_runtime` again with different inputs

