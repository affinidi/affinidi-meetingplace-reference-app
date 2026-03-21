# Video Call — Local Development Setup

This guide explains how to run the full video call feature locally, including what each server does, why both are required, and how to expose them to a physical device via ngrok.

---

## Why two servers?

The video call feature is built on **MatrixRTC**, which combines two separate protocols:

| Server                          | Role                                                                                       | Protocol                         | Default port |
| ------------------------------- | ------------------------------------------------------------------------------------------ | -------------------------------- | ------------ |
| **Synapse** (Matrix homeserver) | Signalling — tracks who is in a call, publishes/receives `m.call.member` membership events | HTTPS / Matrix Client-Server API | `9000`       |
| **LiveKit SFU**                 | Media — routes actual audio and video streams between participants                         | WebSocket + WebRTC               | `7880`       |

They cannot be merged into one:

- Matrix handles identity, room membership, and call signalling. Without it the app cannot log in, create rooms, or discover who joined a call.
- LiveKit is a Selective Forwarding Unit (SFU) that efficiently routes media tracks. Matrix does not carry media, it only tells LiveKit who should be in the room.

```mermaid
C4Container
    title C4 Container Diagram — Video Call

    Person(user, "App User", "Uses the MPX Reference App")
    Container(synapse, "Synapse", "Matrix Homeserver · :9000", "Stores room state and m.call.member membership events used for call signalling.")
    Container(livekit, "LiveKit SFU", "Go · WebRTC · :7880", "Routes audio/video streams between participants.")

    System_Boundary(refapp, "MPX Reference App (Flutter)") {
        Container(sdk_c, "MeetingPlaceSdkProvider", "Dart · matrix-dart-sdk", "Handles login, rooms, and MatrixRTC signalling. Publishes and listens to m.call.member events.")
        Container(lk_c, "LiveKitService", "Dart · livekit_client", "Connects to LiveKit SFU. Publishes the local camera/mic and subscribes to remote participants' tracks.")
    }

    Rel(user, sdk_c, "Call actions")
    Rel(sdk_c, synapse, "Matrix Client-Server API", "HTTPS")
    Rel(lk_c, livekit, "Media tracks", "WebSocket (ws://)")
    Rel(sdk_c, lk_c, "roomId + participant info")
```

---

## MatrixRTC call flow

```mermaid
sequenceDiagram
    actor Alice
    actor Bob
    participant App as MPX Ref App
    participant SDK as Core SDK (uses Matrix SDK)
    participant Synapse as Synapse<br/>(Matrix homeserver)
    participant LK as LiveKit SFU

    rect rgb(200, 220, 255)
        note right of Alice: 📞 Alice presses "Call"
        App->>SDK: startVideoCall(roomId, livekitServiceUrl)
        SDK->>Synapse: PUT m.call.member event<br/>(signals Alice joined the call)
        Synapse-->>SDK: ACK
        App->>LK: LiveKitService.connect(roomId, participantId)<br/>with JWT generated from API key/secret
        LK-->>App: Room joined, track subscriptions begin
    end

    rect rgb(200, 255, 220)
        note right of Bob: 📲 Bob opens the chat
        Synapse-->>SDK: m.call.member event (Alice is in call)
        SDK-->>App: watchVideoCall() → ParticipantsJoinEvent
        App->>App: _onMatrixRTCEvent → show "Alice joined" toast
        App->>LK: LiveKitService.connect(roomId, participantId)
        LK-->>App: Room joined, Alice's audio/video tracks received
        App->>App: onParticipantsChanged → update participant grid
    end

    rect rgb(255, 220, 200)
        note right of Alice: 👋 Alice leaves
        App->>SDK: leaveVideoCall(roomId)
        SDK->>Synapse: DELETE m.call.member event
        Synapse-->>SDK: m.call.member event (Alice left)
        SDK-->>App: watchVideoCall() → ParticipantsLeftEvent
        App->>App: _onMatrixRTCEvent → show "Alice left" toast
        App->>LK: LiveKitService.disconnect()
        LK-->>App: Disconnected
    end
```

---

## Encryption layers

There are **two independent encryption layers** in this feature. It is easy to confuse them because they both involve "E2EE", but they protect different things.

| Layer                    | Protects                        | Protocol                              | Where             |
| ------------------------ | ------------------------------- | ------------------------------------- | ----------------- |
| **Matrix Megolm**        | Text messages and Matrix events | Megolm (AES-256-GCM)                  | Synapse ↔ App     |
| **LiveKit FrameCryptor** | Audio / video media frames      | AES-GCM via WebRTC Insertable Streams | LiveKit SFU ↔ App |

The LiveKit SFU is **blind to media content** — it forwards encrypted RTP frames it cannot read. Synapse never sees media at all.

### Without encryption (baseline)

```mermaid
sequenceDiagram
    participant Alice as Alice's App
    participant SFU as LiveKit SFU
    participant Bob as Bob's App

    Alice->>SFU: publish audio/video frames (CLEARTEXT)
    SFU-->>Bob: forward same frames (CLEARTEXT)
    note over SFU: SFU can read all media
```

### With encryption

Encrypting media frames prevents the LiveKit SFU and any network intermediary from reading audio or video content.

Both deployment modes use **shared-key** encryption — every participant in the same room uses the same symmetric key. The difference is where the key comes from, selected at build time via the `LIVEKIT_TOKEN_SERVER_URL` environment variable:

- **Without token server** — the app derives the key locally from `HMAC-SHA256(apiSecret, roomId)`. Active when `LIVEKIT_TOKEN_SERVER_URL` is not set. Suitable for local development only.
- **With token server** — the server derives & issues the key alongside the LiveKit JWT. Active when `LIVEKIT_TOKEN_SERVER_URL` is set. The API secret never leaves the server. Recommended for any non-local deployment.

> **Note:** Per-participant key distribution via Olm-encrypted Matrix to-device messages is supported by the Matrix SDK (`LiveKitBackend`) and wired in via `MatrixLiveKitKeyProvider`, but is **not currently enabled**. The delegate's `keyProvider` is intentionally left `null`, so the SDK's per-participant key exchange is silently disabled. All encryption uses the shared-key `FrameCryptor`.

#### 1. Without token server — in-app key derivation

All participants independently derive the same key from
`HMAC-SHA256(apiSecret, roomId)` — no key is transmitted.

```mermaid
sequenceDiagram
    participant Alice as Alice's App<br/>(key = HMAC(secret, roomId))
    participant SFU as LiveKit SFU<br/>(no key)
    participant Bob as Bob's App<br/>(key = HMAC(secret, roomId))

    note over Alice: FrameCryptor encrypts<br/>each audio/video frame<br/>with AES-GCM
    Alice->>SFU: publish encrypted frames 🔒
    note over SFU: forwards bytes blindly<br/>cannot decrypt
    SFU-->>Bob: forward encrypted frames 🔒
    note over Bob: FrameCryptor decrypts<br/>using same derived key
```

Key derivation (same result on every device, zero network exchange):

```
key = HMAC-SHA256(LIVEKIT_API_SECRET, roomId)   →   64-char hex (32 bytes)
```

> **Limitation:** `LIVEKIT_API_SECRET` is in the app binary. The key can be extracted from a reverse-engineered binary. Use the token server mode for any non-local deployment.

#### 2. With token server — server-issued shared key

The token server issues both the LiveKit JWT **and** the shared `e2eeKey`. The API secret stays server-side. All participants still share the same symmetric key — only the derivation happens on the server instead of in-app.

```mermaid
sequenceDiagram
    participant Alice as Alice's App
    participant TS as Token Server
    participant SFU as LiveKit SFU<br/>(no key)
    participant Bob as Bob's App

    Alice->>TS: POST /token (roomId, participantId)
    TS-->>Alice: { token: JWT, e2eeKey: "abc…" }
    Bob->>TS: POST /token (roomId, participantId)
    TS-->>Bob: { token: JWT, e2eeKey: "abc…" }
    note over TS: Same e2eeKey for same room.<br/>API secret never sent to clients.

    note over Alice: FrameCryptor encrypts with e2eeKey
    Alice->>SFU: encrypted frames 🔒
    SFU-->>Bob: forward 🔒
    note over Bob: FrameCryptor decrypts with same e2eeKey
```

Implemented via `MatrixLiveKitKeyProvider.fromKey(e2eeKey:)` using `BaseKeyProvider.create(sharedKey: true)`.

---

## Prerequisites

- [Docker Desktop](https://www.docker.com/products/docker-desktop/) — to run Synapse and LiveKit
- [ngrok](https://ngrok.com/download) — to expose both servers to a physical iPhone/Android device

---

## Step 1 — Set up and start the backend servers

Clone the matrix server repo:

```bash
git clone https://gitlab.com/affinidi/foundational/genesis/poc/workathons/ai-workathon-2026/affinidi-ai-mpx-matrix
cd affinidi-ai-mpx-matrix
```

Run setup once (initialises Synapse config and git submodules):

```bash
./scripts/setup.sh
```

Start the servers (Synapse + LiveKit via Docker Compose):

```bash
./scripts/start.sh
```

Other useful scripts:

```bash
./scripts/logs.sh      # Tail live logs
./scripts/restart.sh   # Restart after config changes
```

---

## Step 2 — Expose servers via ngrok (especially for physical devices)

> **Skip this step if you are only running on a simulator** — the app defaults to `http://localhost:9000` and `ws://localhost:7880`, which work fine on simulators.

A physical device cannot reach `localhost` on your Mac. ngrok creates public tunnels for both servers in a single agent session.

### Configure ngrok tunnels

> **Why two tunnels in one config?** The free ngrok plan allows only **one agent session**. We need to declare both tunnels in `ngrok.yml` and starting with `ngrok start --all` runs them in a single session. Starting them as separate commands would fail on the second one.

Edit your local ngrok config: `~/.config/ngrok/ngrok.yml` (create it if it doesn't exist):

```yaml
version: "2"
authtoken: <YOUR_NGROK_AUTHTOKEN>
tunnels:
  synapse:
    proto: http
    addr: 9000
    request_header:
      add:
        - "ngrok-skip-browser-warning:true"
  livekit:
    proto: tcp
    addr: 7880
```

Start both tunnels:

```bash
ngrok start --all
```

Verify both servers are running:

1. Open http://localhost:4040/inspect/http from your browser and you will see:

```
https://59d7-119-234-196-33.ngrok-free.app
tcp://0.tcp.ap.ngrok.io:11371
```

2. Or see the URLs printed in the terminal, e.g.:

```
Forwarding  https://xxxx-xx-xx-xx-xx.ngrok-free.app  → http://localhost:9000  (Synapse)
Forwarding  tcp://0.tcp.ap.ngrok.io:XXXXX             → localhost:7880         (LiveKit)
```

### Update Synapse's public base URL

Edit `affinidi-ai-mpx-matrix/files/homeserver.yaml` and update `public_baseurl` to your current Synapse ngrok HTTPS URL:

```yaml
public_baseurl: "https://xxxx-xx-xx-xx-xx.ngrok-free.app"
```

Then restart Synapse so it picks up the change:

```bash
./scripts/restart.sh
```

---

## Step 3 — Configure the Flutter app

Copy the template if you haven't already:

```bash
cp templates/.example.env configurations/.env
```

Update `configurations/.env` with your values:

```bash
# Override both when testing on a physical device:
MATRIX_HOMESERVER="https://xxxx-xx-xx-xx-xx.ngrok-free.app"
# Note that ngrok gives `tcp:` protocol, when pasting here, replace it with `ws:` instead
LIVEKIT_URL="ws://0.tcp.ap.ngrok.io:XXXXX"

# These should match the keys configured in `affinidi-ai-mpx-matrix/livekit.yaml`
LIVEKIT_API_KEY="<key>"
LIVEKIT_API_SECRET="<secret>"

# ... fill in the other variables
```

> **Note:** ngrok URLs change every time you restart the agent on a free plan. You'll need to repeat Step 2 and update `MATRIX_HOMESERVER`, `LIVEKIT_URL`, and `files/homeserver.yaml` after each restart.

---

## Step 4 — Run the app

---

## Troubleshooting

| Symptom                                                            | Likely cause                                                                                                   | Fix                                                                              |
| ------------------------------------------------------------------ | -------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------- |
| `publishOffer` fails on device                                     | `MATRIX_HOMESERVER` still points to `localhost`                                                                | Update `.env` with current ngrok HTTPS URL                                       |
| LiveKit connect fails on device                                    | `LIVEKIT_URL` uses `tcp://` prefix                                                                             | Must be `ws://`, e.g. `ws://0.tcp.ap.ngrok.io:XXXXX`                             |
| `ngrok start --all` fails on second tunnel                         | Two separate ngrok agents running                                                                              | Kill existing: `pkill ngrok`, then `ngrok start --all`                           |
| Synapse returns 404 after ngrok restart                            | Old URL still in `homeserver.yaml`                                                                             | Update `public_baseurl` + `./scripts/restart.sh`                                 |
| Participants don't appear in grid                                  | LiveKit `--node-ip` mismatch                                                                                   | For simulator use `--node-ip 127.0.0.1`; for device expose via ngrok TCP         |
| `Connection closed before full header was received` on LiveKit URL | LiveKit container not running — volume path for `livekit.yaml` fails if scripts are not run from the repo root | In the `affinidi-ai-mpx-matrix` repo, open terminal and run `./scripts/start.sh` |
