# App Service Authentication

The landing zone creates one Microsoft Entra app registration per enabled App Service when `enable_app_registration_for_appservice = true`. Authentication behavior is selected globally with `app_service_auth_mode`; each application then uses the same client configuration while retaining stack-specific MSAL implementation details in its own repository.

## Authentication Modes

| Mode | App Service Easy Auth | Application-managed MSAL | Intended behavior |
| --- | --- | --- | --- |
| `none` | Disabled | Disabled by landing-zone configuration | No platform or app-managed Entra authentication |
| `easy_auth` | Enabled | Not required | App Service validates/authenticates requests before the app |
| `msal` | Disabled | Enabled | The application owns sign-in, callback, session, and sign-out behavior |
| `both` | Enabled | Enabled | Easy Auth may expose platform identity while the app also supports its MSAL session |

If app registration creation is disabled, the effective authentication mode becomes `none`. If it is enabled while `app_service_auth_mode = "none"`, the effective mode becomes `msal` so the created registration is usable by the application.

## Core Configuration

```hcl
enable_app_registration_for_appservice = true
app_service_auth_mode                  = "both"
app_service_allow_anonymous            = true
app_service_unauthenticated_action     = "AllowAnonymous"
app_registration_create_client_secret  = true
app_registration_web_redirect_uris     = []
```

For every enabled app, the root module supplies:

- `AAD_TENANT_ID`
- `AAD_CLIENT_ID`
- `AAD_CLIENT_SECRET` when secret creation is enabled
- `AAD_REDIRECT_PATH=/auth/callback`
- `AAD_SCOPES=User.Read`
- `MICROSOFT_PROVIDER_AUTHENTICATION_SECRET` for Easy Auth when a client secret exists

Python additionally receives `FLASK_SECRET_KEY`, and Node receives `SESSION_SECRET`, from `app_service_app_secret_key`. Store a strong environment-specific value outside version control; the example value is a placeholder, not a production secret.

Generated redirect URIs are derived for each app registration. Use `app_registration_web_redirect_uris` only for additional explicit URIs that the application genuinely needs.

## Anonymous Access and Sign-In

`app_service_allow_anonymous` and `app_service_unauthenticated_action` control unauthenticated requests only when Easy Auth is active (`easy_auth` or `both`). The explicit action takes precedence in the app-service module.

- `AllowAnonymous` lets requests reach the application; the app may then offer MSAL sign-in.
- `RedirectToLoginPage` makes Easy Auth redirect unauthenticated browser requests.
- `Return401` or `Return403` rejects unauthenticated requests without a browser redirect.

For the demo apps in `both` mode, `AllowAnonymous` is intentional: the landing page and `/health` remain reachable, and the application-managed MSAL buttons control the interactive session. Once an MSAL profile exists, the application UI should show the active session and sign-out control, not additional sign-in buttons.

## Health Endpoint Requirement

Every application configured with `health_check_path = "/health"` must expose `/health` with these properties:

- return `200`-`299` only when the application is ready;
- never redirect to a login or another URL;
- remain reachable through App Service authentication;
- respond quickly using lightweight checks; and
- check only truly critical dependencies.

With Easy Auth set to redirect or reject all anonymous traffic, verify the App Service health probe behavior before enabling eviction. The current landing-zone demo configuration uses `AllowAnonymous`, allowing `/health` to reach the app without weakening the application's own authorization rules for protected routes.

## Choosing a Mode

- Use `easy_auth` when platform-managed authentication is the sole gate and the app does not need to own an MSAL session.
- Use `msal` when each stack owns the full authentication flow and platform authentication would interfere with callbacks or health checks.
- Use `both` only when both identities are intentional and tested; otherwise it can produce two independent session concepts.
- Use `none` only for an intentionally unauthenticated app or when authentication is enforced elsewhere.

Authentication and deployment are independent. Changing between Deployment Center, ZIP deploy, or run-from-package does not change redirect URIs, client IDs, secrets, or session behavior. A deployment pipeline must preserve required environment settings and must never package secrets into the artifact.

## Validation Checklist

- The registration redirect URI exactly matches the deployed app callback URL.
- Secrets are stored in Terraform/Azure secret storage and are not committed.
- `/health` returns directly without authentication redirect.
- Signed-out behavior matches the selected unauthenticated action.
- Signed-in behavior is consistent across .NET, Python, and Node.
- An existing application MSAL session hides duplicate sign-in actions.
- Sign-out clears the application session and returns to the expected landing page.
