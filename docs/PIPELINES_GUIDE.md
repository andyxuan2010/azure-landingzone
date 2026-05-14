# Pipelines Guide

This document explains the two pipeline systems currently present in this repo:

- GitHub Actions in [../.github/workflows/terraform.yml](../.github/workflows/terraform.yml)
- Azure DevOps in [../azure-pipelines.yml](../azure-pipelines.yml)

The two pipelines do not serve exactly the same purpose. GitHub Actions is the current repo-centric validation and snapshot publishing flow. Azure DevOps is the environment execution pipeline that performs the Terraform plan and apply flow on the shared runner estate.

## Pipeline Summary

| Pipeline | File | Primary role | Trigger model | Apply behavior |
| --- | --- | --- | --- | --- |
| GitHub Actions | `.github/workflows/terraform.yml` | Validate root composition and publish snapshots to downstream repos | Push, pull request, and manual dispatch for `main`, `dev`, `sbx` | Apply job exists but is disabled with `if: false` |
| Azure DevOps | `azure-pipelines.yml` | Run Terraform validate, plan, artifact publish, apply, and release tag creation in Azure DevOps | Triggered on `main` in the checked-in YAML | Apply stage is enabled with `condition: true` |

## GitHub Actions Pipeline

### What it does

The GitHub Actions workflow is built around four jobs:

1. `validation-precheck`
2. `validate-plan`
3. `publish-stage-repo`
4. `publish-ado-repo`

There is also an `apply` job in the file, but it is currently disabled. GitHub Actions does not create release tags; it consumes the tags Azure DevOps pushes back to GitHub.

### Trigger behavior

- Runs on push to `main`, `dev`, and `sbx`
- Runs on pull request targeting `main`, `dev`, and `sbx`
- Supports manual dispatch

### Validation flow

The workflow:

- checks whether required Azure validation secrets exist
- configures Git authentication so Terraform can download shared modules from Azure DevOps
- resolves branch-to-environment mapping:
  `main -> prod`
  `dev -> dev`
  `sbx -> sbx`
  everything else defaults to `dev`
- runs:
  `terraform init -reconfigure`
  `terraform fmt -check -recursive`
  `terraform validate`
  `terraform test -filter=tests/root-plan.tftest.hcl`
  `terraform plan -out=tfplan`

### Auth model

GitHub Actions uses repo or environment secrets:

- `AZURE_CLIENT_ID`
- `AZURE_CLIENT_SECRET`
- `AZURE_TENANT_ID`
- `AZURE_SUBSCRIPTION_ID`
- `AZURE_ADO_PAT2`
- `STAGE_REPO_TOKEN`
- `ADO_REPO_PAT`

The Azure secrets are used for Terraform provider authentication. `AZURE_ADO_PAT2` is used to rewrite `https://dev.azure.com/` module download URLs so Terraform can fetch modules from the shared Azure DevOps template repo.

### Artifact and publishing behavior

- On non-PR runs, the workflow uploads the binary Terraform plan as a GitHub Actions artifact.
- After a successful validation/plan run, it publishes a clean snapshot of the repo to:
  a GitHub stage repo
  an Azure DevOps repo

This means GitHub Actions currently acts as both:

- a validation gate for the root landing zone composition
- a content publication mechanism for downstream repo mirrors

### Important characteristics

- It validates the root landing zone composition only, not the full upstream module matrix.
- The `apply` job is intentionally disabled.
- It is safer than the ADO pipeline for repo validation because pull requests run validation without applying changes.

## Azure DevOps Pipeline

### What it does

The Azure DevOps pipeline has two stages:

1. `ValidatePlan`
2. `Apply`

It is designed to execute Terraform from the shared Azure DevOps runner environment and to prepare the working directory through shared templates from the upstream template repo.

### Trigger behavior

The checked-in YAML currently triggers only on:

- `main`

Even though branch-based environment variables exist for `dev` and `sbx`, the current trigger block only includes `main`.

### Execution flow

The pipeline:

- runs on the shared `IaCRunner` Linux agent pool
- imports shared templates from the Azure DevOps `IaC/template` repo
- runs shared runner hygiene setup
- runs a shared Terraform prepare template
- executes:
  `terraform fmt -check -recursive`
  `terraform validate`
  `terraform plan`
- publishes:
  the binary plan file
  a text-rendered `terraform show` output
- then runs `terraform apply`

### Auth model

Azure DevOps uses service connections and the `AzureCLI@2` task. The pipeline exports provider environment variables from the service connection context:

- `ARM_CLIENT_ID`
- `ARM_TENANT_ID`
- `ARM_SUBSCRIPTION_ID`
- `ARM_CLIENT_SECRET` when a service principal key is present
- `ARM_USE_OIDC` and `ARM_OIDC_TOKEN` when an OIDC token is present

This means Azure DevOps is more tightly integrated with Azure service connections than the GitHub Actions workflow.

### Backend and preparation model

Azure DevOps relies on shared templates from the upstream template repo:

- `templates/shared-runner-hygiene.yml@tf_tpl`
- `templates/terraform-prepare.yml@tf_tpl`

That makes the Azure DevOps pipeline more dependent on shared platform pipeline conventions than GitHub Actions, which is more self-contained.

### Important characteristics

- The `Apply` stage is enabled with `condition: true`.
- As checked in, this pipeline will apply after `ValidatePlan` succeeds.
- It currently publishes both a machine-readable plan artifact and a human-readable plan text artifact.
- It only triggers from `main` in the current YAML.

## Key Differences

### Purpose

- GitHub Actions is primarily for repo validation and snapshot publishing.
- Azure DevOps is primarily for Terraform execution against Azure.

### Safety posture

- GitHub Actions does not currently apply changes.
- Azure DevOps does currently apply changes.

### Trigger surface

- GitHub Actions covers `main`, `dev`, `sbx`, pull requests, and manual dispatch.
- Azure DevOps currently triggers only on `main`.

### Runner and template dependency

- GitHub Actions is mostly self-contained.
- Azure DevOps depends on shared runner hygiene and Terraform prepare templates from the template repo.

### Artifact behavior

- GitHub Actions uploads the binary plan artifact.
- If the `INFRACOST_API_KEY` GitHub Actions secret is configured, GitHub Actions also generates an Infracost estimate from the Terraform plan, adds it to the job summary, and posts or updates a PR comment on pull requests.
- Azure DevOps publishes both the binary plan and a rendered text plan.

### Publication behavior

- GitHub Actions republishes the repo to a stage GitHub repo and an Azure DevOps repo.
- Azure DevOps does not perform repo snapshot publishing, but it is the source of truth for release tag creation.

## Recommended Interpretation

For this repo as it exists today:

- Treat GitHub Actions as the source of truth for validating the root landing zone composition in GitHub.
- Treat Azure DevOps as the execution pipeline that can perform environment plan/apply from the shared enterprise runner setup.

That split is reasonable, but it also means you should be aware of one important operational difference:

- a successful GitHub validation does not mean an apply occurred
- a successful Azure DevOps run may have already applied infrastructure changes

## Current Risks And Observations

- The Azure DevOps pipeline has branch-to-environment mappings for `dev` and `sbx`, but the current trigger only includes `main`.
- The Azure DevOps `Apply` stage is always enabled in the checked-in YAML.
- The GitHub Actions workflow contains a manual dispatch `apply` input, but the actual `apply` job is disabled, so that input currently has no effect.
- Release tags are intentionally created only by Azure DevOps. Non-breaking releases increment the patch version, and that pushed tag is what GitHub surfaces.
- The two pipelines are intentionally asymmetric, which is fine, but contributors should not assume they validate or deploy in the same way.

## Which Pipeline Should I Use?

- Use GitHub Actions when you want repo validation, PR feedback, and downstream snapshot publishing.
- Use Azure DevOps when you want the shared runner-based Terraform execution path and the checked-in plan/apply workflow.
