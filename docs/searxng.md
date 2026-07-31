# SearXNG on K3s

InfraStack deploys SearXNG through Argo CD and Kustomize.

```text
https://<TAILSCALE_HOSTNAME>/searxng/
```

The deployment enables both HTML and JSON search output. Kubernetes workloads can use the internal endpoint:

```text
http://searxng.default.svc.cluster.local:8080
```

## Install

Run the normal host reconciler after the change reaches `main`:

```bash
./bootstrap.sh
```

SearXNG generates a fresh cryptographic secret when its pod starts. Its disposable configuration is rendered into an `emptyDir`, while `/var/cache/searxng` uses a 1 GiB `local-path` volume.

## Verify

```bash
sudo kubectl rollout status deployment/searxng \
  --namespace=default \
  --timeout=5m

sudo kubectl get pod,service,pvc,httproute \
  --namespace=default \
  --selector=app.kubernetes.io/name=searxng

curl -fsS \
  'https://<TAILSCALE_HOSTNAME>/searxng/search?q=kubernetes&format=json'
```

The existing Docker Compose service remains available during migration.
