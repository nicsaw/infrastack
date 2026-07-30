# pgAdmin on K3s

InfraStack deploys pgAdmin 4 through Argo CD and Kustomize. It is available privately at:

```text
https://<TAILSCALE_HOSTNAME>/pgadmin/
```

## Install

Run the normal host reconciler:

```bash
./bootstrap.sh
```

Ansible creates the `pgadmin-auth` Secret once, then Argo CD deploys pgAdmin with a persistent `local-path` volume.

## Login

Read the initial email:

```bash
sudo kubectl get secret pgadmin-auth \
  --namespace=default \
  --output=jsonpath='{.data.PGADMIN_DEFAULT_EMAIL}' \
  | base64 --decode
echo
```

Read the initial password:

```bash
sudo kubectl get secret pgadmin-auth \
  --namespace=default \
  --output=jsonpath='{.data.PGADMIN_DEFAULT_PASSWORD}' \
  | base64 --decode
echo
```

Change the password in pgAdmin after the first login.

## Verify

```bash
sudo kubectl rollout status deployment/pgadmin \
  --namespace=default \
  --timeout=5m

sudo kubectl get pod,service,pvc,httproute \
  --namespace=default \
  --selector=app.kubernetes.io/name=pgadmin
```

For a local fallback:

```bash
sudo kubectl port-forward service/pgadmin 8080:8080
```

Then open `http://localhost:8080/pgadmin/`.

## Database connections

This change deploys pgAdmin, not PostgreSQL. The existing Docker Compose PostgreSQL service is isolated on its Compose network and is not automatically registered in K3s pgAdmin. Add database servers manually using an address that is reachable from the K3s pod network, or migrate PostgreSQL into Kubernetes separately.

The `pgadmin-data` PVC is annotated with `Prune=false`, so disabling or removing the app does not automatically delete pgAdmin's saved connections and preferences.

## Legacy Compose service

The old Compose pgAdmin service remains available only through the `legacy` profile:

```bash
docker compose --profile legacy up -d pgadmin4
```

Stop the legacy container after the K3s deployment is verified:

```bash
docker compose stop pgadmin4
docker compose rm -f pgadmin4
```
