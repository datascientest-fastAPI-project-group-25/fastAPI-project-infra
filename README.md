# FastAPI Project Infrastructure

Terraform infrastructure for the **DataScientest Group 25 bootcamp team project**.
This repository is the infrastructure part of a three-repository learning project,
not a claim of a currently running AWS service or production readiness.

## Contribution and team context

[Oluwatoyin Balogun (TYBies)](https://github.com/TYBies) confirms responsibility
for the bootcamp's Terraform/AWS infrastructure, S3 remote state, GitHub Actions
OIDC/IAM integration, and hands-on Kubernetes application deployments and Services.
These are training-project responsibilities, not sole authorship of the application
or the whole team's delivery pipeline.

Repository evidence includes [infrastructure fixes](https://github.com/datascientest-fastAPI-project-group-25/fastAPI-project-infra/commit/163765bfe926d8c14a33f625bab3a884ef3fbbca)
and [infrastructure documentation](https://github.com/datascientest-fastAPI-project-group-25/fastAPI-project-infra/commit/e70a611fbe10a184051b309a941ee0123e551e4e),
both attributed by GitHub to TYBies. Commit history supports specific contributions;
it is not a measure of expertise or proof of current deployment health.

## Architecture and repository boundaries

| Repository | Responsibility |
| --- | --- |
| [app](https://github.com/datascientest-fastAPI-project-group-25/fastAPI-project-app) | FastAPI/React application, tests and container-image workflows |
| [release](https://github.com/datascientest-fastAPI-project-group-25/fastAPI-project-release) | Helm chart, environment values and image-tag updates |
| **infra (this repository)** | AWS networking/EKS, IAM, Terraform state, Kubernetes foundations and Argo CD setup |

```text
app source -> GitHub Actions -> frontend/backend images in GHCR
                              -> release repository image-tag updates
release Helm chart/values -> Argo CD -> Kubernetes workloads and Services
infra Terraform -> AWS VPC/EKS + IAM + Kubernetes/Argo CD foundations
GitHub Actions -> AWS IAM via OIDC; Terraform -> S3 remote state
```

This is the intended integration visible in source, not a verified live end-to-end
pipeline. OIDC here concerns GitHub Actions authenticating to AWS; it does **not**
establish how Argo CD authenticates to Git or how GHCR image pulls authenticate.

### Source map

| Path | What to inspect |
| --- | --- |
| [`bootstrap/`](bootstrap/) | AWS and LocalStack bootstrap approaches and supporting documentation |
| [`bootstrap/modules/state/main.tf`](bootstrap/modules/state/main.tf) | S3 state bucket, versioning/encryption/public-access configuration and DynamoDB locking resources |
| [`terraform/environments/deploy/stg/`](terraform/environments/deploy/stg/) / [`prod/`](terraform/environments/deploy/prod/) | Staging/production Terraform roots with S3 backends |
| [`terraform/modules/`](terraform/modules/) | VPC, EKS, IAM, security, Kubernetes resources, Argo CD, External Secrets and GHCR-secret modules |
| [`terraform/modules/argo/main.tf`](terraform/modules/argo/main.tf) | Argo CD Helm release and ApplicationSet generation |
| [ApplicationSet template](terraform/modules/argo/templates/application-set.yml) | Release repo `main`, `charts/fastapi`, environment value-file selection and automated sync policy |
| [Terraform workflow](.github/workflows/terraform.yml) | AWS credential configuration, PR planning and main-branch deployment logic |

The staging root explicitly selects **in-cluster PostgreSQL**, not RDS. The old
`clean-deploy/` directory layout and RDS claims are not the current source layout.
Bootstrap code declaring locking/versioning is not evidence that those settings
are currently enabled in an AWS account.

## Safe local validation (no AWS account required)

Clone this repository and run commands from its root:

```bash
git clone https://github.com/datascientest-fastAPI-project-group-25/fastAPI-project-infra.git
cd fastAPI-project-infra
```

Prerequisites for the following checks: Python 3 and the `python-hcl2` and `PyYAML`
parser packages in an isolated, trusted local environment. The documentation review
used Python 3.13, python-hcl2 8.1.4 and PyYAML 6.0.3. These checks read source only;
they do not import providers, initialise a backend or execute deployment scripts.

```bash
python3 - <<'PY'
from pathlib import Path
import subprocess
import hcl2
paths = subprocess.check_output(["git", "ls-files"], text=True).splitlines()
files = [Path(p) for p in paths if p.endswith((".tf", ".tfvars", ".hcl"))]
for path in files:
    hcl2.loads(path.read_text())
print(f"Parsed {len(files)} HCL files")
PY
```

```bash
python3 - <<'PY'
from pathlib import Path
import subprocess
import yaml
paths = subprocess.check_output(["git", "ls-files"], text=True).splitlines()
files = [Path(p) for p in paths if p.endswith((".yml", ".yaml"))
         and not p.startswith("charts/fastapi/templates/") and not Path(p).is_symlink()]
for path in files:
    list(yaml.safe_load_all(path.read_text()))
print(f"Parsed {len(files)} YAML files (Helm templates excluded)")
PY
```

**Observed at baseline `ad27179`:** 66 HCL files and 11 YAML files parsed.
Terraform CLI was unavailable, so `terraform fmt` and `terraform validate` were
**not run**. Parser success does not validate provider schemas, module arguments,
IAM permissions or Kubernetes connectivity. No `terraform init`, plan, apply,
AWS CLI request or cluster operation was used for this review.

## Known baseline limitations before deployment

- The ApplicationSet template selects `values.${environment}.yaml`, while the
  release chart contains `values-stg.yaml` and `values-prod.yaml`; release automation
  updates a second set under `config/helm/`. Reconcile these paths before syncing.
- The Argo module creates `argocd-${environment}`, while its ApplicationSet template
  names namespace `argocd`. Resolve namespace ownership before deployment.
- `PLAN.md` is a broken tracked symlink in a fresh clone. Use the documentation
  links below rather than treating that path as a setup prerequisite.
- Saved Terraform plans are tracked in the baseline and contain embedded state.
  They are not safe onboarding artifacts: do not apply, copy or republish them.
  Maintainers should review/remove sensitive artifacts and assess any required
  credential rotation separately; this README-only change does not remediate history.
- The PR Terraform workflow configures AWS credentials even for documentation
  changes. This documentation review skips CI explicitly rather than attempting
  cloud validation. Required checks may therefore remain pending.

## Deployment prerequisites — separate, maintainer-reviewed work

An actual deployment needs an approved AWS account and budget, reviewed IAM trust
and permissions, a chosen Terraform/provider version set, a configured state
backend, container-registry access, and reviewed Kubernetes/Argo CD integration.
Do not use committed example passwords or assume checked-in plans are current.
Review scripts before execution: bootstrap, deploy, destroy and state-unlock
commands can change cloud resources or state. LocalStack exercises are not proof
that AWS deployment works.

## Team documentation

These existing guides retain the team's detailed operational context. Some reflect
older layouts; compare every command with the current tree before running it.

- [Infrastructure guide](INFRASTRUCTURE.md)
- [Bootstrap guide](bootstrap/README.md)
- [Deployment environment guide](terraform/environments/deploy/README.md)
- [State module guide](terraform/modules/terraform-state/README.md)
- [Deployment helpers](scripts/deployment/README.md)
- [Monitoring helpers](scripts/monitoring/README.md)
- [Branching and contribution workflow](BRANCHING.md)
- [Earlier README and command tables](https://github.com/datascientest-fastAPI-project-group-25/fastAPI-project-infra/blob/ad2717913a1620d6550e52eb472ee5f7737563e6/README.md) — historical reference, not a validated runbook

Contribute through a scoped PR; do not merge or deploy merely to verify this README.
See [LICENSE](LICENSE).
