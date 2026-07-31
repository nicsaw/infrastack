# n8n on K3s

InfraStack can deploy n8n, PostgreSQL, and an external task-runner sidecar as an
optional Argo CD application. The existing Docker Compose service is unchanged.

## Configure

n8n is disabled by default. Add overrides to the ignored `config.yaml`:

```yaml
n8n_enabled: true
n8n_namespace: n8n
n8n_timezone: Australia/Sydney

# Enable only when DNS and the Gateway route are ready.
n8n_route_enabled: true
n8n_hostname: n8n.example.net
n8n_protocol: https
n8n_proxy_hops: 1
n8n_gateway_name: homelab
n8n_gateway_namespace: default
```

The defaults can also be overridden for:

- n8n, task-runner, and PostgreSQL images
- storage class and volume sizes
- CPU and memory requests and limits
- namespace, hostname, proxy count, and timezone
- optional external health verification

See `config.example.yaml` for every supported setting.

## Preserve existing credentials

Before migrating an existing instance, set its current encryption key before the
first K3s deployment:

```yaml
n8n_encryption_key: "REPLACE_WITH_EXISTING_KEY"
```

Read the current key from Compose:

```bash
docker compose exec -T n8n cat /home/node/.n8n/config
```

The key must match the existing instance before restoring its PostgreSQL data,
or n8n cannot decrypt saved credentials.

## Install

```bash
./bootstrap.sh
```

Ansible creates runtime configuration and secrets, then creates a dedicated Argo
CD Application for `kubernetes/apps/n8n`. Setting `n8n_enabled: false` removes the
running n8n workloads and route while preserving Secrets and persistent volumes.

## Verify

With the default namespace:

```bash
sudo kubectl rollout status statefulset/n8n-postgres \
  --namespace=n8n \
  --timeout=10m

sudo kubectl rollout status deployment/n8n \
  --namespace=n8n \
  --timeout=10m
```

The internal Service is:

```text
http://n8n.<NAMESPACE>.svc.cluster.local:5678
```

When routing is enabled, test Traefik locally:

```bash
curl -fsS \
  -H 'Host: <N8N_HOSTNAME>' \
  http://127.0.0.1/healthz
```

## Public cutover

Point the chosen hostname at the proxy that reaches the configured Kubernetes
Gateway. Stop the Compose n8n service before restoring its database or enabling
workflows in K3s so both instances do not process triggers simultaneously.
