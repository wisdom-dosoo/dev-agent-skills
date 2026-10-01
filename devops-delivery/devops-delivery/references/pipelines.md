# Pipelines (simplest target that fits)

## Ladder (climb only when forced)

1. **PaaS (Vercel / Render / Fly / Railway).** Default for MVPs and small teams: git-push deploys, managed TLS, preview environments. Move on when: you need VPC peering, exotic runtimes, or costs diverge wildly.
2. **Single host / containers on PaaS (Fly Machines, Render Docker).** Same workflow, your Dockerfile. Move on when: multi-service orchestration or strict resource isolation is required.
3. **Managed Kubernetes / Terraform.** Only with a forcing reason: dedicated compliance, complex service mesh needs, or a platform team to own it. K8s without an owner becomes a second product you did not plan.

## CI pipeline shape (see `templates/ci.yml`)

```
lint → type-check/test → build → secrets/container scan → deploy staging → smoke test → promote production
```

- Every step after `build` operates on the *same artifact* (image digest), never a rebuild.
- Staging auto-deploys from main; production promotes a named artifact (tag/SHA) with one approval. Direct-to-prod pipelines are forbidden.
- Pipeline fails on: lint/type/test failure, High/Critical audit finding, container-check FAIL, smoke-test failure. Each gate names its rerun command.

## Environments

- Minimum: staging + production with separate credentials, separate data, separate secret scopes. One identity per environment; staging keys never work in prod.
- Parity: staging runs the same image shape as prod (same Dockerfile, smaller size). "Works on staging" must mean something.
- Preview environments per PR for frontend/full-stack PaaS targets; tear down automatically.

## Rollback (write before merging)

| Target | Rollback |
|---|---|
| PaaS | Instant revert to previous deployment in dashboard / CLI; record the deployment ID in the release note |
| Containers | Redeploy the previous image tag (tags recorded in the release log; keep N-2) |
| Migrations involved | Backward-compatible schema first; app rollback must tolerate the newer schema (expand → migrate → contract) |

After every production deploy: healthcheck green + smoke test + owner named for 24h. No owner, no deploy.

## Anti-recommendations

- Do not adopt Kubernetes "for scale" without numbers and without an owner.
- Do not rebuild per environment. Promote the tested artifact.
- Do not run migrations inside app boot. Separate job, separate logs, separate rollback story.
