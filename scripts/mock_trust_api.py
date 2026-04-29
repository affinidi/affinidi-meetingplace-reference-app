"""Local PDP (Policy Decision Point) for the MPX + VTI demo.

Implements:

- POST /v1/authorize          : Decision endpoint consumed by the SDK.
- POST /v1/policies           : Create or upsert a group policy.
- GET  /v1/policies           : List all policies.
- GET  /v1/policies/<groupId> : Read a single group policy.
- PUT  /v1/policies/<groupId> : Replace a policy for a group.
- DELETE /v1/policies/<groupId> : Remove a policy.
- POST /v1/roles              : Assign role for (actorDid, groupId).
- GET  /v1/roles              : List role assignments.
- DELETE /v1/roles            : Clear role assignments (?actorDid=&groupId=).
- GET  /v1/decisions          : Recent decision log (in memory).
- GET  /health                : Liveness check.

The /v1/authorize contract is kept unchanged for SDK compatibility.

Run with:

    python3 scripts/mock_trust_api.py

By default it listens on http://127.0.0.1:8080.
"""

import json
import threading
from collections import deque
from datetime import datetime, timezone
from http.server import BaseHTTPRequestHandler, HTTPServer
from urllib.parse import parse_qs, urlsplit


HOST = "127.0.0.1"
PORT = 8080
DECISION_LOG_CAPACITY = 200
REQUIRE_PROOF_CONTEXT_FOR_ALLOW = True


READ_ONLY_TEMPLATE = {
    "viewer": {
        "joinGroup": True,
        "sendGroupMessage": False,
        "addGroupMember": False,
        "removeGroupMember": False,
        "deleteGroup": False,
    },
    "admin": {
        "joinGroup": True,
        "sendGroupMessage": True,
        "addGroupMember": True,
        "removeGroupMember": True,
        "deleteGroup": True,
    },
}

OPEN_TEMPLATE = {
    "viewer": {
        "joinGroup": True,
        "sendGroupMessage": True,
        "addGroupMember": False,
        "removeGroupMember": False,
        "deleteGroup": False,
    },
    "admin": {
        "joinGroup": True,
        "sendGroupMessage": True,
        "addGroupMember": True,
        "removeGroupMember": True,
        "deleteGroup": True,
    },
}

POLICY_TEMPLATES = {
    "read-only": READ_ONLY_TEMPLATE,
    "open": OPEN_TEMPLATE,
}


class PolicyStore:
    """Thread-safe in-memory policy + role assignment store."""

    def __init__(self):
        self._lock = threading.RLock()
        # The "*" wildcard acts as the default policy for any group that does
        # not have an explicit policy registered (matches the previous mock).
        self._policies = {"*": dict(READ_ONLY_TEMPLATE)}
        # role_assignments[group_id][actor_did] = role
        self._role_assignments = {}
        self._decision_log = deque(maxlen=DECISION_LOG_CAPACITY)

    def list_policies(self):
        with self._lock:
            return {gid: dict(roles) for gid, roles in self._policies.items()}

    def get_policy(self, group_id):
        with self._lock:
            policy = self._policies.get(group_id)
            return dict(policy) if policy is not None else None

    def upsert_policy(self, group_id, role_actions):
        with self._lock:
            self._policies[group_id] = {
                role: dict(actions) for role, actions in role_actions.items()
            }
            return dict(self._policies[group_id])

    def delete_policy(self, group_id):
        with self._lock:
            return self._policies.pop(group_id, None) is not None

    def resolve_policy(self, group_id):
        with self._lock:
            policy = self._policies.get(group_id) or self._policies["*"]
            return {role: dict(actions) for role, actions in policy.items()}

    def assign_role(self, actor_did, group_id, role):
        with self._lock:
            group_map = self._role_assignments.setdefault(group_id, {})
            group_map[actor_did] = role

    def get_role(self, actor_did, group_id):
        with self._lock:
            group_map = self._role_assignments.get(group_id) or {}
            return group_map.get(actor_did)

    def list_roles(self):
        with self._lock:
            return {
                gid: dict(actor_map)
                for gid, actor_map in self._role_assignments.items()
            }

    def clear_role(self, actor_did=None, group_id=None):
        with self._lock:
            if group_id is None and actor_did is None:
                self._role_assignments.clear()
                return True
            if group_id is not None and actor_did is None:
                return self._role_assignments.pop(group_id, None) is not None
            if group_id is not None and actor_did is not None:
                group_map = self._role_assignments.get(group_id) or {}
                removed = group_map.pop(actor_did, None) is not None
                if not group_map and group_id in self._role_assignments:
                    self._role_assignments.pop(group_id, None)
                return removed
            # actor_did only -> remove from every group
            removed_any = False
            for gid in list(self._role_assignments.keys()):
                if actor_did in self._role_assignments[gid]:
                    del self._role_assignments[gid][actor_did]
                    removed_any = True
                if not self._role_assignments[gid]:
                    del self._role_assignments[gid]
            return removed_any

    def append_decision(self, entry):
        with self._lock:
            self._decision_log.append(entry)

    def list_decisions(self):
        with self._lock:
            return list(self._decision_log)


STORE = PolicyStore()


def _now_iso():
    return datetime.now(timezone.utc).isoformat()


def _extract_role(req):
    actor_did = req.get("actorDid") or ""
    group_id = req.get("groupId") or ""

    explicit = STORE.get_role(actor_did, group_id) if actor_did else None
    if isinstance(explicit, str) and explicit:
        return explicit, "role_assignment"

    metadata = req.get("metadata")
    if isinstance(metadata, dict):
        role = metadata.get("role")
        if isinstance(role, str) and role:
            return role, "metadata"

    # Demo shortcut: pass "role:admin" or "role:viewer" inside credentialProof.
    credential_proof = req.get("credentialProof")
    if isinstance(credential_proof, str):
        marker = "role:"
        if marker in credential_proof:
            value = credential_proof.split(marker, 1)[1].split(",", 1)[0].strip()
            if value:
                return value, "credential_proof_marker"

    return "viewer", "default_viewer"


def _decide(req):
    action = req.get("action") or ""
    group_id = req.get("groupId") or ""
    actor_did = req.get("actorDid") or ""
    issuer_did = req.get("issuerDid") or ""
    scope = req.get("scope") or ""
    credential_proof = req.get("credentialProof") or ""

    role, role_source = _extract_role(req)
    policy = STORE.resolve_policy(group_id)
    role_policy = policy.get(role) or policy.get("viewer") or {}
    policy_allow = bool(role_policy.get(action, False))

    reason = "allowed_by_policy" if policy_allow else "denied_by_policy"
    if action and action not in role_policy:
        reason = "denied_unknown_action"

    has_proof = bool(credential_proof)
    has_issuer = bool(issuer_did)
    has_scope = bool(scope)
    missing_context = []
    if not has_proof:
        missing_context.append("credentialProof")
    if not has_issuer:
        missing_context.append("issuerDid")
    if not has_scope:
        missing_context.append("scope")

    allow = policy_allow
    if (
        allow
        and REQUIRE_PROOF_CONTEXT_FOR_ALLOW
        and missing_context
    ):
        allow = False
        reason = "denied_missing_proof_context"

    decision = {
        "allow": allow,
        "reason": reason,
        "action": action,
        "groupId": group_id,
        "role": role,
        "roleSource": role_source,
        "evaluatedAt": _now_iso(),
        "actorDid": actor_did,
        "issuerDid": issuer_did,
        "scope": scope,
        "hasCredentialProof": has_proof,
        "hasIssuerDid": has_issuer,
        "hasScope": has_scope,
        "proofContextRequiredForAllow": REQUIRE_PROOF_CONTEXT_FOR_ALLOW,
        "missingProofContext": missing_context,
    }
    STORE.append_decision(decision)
    return decision


def _print_decision(decision):
    line = (
        "[PDP] {ts} action={action} groupId={group} role={role} "
        "source={src} actorDid={actor} issuer={issuer} proof={proof} -> {verdict} ({reason})"
    ).format(
        ts=decision["evaluatedAt"],
        action=decision["action"] or "<none>",
        group=decision["groupId"] or "<none>",
        role=decision["role"],
        src=decision["roleSource"],
        actor=decision["actorDid"] or "<none>",
        issuer=decision["issuerDid"] or "<none>",
        proof="yes" if decision["hasCredentialProof"] else "no",
        verdict="ALLOW" if decision["allow"] else "DENY",
        reason=decision["reason"],
    )
    print(line, flush=True)


def _resolve_template(name, custom_roles):
    if isinstance(custom_roles, dict) and custom_roles:
        return {role: dict(actions) for role, actions in custom_roles.items()}
    template = POLICY_TEMPLATES.get((name or "read-only").lower())
    if template is None:
        return None
    return {role: dict(actions) for role, actions in template.items()}


class Handler(BaseHTTPRequestHandler):
    def _send(self, code, body):
        payload = json.dumps(body).encode("utf-8")
        self.send_response(code)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(payload)))
        self.end_headers()
        self.wfile.write(payload)

    def _read_json(self):
        length = int(self.headers.get("Content-Length", "0") or "0")
        raw = self.rfile.read(length).decode("utf-8") if length else "{}"
        try:
            return json.loads(raw or "{}")
        except Exception:
            return None

    def do_POST(self):
        parsed = urlsplit(self.path)
        path = parsed.path

        if path == "/v1/authorize":
            return self._handle_authorize()

        if path == "/v1/policies":
            return self._handle_create_or_upsert_policy()

        if path == "/v1/roles":
            return self._handle_assign_role()

        self._send(404, {"error": "not_found", "path": path})

    def do_PUT(self):
        parsed = urlsplit(self.path)
        path = parsed.path
        if path.startswith("/v1/policies/"):
            group_id = path[len("/v1/policies/"):]
            return self._handle_replace_policy(group_id)

        self._send(404, {"error": "not_found", "path": path})

    def do_DELETE(self):
        parsed = urlsplit(self.path)
        path = parsed.path
        query = parse_qs(parsed.query)

        if path.startswith("/v1/policies/"):
            group_id = path[len("/v1/policies/"):]
            removed = STORE.delete_policy(group_id)
            print(
                "[PDP] policy deleted groupId=%s removed=%s" % (group_id, removed),
                flush=True,
            )
            self._send(
                200 if removed else 404,
                {"deleted": removed, "groupId": group_id},
            )
            return

        if path == "/v1/roles":
            actor_did = (query.get("actorDid") or [None])[0]
            group_id = (query.get("groupId") or [None])[0]
            removed = STORE.clear_role(actor_did=actor_did, group_id=group_id)
            print(
                "[PDP] role cleared actorDid=%s groupId=%s removed=%s"
                % (actor_did, group_id, removed),
                flush=True,
            )
            self._send(
                200 if removed else 404,
                {"deleted": removed, "actorDid": actor_did, "groupId": group_id},
            )
            return

        self._send(404, {"error": "not_found", "path": path})

    def do_GET(self):
        parsed = urlsplit(self.path)
        path = parsed.path

        if path == "/health":
            self._send(200, {"status": "ok", "ts": _now_iso()})
            return

        if path == "/v1/policies":
            self._send(200, {"policies": STORE.list_policies()})
            return

        if path.startswith("/v1/policies/"):
            group_id = path[len("/v1/policies/"):]
            policy = STORE.get_policy(group_id)
            if policy is None:
                self._send(404, {"error": "policy_not_found", "groupId": group_id})
                return
            self._send(200, {"groupId": group_id, "policy": policy})
            return

        if path == "/v1/roles":
            self._send(200, {"roles": STORE.list_roles()})
            return

        if path == "/v1/decisions":
            self._send(200, {"decisions": STORE.list_decisions()})
            return

        self._send(404, {"error": "not_found", "path": path})

    def _handle_authorize(self):
        req = self._read_json()
        if req is None:
            self._send(400, {"error": "invalid_json"})
            return
        decision = _decide(req)
        _print_decision(decision)
        self._send(200, decision)

    def _handle_create_or_upsert_policy(self):
        body = self._read_json()
        if not isinstance(body, dict):
            self._send(400, {"error": "invalid_json"})
            return

        group_id = body.get("groupId")
        if not isinstance(group_id, str) or not group_id:
            self._send(400, {"error": "missing_groupId"})
            return

        template = body.get("template")
        custom_roles = body.get("roles")
        resolved = _resolve_template(template, custom_roles)
        if resolved is None:
            self._send(
                400,
                {
                    "error": "unknown_template",
                    "knownTemplates": list(POLICY_TEMPLATES.keys()),
                },
            )
            return

        stored = STORE.upsert_policy(group_id, resolved)
        print(
            "[PDP] policy upsert groupId=%s template=%s roles=%s"
            % (group_id, template, list(stored.keys())),
            flush=True,
        )
        self._send(200, {"groupId": group_id, "policy": stored})

    def _handle_replace_policy(self, group_id):
        if not group_id:
            self._send(400, {"error": "missing_groupId"})
            return
        body = self._read_json()
        if not isinstance(body, dict):
            self._send(400, {"error": "invalid_json"})
            return
        custom_roles = body.get("roles")
        template = body.get("template")
        resolved = _resolve_template(template, custom_roles)
        if resolved is None:
            self._send(
                400,
                {
                    "error": "unknown_template",
                    "knownTemplates": list(POLICY_TEMPLATES.keys()),
                },
            )
            return
        stored = STORE.upsert_policy(group_id, resolved)
        print(
            "[PDP] policy replace groupId=%s template=%s roles=%s"
            % (group_id, template, list(stored.keys())),
            flush=True,
        )
        self._send(200, {"groupId": group_id, "policy": stored})

    def _handle_assign_role(self):
        body = self._read_json()
        if not isinstance(body, dict):
            self._send(400, {"error": "invalid_json"})
            return
        actor_did = body.get("actorDid")
        group_id = body.get("groupId")
        role = body.get("role")
        if not all(isinstance(v, str) and v for v in (actor_did, group_id, role)):
            self._send(
                400,
                {"error": "missing_fields", "required": ["actorDid", "groupId", "role"]},
            )
            return
        STORE.assign_role(actor_did, group_id, role)
        print(
            "[PDP] role assigned actorDid=%s groupId=%s role=%s"
            % (actor_did, group_id, role),
            flush=True,
        )
        self._send(
            200,
            {"actorDid": actor_did, "groupId": group_id, "role": role},
        )

    def log_message(self, format, *args):
        # Suppress default access log; we emit our own structured logs.
        return


def main():
    server = HTTPServer((HOST, PORT), Handler)
    print("Local PDP running at http://%s:%d" % (HOST, PORT), flush=True)
    print("  Decision endpoint : POST /v1/authorize", flush=True)
    print("  Policies          : GET/POST /v1/policies, GET/PUT/DELETE /v1/policies/<groupId>", flush=True)
    print("  Roles             : GET/POST /v1/roles, DELETE /v1/roles?actorDid=&groupId=", flush=True)
    print("  Decision log      : GET /v1/decisions", flush=True)
    print("  Health            : GET /health", flush=True)
    print(
        "  Proof context     : required_for_allow=%s (credentialProof + issuerDid + scope)"
        % REQUIRE_PROOF_CONTEXT_FOR_ALLOW,
        flush=True,
    )
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        print("\n[PDP] shutting down", flush=True)
        server.server_close()


if __name__ == "__main__":
    main()
