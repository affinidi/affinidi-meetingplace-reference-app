# Demo scripts

This folder contains helper scripts that support the local **VTI Local Demo (SDK-Enforced Trust)** flow described in the [main README](../README.md#vti-local-demo-sdk-enforced-trust).

## `mock_trust_api.py`

Lightweight Policy Decision Point (PDP) used by the Meeting Place SDK's
`HttpTrustPolicyEnforcer` during local demos. It exposes:

- `POST /v1/authorize` – decision endpoint consumed by the SDK.
- `GET/POST /v1/policies`, `GET/PUT/DELETE /v1/policies/<groupId>` – policy
  CRUD with `read-only` and `open` templates.
- `GET/POST /v1/roles`, `DELETE /v1/roles?actorDid=&groupId=` – role
  assignments per `(actorDid, groupId)`.
- `GET /v1/decisions` – in-memory decision log (most recent first).
- `GET /health` – liveness check.

### Run

```bash
python3 scripts/mock_trust_api.py
```

Defaults to `http://127.0.0.1:8080`. Stop with `Ctrl+C`.

### Quick demo recipes

```bash
# Read-only group policy for a group
curl -s -X POST http://127.0.0.1:8080/v1/policies \
  -H 'content-type: application/json' \
  -d '{"groupId":"<group-did>","template":"read-only"}'

# Assign Bob as viewer (denies sendGroupMessage)
curl -s -X POST http://127.0.0.1:8080/v1/roles \
  -H 'content-type: application/json' \
  -d '{"actorDid":"<bob-did>","groupId":"<group-did>","role":"viewer"}'

# Promote Bob to admin (allows sendGroupMessage)
curl -s -X POST http://127.0.0.1:8080/v1/roles \
  -H 'content-type: application/json' \
  -d '{"actorDid":"<bob-did>","groupId":"<group-did>","role":"admin"}'
```

See the [main README](../README.md#vti-local-demo-sdk-enforced-trust) for the full end-to-end runbook.
