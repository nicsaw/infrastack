# Kubernetes

This directory contains the Kustomize configuration for the InfraStack K3s homelab.

## Layout

- `clusters/homelab` composes everything deployed to the single K3s cluster.
- `platform` contains shared cluster capabilities.
- `apps` contains application workloads migrated from Docker Compose.

Render the complete configuration from the repository root:

```bash
kubectl kustomize kubernetes/clusters/homelab
```

The initial scaffold renders no resources. Add platform capabilities and applications through separate, reviewable migrations. Keep the matching Compose service available until its Kubernetes migration and rollback procedure have been verified.
