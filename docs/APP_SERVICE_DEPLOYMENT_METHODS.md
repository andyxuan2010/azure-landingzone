# App Service Deployment Methods

This document compares the three deployment patterns currently modeled in the landing zone for App Service workloads:

- `deployment_center`
- `run_from_package`
- `zip_deploy_with_build`

The goal is to clarify which system delivers the app content, where the build happens, and which settings or pipelines are expected for each pattern.

## Summary Table

| Method | Source of app content | Where build happens | Repo binding in App Service | Typical App Service settings | Best fit |
|---|---|---|---|---|---|
| `deployment_center` | Azure Repos or GitHub repo bound in App Service | App Service / Oryx after repo sync | Yes | `SCM_DO_BUILD_DURING_DEPLOYMENT=true`, `ENABLE_ORYX_BUILD=true`, no `WEBSITE_RUN_FROM_PACKAGE` | Teams that want App Service to pull directly from source control |
| `run_from_package` | Fully built ZIP package | CI pipeline or manual packaging before deploy | No | `WEBSITE_RUN_FROM_PACKAGE=1`, package-friendly startup command, no remote build settings | Immutable package deployment with a self-contained artifact |
| `zip_deploy_with_build` | ZIP package of app source | App Service / Oryx after ZIP upload | No | `SCM_DO_BUILD_DURING_DEPLOYMENT=true`, often `ENABLE_ORYX_BUILD=true`, no `WEBSITE_RUN_FROM_PACKAGE` | ZIP deployment without repo binding when you still want App Service to build after upload |

## 1. `deployment_center`

### How it works

App Service is connected to a repository through Deployment Center. App Service pulls the selected branch and builds the app remotely.

### In this landing zone

This is the root-modeled Terraform option:

- `deployment_method = "deployment_center"`

The root App Service wiring then enables Deployment Center and passes repository details into the app module.

### Expectations

- App Service owns the repo connection
- Build happens on the Azure side
- You should not also rely on `WEBSITE_RUN_FROM_PACKAGE=1`

### Best use case

- You want the platform to pull code directly from Azure Repos
- You are comfortable with App Service as the deployment orchestrator

## 2. `run_from_package`

### How it works

A fully runnable ZIP package is produced outside App Service and then deployed to the web app. App Service mounts the package directly instead of building from source.

### In this landing zone

This is the root-modeled Terraform option:

- `deployment_method = "run_from_package"`

The root module sets:

- `WEBSITE_RUN_FROM_PACKAGE=1`

### Expectations

- The package must already contain the app files and dependencies
- No remote Oryx build should be required
- For Python, the package usually needs:
  - `app.py`
  - `requirements.txt`
  - `templates/`
  - `static/`
  - vendored dependencies such as `.python_packages/lib/site-packages`

### Python-specific note

This method is stricter for Python than for some other stacks. If the ZIP is not self-contained, the app can fail at startup because App Service is not expected to install dependencies for you.

### Best use case

- You want immutable artifact deployment
- You want CI to fully control package creation
- You want the deployed package to be the source of truth

## 3. `zip_deploy_with_build`

### How it works

A ZIP file is still uploaded with `az webapp deploy`, but App Service does not treat it as a final runnable mounted package. Instead, Kudu and Oryx extract the ZIP and build it on the server after upload.

### In this landing zone

This is now a root-level Terraform `deployment_method` value and is a real operational pattern already used by sibling application repositories.

Typical settings:

- `SCM_DO_BUILD_DURING_DEPLOYMENT=true`
- `ENABLE_ORYX_BUILD=true`
- no `WEBSITE_RUN_FROM_PACKAGE`

### Expectations

- No App Service repo binding is required
- ZIP upload still goes through the Kudu / SCM endpoint
- Python dependencies are installed remotely by App Service during deployment

### Best use case

- You want ZIP-based deployment
- You do not want Deployment Center repo binding
- You want Azure to handle Python build/install after upload

## Deployment Center Troubleshooting Note

When `deployment_method = "deployment_center"` is configured and the App Service itself shows `Running`, the website can still serve only the default Azure placeholder page instead of the application.

That symptom usually means:

- the App Service platform is healthy
- the runtime is configured
- but the repo content did not actually sync into the site

Typical indicators:

- the homepage shows the standard "Your web app is running and waiting for your content" Azure page
- `az webapp log deployment list` returns an empty array for the target app
- Deployment Center is configured, but there is no successful sync/deployment record

In that state, the problem is usually the Deployment Center content sync, not the app startup code itself.

## Side-by-Side for the Current Python App

For the sibling Python app repo:

- `deployment_center`
  - App Service binds to the `web-ccoedemo-python` repo
  - App Service pulls source and runs remote build
  - Use when the landing zone app is configured for Deployment Center

- `run_from_package`
  - The package pipeline builds a self-contained ZIP
  - The package is pushed to the App Service
  - Use when the landing zone app is configured with `WEBSITE_RUN_FROM_PACKAGE=1`

- `zip_deploy_with_build`
  - A pipeline uploads ZIP source content
  - App Service performs Oryx build after upload
  - Use when you want ZIP deployment without repo binding and without self-contained package strictness

## Decision Guide

- Choose `deployment_center` when you want Azure Repos integration directly in App Service.
- Choose `run_from_package` when you want a fully built immutable package produced by CI.
- Choose `zip_deploy_with_build` when you want a ZIP-based deployment flow but still want App Service to build dependencies remotely. This is especially common for Python, but the same pattern can be used for Node.js and .NET sibling app repositories when you want App Service to handle post-upload build/start preparation instead of a fully prebuilt package.

## Current Repo Notes

- The root landing zone currently models:
  - `deployment_center`
  - `run_from_package`
  - `zip_deploy_with_build`

- The sibling Python repo currently carries a package deployment pipeline intended for:
  - `run_from_package`

- The older working Python deployment pattern in the sibling repo corresponds to:
  - `zip_deploy_with_build`

## Important Warning

Do not combine these methods for the same App Service at the same time.

Examples of conflicting combinations:

- `WEBSITE_RUN_FROM_PACKAGE=1` together with remote Oryx build expectations
- Deployment Center repo binding together with package-mounted deployment as the active source of truth

Pick one deployment path per app and keep Terraform, App Service settings, and the application pipeline aligned to that one path.
