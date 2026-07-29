# GitHub Actions runners on K3s

InfraStack can deploy GitHub Actions Runner Controller (ARC) with an ephemeral runner scale set in Kubernetes mode. The ARC controller runs in `arc-systems`; the listener, runner pods, and container-job pods run in `arc-runners`.

## Authentication

Create a fine-grained personal access token for the target repository with:

- Repository access limited to the target repository.
- `Administration: Read and write` repository permission.

Keep the token out of Git. Copy the local configuration and restrict its file permissions:

```bash
cp config.example.yml config.yml
chmod 600 config.yml
```

Set the following values in `config.yml`:

```yaml
github_runners_enabled: true
github_runners_config_url: https://github.com/nicsaw/spearhead
github_runners_scale_set_name: homelab-runners
github_runners_min: 0
github_runners_max: 3
github_runners_token: github_pat_REPLACE_ME
```

Then reconcile the host:

```bash
./bootstrap.sh
```

The playbook creates the Kubernetes authentication secret without committing it, then creates two Argo CD Applications pinned to ARC chart version `0.14.2`.

## Verification

```bash
sudo kubectl get applications -n argocd
sudo kubectl get pods -n arc-systems
sudo kubectl get pods -n arc-runners
sudo kubectl get autoscalingrunnersets -n arc-runners
```

The scale set intentionally keeps zero idle runners. A runner pod appears only when GitHub assigns a job.

## Workflow requirements

Target the scale set by name and declare a job container. Kubernetes mode rejects jobs without a `container:` declaration by default.

```yaml
jobs:
  test:
    runs-on: homelab-runners
    container:
      image: node:22-bookworm
    steps:
      - uses: actions/checkout@v4
      - run: corepack enable
      - run: pnpm install --frozen-lockfile
      - run: pnpm test
```

Container jobs and service containers run as separate pods and share a dynamically provisioned `local-path` work volume. Each runner receives its own 2 GiB claim.

## Docker image builds

Kubernetes mode does not provide a Docker daemon. Workflows using `docker build`, Docker Compose, or `docker/build-push-action` must remain on the legacy Compose runners until they are migrated to a Kubernetes-native image builder such as rootless BuildKit.

Do not set `ACTIONS_RUNNER_REQUIRE_JOB_CONTAINER=false`. Doing so lets workflow steps execute in the runner pod that owns the Kubernetes API permissions used to create job pods.
