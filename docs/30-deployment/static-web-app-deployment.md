# Static Web App Deployment Guide

This guide describes how to deploy website content to the Dev-only Free Azure Static Web App provisioned by this repository. The checked-in site content lives under [`static-web-apps`](../../static-web-apps).

## Targets

| Environment | Resource group | Static Web App | Site folder | Hosting region | SKU |
| --- | --- | --- | --- | --- | --- |
| Dev | `rg-platform-dev` | `demo-platform-cc-dev` | `static-web-apps/north-peak-cloud` | East US 2 | Free |

Terraform provisions the hosting resources. Website content should be deployed by a separate application deployment process. This keeps infrastructure changes, application releases, and deployment credentials separate.

The resource group is in Canada Central, but Static Web Apps are deployed to East US 2 because `Microsoft.Web/staticSites` is not available in Canada Central for this subscription. The Static Web App region is controlled by `static_web_app_location`.

The resources must be provisioned before content can be deployed:

```powershell
terraform init -reconfigure -input=false `
  -backend-config=environments/dev/backend.hcl

terraform plan `
  -var-file=environments/dev/terraform.tfvars `
  -out=dev.tfplan

terraform apply dev.tfplan
```

## Recommended practice

Use the checked-in GitHub Actions workflow at [`.github/workflows/static-web-apps.yml`](../../.github/workflows/static-web-apps.yml) for normal deployments. It deploys from `main` and publishes the primary site to the single Dev Static Web App. Use the Azure Static Web Apps CLI for a quick local demonstration or an emergency redeployment.

The preferred flow is:

1. Build the website in CI.
2. Deploy the exact build artifact to the target Static Web App.
3. Store the Static Web App deployment token in the CI secret store.
4. Verify the deployed hostname and application health.
5. Keep the deployment token out of Terraform variables, source control, logs, and pull requests.

Do not put website files into Terraform state and do not make the deployment token a normal Terraform output. A deployment token grants permission to publish to the Static Web App.

## Option 1: GitHub Actions

GitHub Actions is the recommended method for repeatable deployments from this repository or from a separate application repository.

Create one repository or environment secret:

- `SWA_PRIMARY_TOKEN` for `demo-platform-cc-dev`

The repository contains a workflow for the framework-free primary site. It watches `static-web-apps/**`, uploads the site folder, and deploys it to the Dev site. The workflow expects this GitHub Environment secret in the `dev` environment:

- `SWA_PRIMARY_TOKEN` for `static-web-apps/north-peak-cloud`

Before deployment, the workflow runs `validate-site-content`. This prerequisite validates HTML metadata, IDs, local links/assets, and shared security headers across the demo sites, then checks that `static-web-apps/north-peak-cloud/` exists and contains an `index.html` entry point. The deployment job depends on this check, so a missing site folder or entry point stops the workflow before any Azure upload begins.

For a different website layout, adjust `app_location` and the build settings in the workflow. A workflow similar to the following is the deployment pattern:

```yaml
name: Deploy Static Web Apps

on:
  push:
    branches:
      - main
  workflow_dispatch:

jobs:
  deploy-primary:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@11d5960a326750d5838078e36cf38b85af677262 # v4

      - name: Deploy primary Static Web App
        uses: Azure/static-web-apps-deploy@1a947af9992250f3bc2e68ad0754c0b0c11566c9 # v1
        with:
          azure_static_web_apps_api_token: ${{ secrets.SWA_PRIMARY_TOKEN }}
          action: upload
          app_location: "static-web-apps/north-peak-cloud"
          skip_app_build: true

```

The checked-in workflow deploys the primary site directly. If additional sites are later provisioned, add a validation path, deployment job, and deployment token for each site.

For stronger release control, build once and publish the build artifact before deployment.

## Getting the deployment tokens

Retrieve a token only when setting up or rotating the CI secret:

```powershell
$primaryToken = az staticwebapp secrets list `
  --subscription 1ec5edd4-5654-4246-8027-b29ef63b3393 `
  --resource-group rg-platform-dev `
  --name demo-platform-cc-dev `
  --query "properties.apiKey" -o tsv

```

Copy the values directly into the GitHub or Azure DevOps secret interface. Do not commit them to a file. Rotate a token if it is exposed.

## Option 2: Azure Static Web Apps CLI

The CLI is useful for a quick demo when the site has already been built locally. The deployment directory must contain the final static content, including `index.html`.

Install the CLI:

```powershell
npm install -g @azure/static-web-apps-cli
```

Deploy the primary site:

```powershell
$env:SWA_CLI_DEPLOYMENT_TOKEN = az staticwebapp secrets list `
  --subscription 1ec5edd4-5654-4246-8027-b29ef63b3393 `
  --resource-group rg-platform-dev `
  --name demo-platform-cc-dev `
  --query "properties.apiKey" -o tsv

swa deploy .\dist `
  --deployment-token $env:SWA_CLI_DEPLOYMENT_TOKEN `
  --env production

Remove-Item Env:SWA_CLI_DEPLOYMENT_TOKEN
```

The CLI can also deploy an API folder when the Static Web App uses the supported Static Web Apps API model:

```powershell
swa deploy .\dist `
  --api-location .\api `
  --deployment-token $env:SWA_CLI_DEPLOYMENT_TOKEN `
  --env production
```

## Option 3: Portal repository integration

For a small proof of concept, Azure Portal can connect a Static Web App directly to GitHub or Azure DevOps:

1. Open the Static Web App in Azure Portal.
2. Open the deployment or source-control configuration.
3. Select GitHub or Azure DevOps.
4. Choose the repository, branch, app location, and output location.
5. Allow Azure to create the deployment workflow.

This is convenient, but more deployment configuration lives outside the repository. Prefer a checked-in workflow when the deployment needs review, repeatability, or promotion across environments.

## Finding the deployed URLs

Static Web Apps receive autogenerated hostnames. List the URLs with Azure CLI:

```powershell
az staticwebapp list `
  --subscription 1ec5edd4-5654-4246-8027-b29ef63b3393 `
  --resource-group rg-platform-dev `
  --query "[].{name:name,hostname:defaultHostname,sku:sku.name}" `
  -o table
```

Open each result as `https://<defaultHostname>`.

Current Dev URL:

- North Peak Cloud: <https://black-dune-0d052ec0f.4.azurestaticapps.net>

You can also use Azure Portal:

`2join.us` subscription → `rg-platform-dev` → **Static Web Apps** → select the app → **Overview** → **URL**.

## Verification checklist

After deployment, verify:

```powershell
az staticwebapp show `
  --subscription 1ec5edd4-5654-4246-8027-b29ef63b3393 `
  --resource-group rg-platform-dev `
  --name demo-platform-cc-dev `
  --query "{name:name,hostname:defaultHostname,sku:sku.name}" `
  -o table
```

Then check the site over HTTPS and confirm:

- The expected `index.html` is returned.
- Static assets load without 404 errors.
- Client-side routes work, if applicable.
- The deployment workflow completed successfully.
- The site is using the expected Free SKU.

For a single-page application, include the appropriate `staticwebapp.config.json` route fallback when client-side routes must resolve to `index.html`.

## Deployment and cost notes

- The Static Web App is configured with the Free SKU.
- It does not require an App Service Plan.
- GitHub Actions, Azure DevOps agents, build minutes, external APIs, or additional Azure services can have separate quotas or charges.
- Review the Azure subscription cost analysis after enabling any build, API, monitoring, or storage integration.

## Official references

- [What is Azure Static Web Apps?](https://learn.microsoft.com/en-us/azure/static-web-apps/overview)
- [Deploy with the Azure Static Web Apps CLI](https://learn.microsoft.com/en-us/azure/static-web-apps/static-web-apps-cli-deploy)
- [Azure Static Web Apps CLI reference](https://learn.microsoft.com/en-us/azure/static-web-apps/static-web-apps-cli)
- [Quickstart: Build your first static web app](https://learn.microsoft.com/en-us/azure/static-web-apps/get-started-portal)
