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

Traefik routes applications by path. Publish the Traefik listener privately through the Tailscale installation in WSL:

```bash
sudo tailscale serve --bg http://127.0.0.1:80
tailscale serve status
```

Open Homepage at <https://rogwsl.tail9ac68b.ts.net/>. Applications discovered from Gateway API routes appear there automatically. MeTube is available directly at <https://rogwsl.tail9ac68b.ts.net/metube/>.

Remove the private proxy when it is no longer needed:

```bash
sudo tailscale serve reset
```
