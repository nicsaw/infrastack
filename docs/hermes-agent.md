# Hermes Agent on K3s

InfraStack can deploy Hermes Agent and a Camofox browser as an optional Argo CD application. Both containers run in one Pod, so Hermes reaches Camofox through `http://127.0.0.1:9377`, matching the shared-network behaviour of the existing Docker Compose setup.

The Compose services remain unchanged.

## Enable

Add the following to the ignored `config.yaml`:

```yaml
hermes_agent_enabled: true

# Optional private routes through the existing Traefik Gateway.
hermes_agent_route_enabled: true
hermes_agent_dashboard_path: /hermes
hermes_agent_api_path: /hermes-api

# Provider and messaging credentials are configured after login through the
# Hermes dashboard and stored on the persistent /opt/data volume.
```

Run:

```bash
./bootstrap.sh
```

InfraStack creates:

- a dedicated `hermes-agent` namespace;
- an Argo CD Application;
- one Pod containing Hermes Agent and Camofox;
- persistent volumes for `/opt/data` and `/root/.camofox`;
- generated API and dashboard credentials;
- optional `/hermes/` and `/hermes-api/` Gateway API routes.

## Credentials

```bash
sudo kubectl get secret hermes-agent-env \
  --namespace=hermes-agent \
  --output=jsonpath='{.data.HERMES_DASHBOARD_BASIC_AUTH_USERNAME}' \
  | base64 --decode
echo

sudo kubectl get secret hermes-agent-env \
  --namespace=hermes-agent \
  --output=jsonpath='{.data.HERMES_DASHBOARD_BASIC_AUTH_PASSWORD}' \
  | base64 --decode
echo

sudo kubectl get secret hermes-agent-env \
  --namespace=hermes-agent \
  --output=jsonpath='{.data.API_SERVER_KEY}' \
  | base64 --decode
echo
```

With the default routing settings, open:

```text
https://<TAILSCALE_HOSTNAME>/hermes/
```

The OpenAI-compatible API is available at:

```text
https://<TAILSCALE_HOSTNAME>/hermes-api/
```

Authenticate API requests with:

```text
Authorization: Bearer <API_SERVER_KEY>
```

Kubernetes workloads can use:

```text
http://hermes-agent.hermes-agent.svc.cluster.local:9119
http://hermes-agent.hermes-agent.svc.cluster.local:8642
```

## Configure Hermes

The dashboard writes Hermes configuration, API keys, sessions, skills, memories, logs and plugins beneath `/opt/data`, which is backed by a persistent volume. Provider and messaging credentials are configured from the dashboard after the first login rather than stored in InfraStack configuration or committed to Git.

Do not expose the dashboard directly to the public internet with basic authentication. The default route is intended for the existing private Tailscale access path.

## Observe Camofox

Camofox is not published through Traefik. Use a temporary port-forward:

```bash
sudo kubectl port-forward \
  --namespace=hermes-agent \
  service/hermes-agent \
  6080:6080
```

Then open:

```text
http://localhost:6080/
```

The Camofox control API is available only inside the cluster at port `9377`.

## Verify

```bash
sudo kubectl rollout status deployment/hermes-agent \
  --namespace=hermes-agent \
  --timeout=15m

sudo kubectl get pod,service,pvc \
  --namespace=hermes-agent \
  --selector=app.kubernetes.io/name=hermes-agent

curl -fsS \
  https://<TAILSCALE_HOSTNAME>/hermes/api/status
```

## Existing Compose data

The K3s deployment uses new PVCs and does not automatically import `services/hermes-agent/data` or `services/camofox/data`. Stop the Compose Hermes and Camofox services before reusing the same Telegram or Discord bot tokens so two gateways do not process the same messages.

## Disable

Set:

```yaml
hermes_agent_enabled: false
```

and rerun `./bootstrap.sh`.

InfraStack removes the Argo CD Application, active workloads and routes. It retains the Kubernetes Secret and both PVCs so re-enabling the service does not delete agent or browser state.
