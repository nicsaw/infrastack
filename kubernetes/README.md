# Kubernetes

This directory contains the reusable Kustomize configuration for the InfraStack K3s homelab.

## Directory structure

- `clusters/homelab` composes everything deployed to the single K3s cluster.
- `infrastructure` contains shared cluster capabilities.
- `apps` contains application workloads.

Render the complete configuration from the repository root:

```bash
kubectl kustomize kubernetes/clusters/homelab
```

## Configuration ownership

Run `./bootstrap.sh` from the repository root to install and configure the server.

Ansible owns:

- Tailscale, K3s and Argo CD installation.
- The Argo CD Application pointing at the cloned repository.
- The machine-specific `homepage-runtime` ConfigMap.
- Tailscale Serve.

Argo CD owns the reusable resources rendered from `kubernetes/clusters/homelab`.

The runtime ConfigMap exists before Argo CD deploys Homepage, preventing a missing-ConfigMap startup failure.

## Private application access

The bootstrap configures Traefik behind private Tailscale HTTPS:

```text
https://server-name.example-tailnet.ts.net/
https://server-name.example-tailnet.ts.net/metube/
```

The installer prints the concrete URLs only after both routes return HTTP 200. Tailscale is the private remote-access path, while Traefik continues to route applications inside the cluster.
