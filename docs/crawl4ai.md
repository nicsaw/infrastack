# Crawl4AI on K3s

InfraStack deploys Crawl4AI through Argo CD and Kustomize.

```text
https://<TAILSCALE_HOSTNAME>/crawl4ai/
```

The public health endpoint is available at `/crawl4ai/health`. Other API endpoints require the generated bearer token.

## Install

Run the normal host reconciler after the change reaches `main`:

```bash
./bootstrap.sh
```

Ansible creates the `crawl4ai-auth` Secret once. Argo CD then deploys the authenticated Crawl4AI API with a private 1 GiB shared-memory volume and ephemeral runtime storage.

## API token

```bash
CRAWL4AI_API_TOKEN="$(
  sudo kubectl get secret crawl4ai-auth \
    --namespace=default \
    --output=jsonpath='{.data.CRAWL4AI_API_TOKEN}' \
    | base64 --decode
)"
```

## Test

```bash
curl -fsS \
  "https://<TAILSCALE_HOSTNAME>/crawl4ai/health"

curl -fsS \
  -X POST \
  "https://<TAILSCALE_HOSTNAME>/crawl4ai/crawl" \
  -H "Authorization: Bearer ${CRAWL4AI_API_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{"urls":["https://example.com"]}'
```

Kubernetes workloads can use:

```text
http://crawl4ai.default.svc.cluster.local:11235
```

They must also provide the bearer token.

## Playground

The upstream playground and dashboard use root-absolute browser paths, so InfraStack does not publish them through the namespaced `/crawl4ai/` route. Use a local port-forward when needed:

```bash
sudo kubectl port-forward service/crawl4ai 11235:11235
```

Then open `http://localhost:11235/playground`.
