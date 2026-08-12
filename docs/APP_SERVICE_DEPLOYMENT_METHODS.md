# App Service Deployment Methods

`app_services[*].deployment_method` is the single deployment selector for each App Service. The landing zone supports four methods. Select one method per app and keep Terraform settings, the application pipeline, and the deployed artifact aligned with it.

## Method Matrix

| Method | Deployment owner | Input | Build location | Source-control binding | Terraform-managed settings |
| --- | --- | --- | --- | --- | --- |
| `external_zip_deploy` | Application CI/CD pipeline | Prebuilt runnable ZIP | Pipeline | No | Remote build disabled; this method does not set `WEBSITE_RUN_FROM_PACKAGE` |
| `run_from_package` | Application CI/CD pipeline | Prebuilt runnable ZIP | Pipeline | No | `WEBSITE_RUN_FROM_PACKAGE=1`; remote build disabled |
| `zip_deploy_with_build` | Application CI/CD pipeline | Source ZIP | App Service/Kudu/Oryx | No | Remote build enabled; this method does not set `WEBSITE_RUN_FROM_PACKAGE` |
| `deployment_center` | App Service Deployment Center | Git repository | App Service/Kudu/Oryx | Yes | Remote build enabled; this method does not set `WEBSITE_RUN_FROM_PACKAGE` |

The legacy `deployment_center_enabled` input remains only for backward compatibility. New configuration must use `deployment_method` and must not combine the legacy flag with another method.

## Pipeline-Owned Methods

### `external_zip_deploy`

The application pipeline builds a runnable artifact and uploads it with a ZIP-deploy operation such as `az webapp deploy --type zip`. App Service extracts the package into the site content directory. The repository URL and Deployment Center integration settings are not used. Ensure a previously configured `WEBSITE_RUN_FROM_PACKAGE` setting is removed by the pipeline or configuration transition.

Use this when the pipeline should be the only deployment mechanism and the artifact already contains everything required at runtime. A stack-specific startup command may still be required; for example, the Node Linux app persists `cd /home/site/wwwroot && npm start` through Terraform.

### `run_from_package`

The pipeline builds a complete package and deploys it while `WEBSITE_RUN_FROM_PACKAGE=1` is set. App Service mounts the ZIP as read-only content rather than extracting and building it.

The artifact must contain all runtime files and dependencies. For Python, that normally means vendoring dependencies under `.python_packages/lib/site-packages`; for Node, production dependencies must be included unless the runtime can resolve them elsewhere; for .NET, publish output must be packaged rather than source.

### `zip_deploy_with_build`

The pipeline uploads application source as a ZIP, and App Service performs the build after upload. Terraform enables `SCM_DO_BUILD_DURING_DEPLOYMENT` and `ENABLE_ORYX_BUILD`. Ensure a previously configured `WEBSITE_RUN_FROM_PACKAGE` setting is removed by the pipeline or configuration transition.

Use this when CI should initiate deployment but Kudu/Oryx should restore or build dependencies. The pipeline artifact must contain source and dependency manifests, not only an incomplete publish directory.

## Deployment Center

With `deployment_method = "deployment_center"`, Terraform creates an App Service source-control binding. Configure either a GitHub repository URL or the complete Azure Repos coordinate set.

GitHub example:

```hcl
app_services = {
  dotnet = {
    enabled                                  = true
    stack                                    = "dotnet"
    kind                                     = "Windows"
    plan_os_type                             = "Windows"
    sku_name                                 = "S1"
    deployment_method                        = "deployment_center"
    deployment_center_repo_url               = "https://github.com/example/web-dotnet"
    deployment_center_azure_repos_branch     = "main"
    deployment_center_use_manual_integration = true
  }
}
```

Azure Repos example:

```hcl
deployment_method                           = "deployment_center"
deployment_center_azure_repos_organization  = "CCOE-Azure"
deployment_center_azure_repos_project       = "IaC"
deployment_center_azure_repos_repository    = "web-ccoedemo-python"
deployment_center_azure_repos_branch        = "main"
deployment_center_use_manual_integration    = true
```

### Manual versus continuous integration

`deployment_center_use_manual_integration = true` creates the repository binding without asking App Service to create a source-provider webhook. A source change does not automatically trigger Deployment Center; start a sync explicitly or use the application pipeline.

`deployment_center_use_manual_integration = false` requests continuous integration. App Service must authorize against the source provider and create a webhook. This is not merely a scheduling switch: the Azure identity applying Terraform must have a usable source-control authorization context.

When Terraform runs as a service principal and App Service attempts to resolve that object as a source-control user, provisioning can fail with error `51004`, for example `Cannot find User with name <service-principal-object-id>`. A public GitHub repository does not remove the webhook authorization requirement. Practical choices are:

- keep manual integration enabled and trigger sync through an authorized process;
- configure Deployment Center interactively with an authorized GitHub identity; or
- use one of the pipeline-owned deployment methods.

Do not set continuous integration to `false` solely to make every push deploy unless the required source-provider authorization is already established.

## Application Pipeline Compatibility

The landing-zone selector configures App Service; it does not dynamically change a sibling repository's GitHub Actions workflow. A pipeline must implement the selected method explicitly.

At the time of this guide, the three sibling application pipelines use these fixed paths:

| Stack repository | Pipeline behavior | Matching method |
| --- | --- | --- |
| `web-ccoedemo-dotnet` | Publishes .NET output and ZIP deploys it | `external_zip_deploy` |
| `web-ccoedemo-node` | Packages the application with production dependencies and ZIP deploys it | `external_zip_deploy` |
| `web-ccoedemo-python` | Vendors Python dependencies, packages them, and enables package mounting | `run_from_package` |

Those pipelines deliberately detach an existing Deployment Center source binding before deploying. Therefore, do not use them as the deployment owner while expecting `deployment_center` to remain the source of truth. To support multiple methods from one application workflow, add an explicit workflow input or environment variable and branch the packaging, App Service settings, and deploy command together.

## Health Checks

Each enabled app can set `health_check_path = "/health"`. The application endpoint must return a `200`-`299` response only when ready, respond quickly, avoid redirects, and perform lightweight checks. App Service authentication must allow the platform probe to reach the endpoint. Only truly critical dependencies should affect readiness; nonessential dependency failures can otherwise evict healthy instances.

`health_check_eviction_time_in_min` is optional and defaults to five minutes when a health path is set.

## Troubleshooting

- Azure placeholder page with no deployment history: the site is running, but Deployment Center has not synchronized content.
- `Cannot find User with name <object-id>` during source-control creation: continuous Deployment Center authorization is trying to use a service principal as a source-control user; use manual integration or establish an authorized user-backed connection.
- `503 Service Unavailable`: inspect startup logs, startup command, runtime version, package contents, and App Service plan quota. A Deployment Center binding alone does not prove that runnable content was deployed.
- Package starts locally but not in Azure: verify that the chosen method matches the artifact. Do not expect remote dependency restoration under either prebuilt ZIP method.

## Consistency Rules

- Configure exactly one method per app.
- Omit Deployment Center repository fields for pipeline-owned methods; they have no effect there and create misleading configuration.
- Do not combine `WEBSITE_RUN_FROM_PACKAGE=1` with remote-build settings.
- Do not run a package-deployment pipeline against an app whose active deployment owner is Deployment Center.
- Keep stack-specific build and startup details in the application repo; keep the deployment contract identical across stacks.
