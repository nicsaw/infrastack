# Kubernetes

This directory contains the Kustomize configuration for the InfraStack K3s homelab.

## Directory Structure

- `bootstrap` contains the Argo CD Application applied once to start GitOps
- `clusters/homelab` composes everything deployed to the single K3s cluster
- `infrastructure` contains shared cluster capabilities
- `apps` contains application workloads

Bootstrap Argo CD after installation:

```bash
kubectl apply --filename kubernetes/bootstrap/argocd-application.yaml
```

Render the complete configuration from the repository root:

```bash
kubectl kustomize kubernetes/clusters/homelab
```

## Private Application Access

Create Homepage's runtime host configuration from the Tailscale installation in WSL:

```bash
TAILSCALE_HOST="$(tailscale status --json | jq --raw-output '.Self.DNSName | rtrimstr(".")')"
sudo kubectl create configmap homepage-runtime \
  --from-literal="external-host=${TAILSCALE_HOST}" \
  --dry-run=client \
  --output=yaml | \
  sudo kubectl apply --filename -
```

The ConfigMap must exist before Homepage can start. It is runtime configuration and is intentionally not managed by Argo CD.

Traefik routes applications by path. Publish the Traefik listener privately through Tailscale:

```bash
sudo tailscale serve --bg http://127.0.0.1:80
tailscale serve status
```

Open the HTTPS URL reported by `tailscale serve status`. Applications discovered from Gateway API routes appear there automatically. MeTube is available by appending `/metube/` to that URL.

Tailscale is the private remote-access path, not the local firewall boundary. Traefik continues to listen on port 80 inside WSL, so treat the Windows and WSL host as trusted or restrict that port with the host firewall.

Remove the private proxy when it is no longer needed:

```bash
sudo tailscale serve reset
```
