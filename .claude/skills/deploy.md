# Deploy Infrastructure

Terraform workflow for deploying or updating AWS infrastructure.

## Steps

1. `cd terraform && terraform validate` — check syntax
2. `cd terraform && terraform plan` — preview changes, review output with user
3. Only after user confirms: `cd terraform && terraform apply`

## Notes

- terraform.tfvars must exist with tailscale_auth_key and github_repo_url before first deploy
- Always show the plan output and wait for user approval before applying
