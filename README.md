
# Affinidi Meeting Place — Flutter Reference App

A production-ready reference app showing how to build a secure, privacy-first messaging application using the **[Affinidi Meeting Place Core](https://pub.dev/packages/meeting_place_core)** and **[Chat](https://pub.dev/packages/meeting_place_chat)** SDKs; with **Decentralised Identifiers (DIDs)**, **DIDComm v2.1** messaging, and a working **Human ZKP demo** built in.

> **Privacy notice:** This project does not collect or process any personal data. If you integrate it into a broader system that handles personally identifiable information (PII), you are responsible for complying with all applicable privacy laws and data-protection obligations.

## Table of Contents

1. [Core Concepts](#core-concepts)
2. [Preview](#preview)
3. [Key Features](#key-features)
4. [Architecture Overview](#architecture-overview)
5. [Feature Demonstrations](#feature-demos)
6. [Requirements](#requirements)
7. [Getting Started](#getting-started)
8. [Environment Variables](#environment-variables)
9. [VSCode Configuration](#vscode-configuration)
10. [Run App on Simulator](#run-app-on-simulator)
11. [Git Hooks](#git-hooks)
12. [Troubleshooting](#troubleshooting)
13. [Support & Feedback](#support--feedback)
14. [Contributing](#contributing)

---

## Core Concepts

Familiarise yourself with these key terms before diving into the code.

<table>
<thead>
<tr><th>Term</th><th>Definition</th></tr>
</thead>
<tbody>
<tr><td colspan="2"><strong>Core SDK</strong></td></tr>
<tr><td><strong>Decentralised Identifier (DID)</strong></td><td>A globally unique identifier that enables secure, self-sovereign identity interactions. The owner controls the DID without relying on a central authority.</td></tr>
<tr><td><strong>Verifiable Credential (VC)</strong></td><td>A cryptographically signed digital claim about a subject (e.g. a person or organisation), issued by a trusted issuer and verifiable by anyone.</td></tr>
<tr><td><strong>Messaging Server (Mediator)</strong></td><td>A routing service that securely relays messages between parties; individuals, businesses, or AI agents, without being able to read message content.</td></tr>
<tr><td><strong>Invitation</strong></td><td>A <code>ContactCard</code> containing a name, description, validity period, and a unique mnemonic phrase. Publish one so others can initiate a secure connection request with you.</td></tr>
<tr><td><strong>Channel</strong></td><td>A secure, bilateral connection formed once an invitation is accepted. Each channel has its own DID, separate from each participant's primary DID.</td></tr>
<tr><td><strong>Relationship Card (R-Card)</strong></td><td>A signed contact credential containing your name, email, phone, and company. Sent automatically when a channel opens and stored in the Credentials tab. Exportable to vCard 3.0.</td></tr>
<tr><td><strong>Verifiable Relationship Credential (VRC)</strong></td><td>A mutual "verified relationship" credential between two DIDs, exchanged via a two step handshake in chat. Both participants receive a signed copy stored in the Credentials tab.</td></tr>
<tr><td colspan="2"><strong>ZKP Feature (opt-in)</strong></td></tr>
<tr><td><strong>Zero Knowledge Proof (ZKP)</strong></td><td>A cryptographic method that lets one party prove a fact to another without revealing underlying personal data. Used in this app to prove "humanness" via a Liveness Credential. Enable with <code>ZKP_ENABLED=true</code>.</td></tr>
</tbody>
</table>

## Preview

The reference app showcases the core capabilities of a secure, private messaging application - identity setup, connection offers, peer-to-peer messaging, and group messaging, all built on best practices from the Affinidi Meeting Place SDK.

![App preview screenshots](assets/docs/meetingplace-screenshot.png)

## Key Features

| Feature | Description |
|---------|-------------|
| **Multiple Identities** | Set a primary identity for your main profile, plus create aliases for specific contexts (e.g. a hobbyist persona or professional profile). |
| **Connect with Invitations** | Create and publish invitations with custom options: a custom phrase, a usage limit, or an expiry date. |
| **Secure Messaging** | Peer-to-peer and group messaging with end-to-end privacy built in. |
| **Verified Identity (R-Card and VRC)** | Share your R-Card (a signed digital contact card) in any chat, or initiate a mutual VRC exchange to create a verifiable record of your relationship. See [Feature Demonstrations](#feature-demos). |
| **Messaging Server** | Use the Affinidi-hosted messaging server or bring your own managed mediator. |
| **Human ZKP Demo** | Prove a contact is human using a Zero Knowledge Proof; no biometric data or personal information is shared. See [Feature Demonstrations](#feature-demos). |

For full SDK documentation, see the [Affinidi Meeting Place SDK docs](https://docs.affinidi.com/products/affinidi-messaging/meeting-place/).

## Architecture Overview

The app uses a clean, four layer architecture. Each layer has one job and can only talk to the layer below it.

### Architectural Layers

![Reference App Architecture](./assets/docs/reference-app-arch-diagram.png)

```
Presentation Layer → Application Layer → Domain Layer → Infrastructure Layer
```

### Core Components

#### 1. Presentation Layer (`/lib/presentation/`)
- **Screens**: Individual page implementations for different app features.
- **Widgets**: Reusable UI components and custom widgets.
- **Themes**: App styling and theming configuration.
- **Pure UI**: Contains only view logic, no business logic or state management.

#### 2. Application Layer (`/lib/application/`)
- **Services**: Business logic and use cases.
- **Navigation**: App routing and navigation configuration.
- **State Management**: Riverpod providers for managing application state.

#### 3. Domain Layer (`/lib/domain/`)
- **Models**: Core business entities and value objects.
- **Repository Interfaces**: Contracts for data access.

#### 4. Infrastructure Layer (`/lib/infrastructure/`)
- **Database**: Local storage implementation using Drift.
- **Repositories**: Concrete implementations of domain repository interfaces.
- **Providers**: Riverpod providers for external packages and dependency injection.
- **External Services**: Firebase messaging, biometrics, secure storage, media handling.
- **Configuration**: Environment settings and app configuration.


### Access Rules

Layers can only access the layer directly below them, never skip a level.

| Layer | Responsibility | Can access |
|-------|----------------|------------|
| **Screens** (Presentation) | Display UI, handle user input | Controllers only |
| **Controllers** (State management) | Manage state, coordinate UI ↔ business logic | Services, infrastructure providers |
| **Services** (Application) | Implement business logic and use cases | Repository interfaces, infrastructure providers |

### SDK Integration

| Component | What it does |
|-----------|--------------|
| **Core SDK** | DID management and DIDComm messaging |
| **Chat SDK** | Messaging capabilities |
| **Repository pattern** | Wraps SDK calls behind domain interfaces; swap the SDK without touching UI or business logic |
| **Riverpod providers** | Injects SDK instances throughout the app |

### Chat Screen Architecture

![Chat Screen Architecture](./assets/docs/chat_screen_architecture.png)

Source diagram: [`assets/docs/chat_screen_architecture.puml`](./assets/docs/chat_screen_architecture.puml)

<h2 id="feature-demos">Feature Demonstrations</h2>

Each tab below documents one interactive feature built into this reference app. Adding a new feature demo = adding a new tab. The page length stays constant regardless of how many demos are included.

<details open id="panel-zkp">
<summary><strong>Human ZKP Demo</strong></summary>

<h3 id="zkp-what">What is a Zero Knowledge Proof?</h3>

A **Zero-Knowledge Proof (ZKP)** lets one party prove a fact to another without revealing the underlying data. In this app, the fact being proved is: *"I am a real human."* The proof is derived from a **Liveness Credential**; a signed Verifiable Credential issued after a liveness check and packaged as a compact **Groth16 ZKP** that can be verified instantly by the other party.

<h3 id="zkp-enable">Enabling the demo</h3>

The Human ZKP demo is **off by default**. Enable it at build or run time:

```bash
ZKP_ENABLED=true
```

> Setting `ZKP_ENABLED=true` also unlocks the **Credentials** tab, where you can inspect and manage Liveness Credentials.

> Out of the box the demo uses **synthetic liveness evidence**, no camera or third-party service needed. To connect a real face detection service, see [Using a real liveness provider](#zkp-real-provider).

<h3 id="zkp-happy">Happy path</h3>

The screenshots below show the full flow from the requester's side.

<table>
<tr>
<td align="center" width="25%"><strong>Open chat</strong><br><sub>Start a peer-to-peer conversation</sub></td>
<td align="center" width="25%"><strong>Send ZKP request</strong><br><sub>Tap <b>'+'</b>to start Human ZKP flow</sub></td>
<td align="center" width="25%"><strong>Contact completes liveness</strong></td>
<td align="center" width="25%"><strong>ZKP sent and verified</strong></td>
</tr>
</table>

<table>
<tr>
<td align="center" width="25%"><img src="assets/zkp/open-chat.png" alt="Step 1" width="180" /><br><sub>Step 1</sub></td>
<td align="center" width="25%"><img src="assets/zkp/send-zkp-request.png" alt="Step 2" width="180" /><br><sub>Step 2</sub></td>
<td align="center" width="25%"><img src="assets/zkp/complete-liveness.png" alt="Step 3" width="180" /><br><sub>Step 3</sub></td>
<td align="center" width="25%"><img src="assets/zkp/zkp-sent.png" alt="Step 4" width="180" /><br><sub>Step 4</sub></td>
</tr>
</table>

<h3 id="zkp-fail">Failure path</h3>

If verification fails, a **Concierge message** appears in the thread with a Human ZKP badge:

<blockquote>
<p><em>"Bob failed to provide a Zero Knowledge Proof confirming they are human."</em></p>
</blockquote>

<p align="center">
<img src="assets/zkp/zkp-verification-failure.png" alt="ZKP verification failure" width="220" />
</p>

<h3 id="zkp-real-provider">Using a real liveness provider</h3>

The liveness check in this reference app is **mocked with synthetic evidence**; it exercises the full **Liveness Credential → ZKP pipeline** end-to-end without a camera or third-party account, so you can run the demo immediately after cloning.

The detailed pipeline architecture, provider integration guide, and AWS Rekognition setup instructions live in the **[Credentials SDK documentation](https://github.com/affinidi/affinidi-meetingplace-sdk-dart/blob/main/meeting-place-credentials.html#provider-setup)** — not here. That keeps provider setup accurate as the SDK evolves.

> **Recommended provider — AWS Rekognition Face Liveness.** Our team has end-to-end validated this integration against the Liveness Credential pipeline. See [Credentials SDK; Provider Setup](https://github.com/affinidi/affinidi-meetingplace-sdk-dart/blob/main/meeting-place-credentials.html#provider-setup).

> **Prefer a different service?** The pipeline is provider-agnostic. Azure Face API, Onfido, or any custom liveness solution will work, implement `LivenessEvidenceSource` and the credential and ZKP layers require zero changes.

<ul>
<li>
<details>
<summary id="aws-rekognition-face-liveness-setup">AWS Rekognition Face Liveness setup</summary>

This section documents everything required to configure **Amazon Rekognition Face Liveness** for use with a Flutter app via the [`face_liveness_detector`](https://github.com/affinidi/affinidi-meetingplace-reference-app/blob/main/packages/face_liveness_detector/README.md) plugin. An end-to-end proof-of-concept validated this flow against the Liveness Credential pipeline above. The AWS integration itself is not part of the reference app and should be implemented in your own project or SDK layer.

#### Overview

AWS Face Liveness works in three steps:

1. **Create session** — call `CreateFaceLivenessSession` to obtain a `sessionId`.
2. **Camera challenge** — present the native Amplify Face Liveness UI, which streams video to Rekognition for the given session.
3. **Fetch results** — call `GetFaceLivenessSessionResults` to read the session status and confidence score.

Authentication uses a **Cognito Identity Pool** with guest (unauthenticated) access. No user sign-in is required. The mobile client obtains temporary AWS credentials and calls Rekognition directly, or via a backend you control.

#### AWS prerequisites

1. An **AWS account** with [Amazon Rekognition Face Liveness](https://docs.aws.amazon.com/rekognition/latest/dg/face-liveness.html) available in your chosen region (for example, `us-east-1`).
2. A **Cognito Identity Pool** with **Enable access to unauthenticated identities** turned on.
3. An **IAM policy** on the unauthenticated role granting Rekognition Face Liveness API access:

```json
{
	"Version": "2012-10-17",
	"Statement": [
		{
			"Effect": "Allow",
			"Action": [
				"rekognition:CreateFaceLivenessSession",
				"rekognition:GetFaceLivenessSessionResults"
			],
			"Resource": "*"
		}
	]
}
```

4. Note your **Identity Pool ID** (format `region:uuid`) and **region**. Both are required for Amplify configuration.

For a guided walkthrough, see the [AWS Amplify Face Liveness quick start](https://ui.docs.amplify.aws/swift/connected-components/liveness#quick-start).

#### AWS console setup

1. Open **Amazon Cognito** → **Identity pools** → **Create identity pool**.
2. Enable **Guest access** (unauthenticated identities).
3. Create or select the IAM role for unauthenticated users and attach the Rekognition policy above.
4. Copy the **Identity pool ID** (for example, `us-east-1:xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx`).
5. Confirm Face Liveness is supported in your region.

**Alternative: Amplify CLI**

```bash
amplify init
amplify add auth    # choose Identity Pool with unauthenticated access
amplify push
```

A reference Amplify project lives at `packages/face_liveness_detector/example/android/amplify/`.

#### Amplify configuration

The native Face Liveness UI reads Amplify config from platform-specific files. Both must reference the same Identity Pool ID and region.

**`amplifyconfiguration.json`:**

```json
{
	"auth": {
		"plugins": {
			"awsCognitoAuthPlugin": {
				"IdentityManager": { "Default": {} },
				"CredentialsProvider": {
					"CognitoIdentity": {
						"Default": {
							"PoolId": "us-east-1:REPLACE_WITH_IDENTITY_POOL_ID",
							"Region": "us-east-1"
						}
					}
				},
				"CognitoIdentity": {
					"Default": {
						"PoolId": "us-east-1:REPLACE_WITH_IDENTITY_POOL_ID",
						"Region": "us-east-1"
					}
				}
			}
		}
	}
}
```

**File locations:**

| Platform | Path |
|----------|------|
| iOS | `ios/amplifyconfiguration.json` and `ios/awsconfiguration.json` (add both to the Xcode Runner target) |
| Android | `android/app/src/main/res/raw/amplifyconfiguration.json` |

Example templates are in `packages/face_liveness_detector/example/ios/` and the [package README](https://github.com/affinidi/affinidi-meetingplace-reference-app/blob/main/packages/face_liveness_detector/README.md).

If your integration also calls Rekognition from Dart (session creation and results fetch), configure Amplify Auth separately with the same pool ID and region, either programmatically or via the same JSON files.

#### Native platform setup

##### iOS

1. Place `amplifyconfiguration.json` and `awsconfiguration.json` in the `ios/` directory and add them to the Xcode Runner target.
2. Add Swift Package dependencies to the Runner target:
	 - [amplify-swift](https://github.com/aws-amplify/amplify-swift) `2.46.1+` with products `Amplify` and `AWSCognitoAuthPlugin`
	 - [amplify-ui-swift-liveness](https://github.com/aws-amplify/amplify-ui-swift-liveness) `1.3.5+` with product `FaceLiveness`
3. Call `Amplify.configure()` during app startup (before presenting the liveness widget).
4. Declare camera usage in `Info.plist`:

```xml
<key>NSCameraUsageDescription</key>
<string>Camera access is required for face liveness verification.</string>
```

5. Minimum deployment target: iOS 13.0+ (16.0+ recommended).

See [`packages/face_liveness_detector/ios/setup_dependencies.md`](https://github.com/affinidi/affinidi-meetingplace-reference-app/blob/main/packages/face_liveness_detector/ios/setup_dependencies.md) for detailed Xcode steps.

##### Android

1. Place `amplifyconfiguration.json` in `android/app/src/main/res/raw/`.
2. Set `minSdkVersion` to at least **24** and `compileSdkVersion` to **35**.
3. Extend `FlutterFragmentActivity` instead of `FlutterActivity`:

```kotlin
import io.flutter.embedding.android.FlutterFragmentActivity

class MainActivity : FlutterFragmentActivity()
```

4. Declare camera permission in `AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.CAMERA" />
```

5. The `face_liveness_detector` plugin configures Amplify on attach and pulls in the native Amplify Face Liveness dependencies.

> Use a **physical device** for Face Liveness. The camera challenge does not work reliably on emulators or simulators.

#### Session lifecycle

Once AWS and native setup are complete, integrate the liveness check in your app:

1. **Create a session** — from your backend or directly from the client using temporary Cognito credentials:

```text
RekognitionService.CreateFaceLivenessSession
-> { "SessionId": "..." }
```

2. **Run the camera challenge** — pass the session ID and region to the Flutter widget:

```dart
FaceLivenessDetector(
	sessionId: sessionId,
	region: 'us-east-1',
	onComplete: () { /* fetch results */ },
	onError: (code) { /* handle error */ },
)
```

3. **Fetch results** — after `onComplete`, call:

```text
RekognitionService.GetFaceLivenessSessionResults
-> { "Status": "SUCCEEDED", "Confidence": 95.3, ... }
```

4. **Map to evidence** — convert the result into provider-neutral evidence for your credential layer:

| Field | AWS source |
|-------|------------|
| `providerId` | `"aws_rekognition"` |
| `providerTransactionId` | `SessionId` |
| `livenessScore` | `Confidence` |
| `livenessThreshold` | Your configured minimum (for example, `80.0`) |
| `checkedAt` | Timestamp when results were fetched |

A working Flutter example with backend session creation is in `packages/face_liveness_detector/example/`.

</details>
</li>
</ul>

</details>

<details id="panel-vrc">
<summary><strong>R-Card and VRC Demo</strong></summary>

<h3 id="vrc-what">What are R-Cards and VRCs?</h3>

The Meeting Place app includes a built-in credential exchange system powered by the **Credentials SDK**. Two types of verifiable credentials are supported:

| Credential | What it encodes | How it is exchanged |
|------------|-----------------|---------------------|
| **Relationship Card (R-Card)** | Your contact information: name, email, phone, company. Signed as a jCard Verifiable Credential (RFC 7095). Exportable to vCard 3.0. | Sent automatically when a channel first opens (inauguration), or shared manually from the chat action menu. |
| **Verifiable Relationship Credential (VRC)** | A mutual "verified relationship" credential encoding the DIDs of both participants and the timestamp of the exchange. | Two-step VDIP handshake: one side requests, the other reciprocates. Both participants receive a signed copy. |

> R-Card and VRC exchange requires no feature flags. Any open channel can exchange credentials. The **Credentials** tab shows all stored R-Cards and VRCs on this device.

> **Integrating into your own app?** See the [Credentials SDK documentation](https://github.com/affinidi/affinidi-meetingplace-sdk-dart/blob/main/meeting-place-credentials.html#rcard-vrc) for the operations API, repository interfaces, and data models.

<h3 id="vrc-rcard">R-Card exchange</h3>

An R-Card is your verifiable digital contact card. The app supports two R-Card flows: automatic sharing when a channel opens, and manual sharing from the chat action menu.

<h4>Automatic flow</h4>

The app automatically sends your R-Card to a new contact when a channel is first opened.

<table>
<tr>
<td align="center" width="33%"><strong>Open a channel</strong></td>
<td align="center" width="33%"><strong>R-Card sent automatically</strong></td>
<td align="center" width="33%"><strong>Contact receives it and saves it</strong></td>
</tr>
<tr>
<td align="center" width="33%"><img src="assets/rcard/rcard-automatic.png" alt="R-Card sent automatically" /></td>
<td align="center" width="33%"><img src="assets/rcard/rcard-info.png" alt="R-Card received in thread" /></td>
<td align="center" width="33%"><img src="assets/rcard/rcard-tab.png" alt="R-Card saved to credentials" /></td>
</tr>
</table>

<h4>Manual flow</h4>

You can also share an R-Card at any time from the chat action menu by tapping **+** and selecting **Share R-Card**.

<table>
<tr>
<td align="center" width="33%"><strong>Open chat action menu</strong></td>
<td align="center" width="33%"><strong>Select the R-Card you want to share</strong></td>
<td align="center" width="33%"><strong>Both parties see it in chat</strong></td>
</tr>
<tr>
<td align="center" width="33%"><img src="assets/rcard/rcard-manual.png" alt="R-Card sent manually" /></td>
<td align="center" width="33%"><img src="assets/rcard/select-rcard.png" alt="Select the R-Card you want to share" /></td>
<td align="center" width="33%"><img src="assets/rcard/rcard-shared-screen.png" alt="Both parties see it in chat" /></td>
</tr>
</table>

<h3 id="vrc-exchange">VRC exchange</h3>

A VRC is a mutual "verified relationship" credential. Unlike an R-Card, a VRC requires both participants to act: one side initiates a request, and the other reciprocates.

> VRCs establish a trusted record of a relationship that exists independently of any messaging platform. The credential can be verified by anyone without contacting a central authority.

<table>
<tr>
<td align="center" width="20%"><strong>Initiate request</strong></td>
<td align="center" width="20%"><strong>Request sent</strong></td>
<td align="center" width="20%"><strong>Contact prompted</strong></td>
<td align="center" width="20%"><strong>Both sides sign</strong></td>
</tr>
<tr>
<td align="center" width="20%"><img src="assets/vrc/initiate-request.png" alt="Initiate request" /></td>
<td align="center" width="20%"><img src="assets/vrc/request-sent.png" alt="Request sent" /></td>
<td align="center" width="20%"><img src="assets/vrc/contact-prompted.png" alt="Contact prompted" /></td>
<td align="center" width="20%"><img src="assets/vrc/chat-screen-vrc.png" alt="Both sides sign" /></td>
</tr>
</table>

</details>

</details>

## Requirements

| Dependency | Version |
|------------|---------|
| **Flutter** | `3.41.4` |
| **Dart SDK** | `^3.9.2` |

## Getting Started

Set up your environment to run the Meeting Place application.

### Step 1: Activate Melos

```bash
dart pub global activate melos && export PATH="$PATH":"$HOME/.pub-cache/bin"
```

> Add the `export PATH="$PATH":"$HOME/.pub-cache/bin"` line to your shell config (`~/.zshrc` or `~/.bashrc`) so it persists across terminal sessions.

### Step 2: Install dependencies

```bash
melos pubget
```

### Step 3: Generate models

```bash
melos gen
```

### Step 4: Generate localised strings

```bash
melos strings
```

### Step 5: Configure environment variables

See [Environment Variables](#environment-variables) for the full setup.

## Environment Variables

The app uses a `.env` file for configuration. A template is provided.

```bash
mkdir -p configurations && cp templates/.example.env configurations/.env
```

> Run this from the **root folder** of the reference app. Most variables have sensible defaults, only supply values specific to your setup.

### Required Environment Variables

#### Connect to Control Plane API

The Control Plane API enables identity discovery and secure channel creation over DIDComm v2.1. To run it locally, follow the [Control Plane API for Dart](https://docs.affinidi.com/products/affinidi-messaging/meeting-place/deployment-options/control-plane-open-sourced/) guide.

```bash
# Your Control Plane DID (did:web value from your API server)
CONTROL_PLANE_DID=""
```

#### Connect to DIDComm Mediator

The DIDComm Mediator routes messages between parties without reading their content. Follow the [DIDComm Mediator](https://docs.affinidi.com/products/affinidi-messaging/didcomm-mediator/deployment-options/mediator-open-sourced/) guide to set it up.

```bash
# Your Mediator DID
DEFAULT_MEDIATOR_DID=""
```

#### Enable push notifications

Create a [Firebase](https://firebase.google.com/docs/projects/learn-more) project, then:

> **Firebase iOS app**
> 1. [Create an iOS app](https://firebase.google.com/docs/ios/setup#register-app) in your Firebase project.
> 2. Download `GoogleService-Info.plist` from the iOS app settings.
> 3. Copy it to `app/ios/Runner/`. You only need the file, skip the other Firebase setup steps.

> **Firebase Android app**
> 1. [Create an Android app](https://firebase.google.com/docs/android/setup#register-app) in your Firebase project.
> 2. Download `google-services.json` from the Android app settings.
> 3. Copy it to `app/android/app/`. You only need the file, skip the other Firebase setup steps.

```bash
# Firebase - shared
FIREBASE_MESSAGING_SENDER_ID=""
FIREBASE_PROJECT_ID=""
FIREBASE_STORAGE_BUCKET=""

# Firebase - iOS
FIREBASE_IOS_APIKEY=""
FIREBASE_IOS_APP_ID=""
FIREBASE_IOS_BUNDLE_ID=""

# Firebase - Android
FIREBASE_ANDROID_APIKEY=""
FIREBASE_ANDROID_APP_ID=""
```

### Optional Environment Variables

These variables have defaults. Override them only when needed.

```bash
# App configuration
APP_VERSION_NAME=""                              # Default: ""
BIOMETRICS_ENABLED="true"                        # Default: true
DATABASE_LOGGING_ENABLED="false"                 # Default: false (debug builds only)
FOREGROUND_NOTIFICATIONS_ENABLED="false"         # Default: false
TAPS_TO_UNLOCK_DEBUG="7"                         # Default: 7

# Chat settings
CHAT_ACTIVITY_EXPIRES_IN_SECONDS="3"             # Default: 3
CHAT_PRESENCE_SEND_INTERVAL_IN_SECONDS="60"      # Default: 60
CHAT_IMAGE_MAX_SIZE="800"                        # Default: 800 px
CHAT_IMAGE_QUALITY_PERCENT="80"                  # Default: 80%

# Profile settings
PROFILE_IMAGE_MAX_SIZE="100"                     # Default: 100 px
PROFILE_IMAGE_QUALITY_PERCENT="80"               # Default: 80%

# Marketplace
MARKETPLACE_QR_PREFIX=""                         # Default: ""

# Out-of-Band (OOB) flow: distinguishes multiple OOB flows so QR validation does not interfere across flows
DIRECT_INTERACTIVE_OOB_TYPE=""                   # Default: "" (e.g. "oss-app-main-oob-flow")

# Human ZKP & Liveness Credential
ZKP_ENABLED="false"                              # Default: false — enables Human ZKP demo + Credentials tab
```

> All configuration options and their defaults are defined in `lib/infrastructure/configuration/environment.dart`.

## VSCode Configuration

```bash
mkdir -p .vscode && cp templates/.example.launch.json .vscode/launch.json
```

This configuration points to the correct environment file automatically. Edit `launch.json` to change device IDs, environment files, or other launch parameters.

## Run App on Simulator

Refer to the [Flutter Get Started guide](https://docs.flutter.dev/get-started/install) for setting up your environment to run the app on an iOS Simulator or Android Emulator.

> **For Face Liveness testing, use a physical device.** The camera challenge does not work on simulators or emulators.

## Git Hooks

Automatically run code analysis before every commit:

```sh
cp templates/.example.pre-commit .git/hooks/pre-commit
chmod +x .git/hooks/pre-commit
```

This runs `melos run analyze` before each commit and blocks it if any issues are found.

> The file **must** be named `pre-commit` (no extension) inside `.git/hooks/`.

## Troubleshooting

### Firebase: duplicate app error

> `FirebaseException ([core/duplicate-app] A Firebase App named "[DEFAULT]" already exists)`

**Cause:** The Firebase configuration files and the environment variables in `configurations/.env` do not match.

**Solution:** Ensure the following values are consistent across files:

| Config file | `.env` variable prefix |
|-------------|------------------------|
| `google-services.json` (Android) | `FIREBASE_ANDROID_*` |
| `GoogleService-Info.plist` (iOS / macOS) | `FIREBASE_IOS_*` |
| Both files | `FIREBASE_PROJECT_ID`, `FIREBASE_MESSAGING_SENDER_ID`, `FIREBASE_STORAGE_BUCKET` |

See also: [Firebase duplicate app error reference](https://github.com/firebase/flutterfire/blob/main/packages/firebase_core/firebase_core_platform_interface/lib/src/firebase_core_exceptions.dart#L20-L25).

For AWS Rekognition integration issues, refer to the [Credentials SDK: Provider Setup](https://github.com/affinidi/affinidi-meetingplace-sdk-dart/blob/main/meeting-place-credentials.html#provider-setup) guide.

## Support & Feedback

If you face any issues or have suggestions, [contact us here](https://share.hsforms.com/1afnezgGiQTmkfIT5oxWc8Qea58c).

### Reporting technical issues

1. Search [GitHub Issues](https://github.com/affinidi/affinidi-meetingplace-reference-app/issues) to check if the bug has already been reported.
2. If not, [open a new issue](https://github.com/affinidi/affinidi-meetingplace-reference-app/issues/new). Include a clear title and description, steps to reproduce, and a code sample demonstrating the unexpected behaviour.

## Contributing

Want to contribute? Head over to our [CONTRIBUTING](https://github.com/affinidi/affinidi-meetingplace-reference-app/blob/main/CONTRIBUTING.md) guidelines.