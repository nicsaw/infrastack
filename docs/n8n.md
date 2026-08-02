# n8n on K3s

InfraStack can deploy n8n, PostgreSQL, and an external task-runner sidecar as an
optional Argo CD application. The existing Docker Compose service is unchanged.

## Configure

n8n is disabled by default. Add the installation-specific values to the ignored
`config.yaml`:

```yaml
n8n_enabled: true
n8n_hostname: n8n.example.net
n8n_timezone: Australia/Sydney
```

InfraStack fixes the implementation conventions:

- namespace and Argo CD Application: `n8n`
- Gateway: `default/homelab`
- route: HTTPS on the configured hostname at `/`
- trusted proxy chain: Cloudflare Tunnel then Traefik
- one n8n main replica with an external task-runner sidecar
- PostgreSQL database and user: `n8n`
- n8n, task-runner, and PostgreSQL images: versioned in Git

Only installation differences remain configurable:

- enable or disable n8n
- public hostname
- timezone
- existing encryption key for migration
- storage class and volume sizes
- CPU and memory requests and limits

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

Ansible creates the `n8n` namespace, runtime configuration, Secrets, fixed
Gateway API route, and a dedicated Argo CD Application for
`kubernetes/apps/n8n`.

Setting `n8n_enabled: false` removes the running application and route while
retaining the Secret and persistent volumes.

## Verify

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
http://n8n.n8n.svc.cluster.local:5678
```

Test the Traefik route locally before switching public DNS:

```bash
curl -fsS \
  -H 'Host: n8n.example.net' \
  http://127.0.0.1/healthz
```

## Public cutover

Point the configured hostname at the Cloudflare Tunnel origin that reaches the
InfraStack Traefik Gateway.

Stop the Compose n8n service before restoring its database or enabling workflows
in K3s so both instances do not process triggers simultaneously.

The bootstrap verifies the Kubernetes rollout and the local Gateway route. Test
the public HTTPS endpoint after DNS and Cloudflare are configured:

```bash
curl -fsS https://n8n.example.net/healthz
```
