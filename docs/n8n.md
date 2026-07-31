# n8n on K3s

InfraStack deploys n8n and a dedicated PostgreSQL instance through Argo CD and
Kustomize.

```text
https://n8n.nicholassaw.com/
```

The existing Docker Compose service remains unchanged during migration.

## Install

For a fresh n8n instance, run:

```bash
./bootstrap.sh
```

Ansible creates the `n8n` namespace and the `n8n-secrets` Secret once. Argo CD
then deploys PostgreSQL, n8n, an external task-runner sidecar, persistent n8n
data, and a persistent `/files` volume.

## Preserve existing credentials

When migrating the existing Compose instance, set its current encryption key in
the ignored `config.yaml` before the first bootstrap:

```yaml
n8n_encryption_key: "REPLACE_WITH_EXISTING_KEY"
```

Read the current key from the Compose volume:

```bash
docker compose exec -T n8n \
  cat /home/node/.n8n/config
```

The key must match the existing instance before restoring its PostgreSQL
database, otherwise n8n cannot decrypt stored credentials.

## Verify

```bash
sudo kubectl rollout status statefulset/n8n-postgres \
  --namespace=n8n \
  --timeout=10m

sudo kubectl rollout status deployment/n8n \
  --namespace=n8n \
  --timeout=10m

curl -fsS \
  -H 'Host: n8n.nicholassaw.com' \
  http://127.0.0.1/healthz
```

Kubernetes workloads can use:

```text
http://n8n.n8n.svc.cluster.local:5678
```

## Cloudflare cutover

The `HTTPRoute` accepts `n8n.nicholassaw.com` and forwards it to the n8n
Service. After the K3s deployment is verified, update the existing Cloudflare
Tunnel public hostname so its origin reaches Traefik on the K3s host instead of
the Compose n8n container.

Stop the Compose n8n service before restoring its database or enabling workflows
in K3s to avoid duplicate trigger execution.
