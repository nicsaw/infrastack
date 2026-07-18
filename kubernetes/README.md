# Kubernetes

This directory contains the Kustomize configuration for the InfraStack K3s homelab.

## Directory Structure

- `clusters/homelab` composes everything deployed to the single K3s cluster
- `platform` contains shared cluster capabilities
- `apps` contains application workloads

Render the complete configuration from the repository root:

```bash
kubectl kustomize kubernetes/clusters/homelab
```
