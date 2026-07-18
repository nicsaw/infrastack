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
