# Affinidi Meeting Place - Reference App for Flutter

This reference application demonstrates the sample usage of the **[Affinidi Meeting Place Core](https://pub.dev/packages/meeting_place_core)** and **[Chat](https://pub.dev/packages/meeting_place_chat)** SDK together with sample integrations (state management, services, infrastructure) in a real Flutter project.

With the use of Affinidi Meeting Place SDK, you can build a messaging appplication that provides a safe and secure method for discovering, connecting, and communicating with others (individuals, businesses, and AI agents) using Decentralised Identifiers (DIDs) and DIDComm v2.1 protocol.

> **IMPORTANT:** This project does not collect or process any personal data. However, when used as part of a broader system or application that handles personally identifiable information (PII), users are responsible for ensuring that any such use complies with applicable privacy laws and data protection obligations.

## Table of Contents

- [Core Concepts](#core-concepts)
- [Preview](#preview)
- [Key Features](#key-features)
- [Architecture Overview](#architecture-overview)
  - [Architectural Layers](#architectural-layers)
  - [Core Components](#core-components)
  - [Access Rules and Data Flow](#access-rules-and-data-flow)
  - [Affinidi Meeting Place SDK Integration](#affinidi-meeting-place-sdk-integration)
- [Requirements](#requirements)
- [Getting started](#getting-started)
- [Environment Variables](#environment-variables)
  - [Required Environment Variables](#required-environment-variables)
  - [Optional Environment Variables](#optional-environment-variables)
- [VSCode Configuration](#vscode-configuration)
- [Run App on Simulator](#run-app-on-simulator)
- [Troubleshooting](#troubleshooting)
- [Support \& Feedback](#support--feedback)
  - [Reporting Technical Issues](#reporting-technical-issues)
- [Contributing](#contributing)

## Core Concepts

- **Decentralised Identifier (DID):** A globally unique identifier that enables secure interactions. The DID is the cornerstone of Self-Sovereign Identity (SSI), a concept that empowers individuals or entities to control their digital identities. DID has different methods to prove control of digital identity.

- **Verifiable Credential (VC):** A digital representation of a claim created by the issuer about the subject (e.g., Individual). VC is cryptographically signed and verifiable.

- **Messaging Server (Mediator):** A service that handles and routes messages securely between parties (e.g., users, businesses, other mediators, or even AI agents). The mediators process the message without being able to access the message’s content intended for the recipient.

- **Invitation:** A vCard containing information about the invitation, such as name, description, and validity. It also includes a unique phrase or mnemonic that a user can publish to allow others to initiate a connection request. It serves as an entry point for users who wish to connect with you securely.

- **Channel:** A secure connection that forms once an invitation to connect is accepted and finalised by the offerer. Each channels creates its own DID as an identifier along with the DID of each participants.

## Preview

The reference application showcases the implementation of the Affinidi Meeting Place Core and Chat SDKs, including the best practices. It showcases the core functionalities and capabilities of a secure and private messaging application, where you can set up your primary identity, create connection offers, and send messages, which include peer-to-peer and group messaging.

![screenshots](assets/docs/meetingplace-screenshot.png)

## Key Features

- **Multiple Identities** - set up your primary identity to serve as your main professional or personal profile. Additionally, create aliases tailored to specific scenarios or communication needs (for example, a hobbyist or community profile).

- **Connect with Invitations** - create and publish invitations for other users to find and connect with you, whether it's peer-to-peer or in a group setting. You can create invites with custom setup options, such as using a custom phrase, specifying the number of invite uses, or setting an expiry, for a more secure setup.

- **Secure Messaging** - communicate either in a peer-to-peer or group setting, like how most chat applications do, but with security and privacy built in.

- **Verified Identity** - show a proof of your identity using a verifiable credential as proof within the chat.

- **Messaging Server** - use our messaging servers as your default server configuration or create your own managed messaging server.

Refer to [the documentation](https://docs.affinidi.com/products/affinidi-messaging/meeting-place/) to learn more about Affinidi Meeting Place SDK.

## Architecture Overview

The architecture is organised into distinct layers, each with specific responsibilities to ensure maintainability, testability, and separation of concerns.

### Architectural Layers

![Reference App Arch](./assets/docs/reference-app-arch-diagram.png)

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

### Access Rules and Data Flow

The architecture enforces strict access rules to maintain separation of concerns:

#### Screens (Presentation Layer)
- **Responsibility**: Display UI and handle user interactions only.
- **Access**: Can only access **Controllers** for state changes.
- **Restrictions**: No direct access to services or infrastructure.

#### Controllers (State Management)
- **Responsibility**: Manage application state and coordinate between UI and business logic.
- **Access**: Can access **Services** and **Infrastructure Providers**.
- **Pattern**: Implemented as Riverpod StateNotifiers/Providers.

#### Services (Application Layer)
- **Responsibility**: Implement business logic and use cases.
- **Access**: Can access **Repository interfaces** from the Domain layer and **Infrastructure Providers**.

```mermaid
graph LR
    Screen["Screen<br/>(Display UI)"] 
    Controller["Controller(UI Logic)<br/>(UI State Management)"]
    Service["Service<br/>(App Business Logic)<br/>(App State Management)"]
    RepoInterface["Repository Interface<br/>(Domain Contract)"]
    RepoImpl["Repository Implementation<br/>(Infrastructure Implementation)"]

    Screen --> Controller
    Controller --> Service
    Service --> RepoInterface
    RepoInterface --> RepoImpl

    classDef presentation fill:#040822,color:white,stroke:#85fbfd,stroke-width:1px
    classDef application fill:#040822,color:white,stroke:#3464fd,stroke-width:1px
    classDef domain fill:#040822,color:white,stroke:#cdced3,stroke-width:1px
    classDef infrastructure fill:#040822,color:white,stroke:#cdced3,stroke-width:1px

    class Screen,Controller presentation
    class Service application
    class RepoInterface domain
    class RepoImpl infrastructure
```

This ensures that:

- UI components remain pure and testable.
- Business logic is isolated from infrastructure concerns.
- Dependencies flow inward toward the domain core.
- Each layer has a single, well-defined responsibility.

### Affinidi Meeting Place SDK Integration

The app integrates with Affinidi Meeting Place using:

- **Core SDK**: Handles DID management and DIDComm messaging.
- **Chat SDK**: Provides messaging capabilities.
- **Repository Pattern**: Abstracts SDK interactions behind domain interfaces.
- **Provider Pattern**: Manages SDK instances through dependency injection.

This architecture ensures that the Affinidi SDK integration is properly abstracted and can be easily maintained or replaced if needed.

## Requirements

- Flutter 3.35.3
- Dart SDK ^3.9.2

## Getting started

Set up your environment to run the Meeting Place application.

#### Activate Melos

```bash
dart pub global activate melos && export PATH="$PATH":"$HOME/.pub-cache/bin"
```

> **NOTE:** Add the `export PATH="$PATH":"$HOME/.pub-cache/bin"` into your shell configuration file, like `~/.zshrc` or `~/.bashrc` to apply the new `PATH` permanently into your terminal.

#### Install Dependencies

```bash
melos pubget
```

#### Generate Models

To generate models, run the following command in your terminal:

```bash
melos gen
```

#### Generate Localised Strings

To generate localised strings from arb files, run the following command in your terminal:

```bash
melos strings
```

## Environment Variables

The Meeting Place reference app provides a `.example.env` template to populate the required variables and quickly setup the app.

To prepare the env variable, copy the environment file from the template.

```bash
mkdir -p configurations && cp templates/.example.env configurations/.env
```
> **NOTE:** Execute the command inside the root folder of the reference app.

Most environment variables have sensible defaults defined in the application. You only need to provide values specific to your setup or when you want to override the defaults.

### Required Environment Variables

The following variables **must** be provided in your `configurations/.env` file.

#### Connect to Control Plane API

The Control Plane API enables discovery and secure channel creation using DIDComm v2.1. Participants can publish a connection offer or invitation with one of their identities (e.g., gaming persona) for direct or group chat.

To create an instance of Control Plane API locally, follow the guide from the [Control Plane API for Dart](https://docs.affinidi.com/products/affinidi-messaging/meeting-place/deployment-options/control-plane-open-sourced/) open source project.

After setting up the API server, copy the `CONTROL_PLANE_DID` containing the `did:web` value from the env file.

```bash
# Required for MeetingPlaceCoreSDK functionality
# YourControl Plane DID
CONTROL_PLANE_DID=""
```

The `did:web` value can differ depending on your domain hosting the Control Plane API.

#### Connect to DIDComm Mediator

The DIDComm Mediator is a messaging server that routes messages securely between parties, such as individuals, businesses, or AI agents. Mediators cannot access message content.

To create an instance of DIDComm Mediator locally, follow the guide from the [DIDComm Mediator](https://docs.affinidi.com/products/affinidi-messaging/didcomm-mediator/deployment-options/mediator-open-sourced/) open source project.

Setting up DIDComm Mediator generates the Mediator DID that you can use to populate the `DEFAULT_MEDIATOR_DID` env variable.

```bash
# Required for MeetingPlaceCoreSDK functionality
# Your Mediator DID
DEFAULT_MEDIATOR_DID=""
```

#### Enable Push Notifications

To enable push notification, create a [Firebase](https://firebase.google.com/docs/projects/learn-more) project. After creating the project, follows the steps below:

##### Firebase iOS App

1. [Create an iOS app](https://firebase.google.com/docs/ios/setup#register-app) from your Firebase project.
2. Download the `GoogleService-Info.plist` from the iOS app settings.
3. Copy the downloaded `GoogleService-Info.plist` into the `app/ios/Runner` folder of the Meeting Place reference app.

> **NOTE:** Skip other steps, you only need to generate and download the `GoogleService-Info.plist` file.

##### Firebase Android App

1. [Create an Android app](https://firebase.google.com/docs/android/setup#register-app) from your Firebase project.
2. Download the `google-services.json` from the iOS app settings.
3. Copy the downloaded `google-services.json` into the `app/android/app` folder of the Meeting Place reference app.

> **NOTE:** Skip other steps, you only need to generate and download the `google-services.json` file.

After setting up the Firebase apps, populate the Firebase-related environment variables that can be found in the Firebase console or in the downloaded files.

```bash
# Required for Firebase integration
FIREBASE_MESSAGING_SENDER_ID=""
FIREBASE_PROJECT_ID=""
FIREBASE_STORAGE_BUCKET=""

FIREBASE_IOS_APIKEY=""
FIREBASE_IOS_APP_ID=""
FIREBASE_IOS_BUNDLE_ID=""

FIREBASE_ANDROID_APIKEY=""
FIREBASE_ANDROID_APP_ID=""
```

### Optional Environment Variables

The following variables have default values but can be customized:

```bash
# App configuration (defaults shown)
APP_VERSION_NAME=""                              # Default: ""
BIOMETRICS_ENABLED="true"                        # Default: true
DATABASE_LOGGING_ENABLED="false"                 # Default: false (debug mode only)
FOREGROUND_NOTIFICATIONS_ENABLED="false"         # Default: false
TAPS_TO_UNLOCK_DEBUG="7"                         # Default: 7

# Chat settings (defaults shown)
CHAT_ACTIVITY_EXPIRES_IN_SECONDS="3"             # Default: 3
CHAT_PRESENCE_SEND_INTERVAL_IN_SECONDS="60"      # Default: 60
CHAT_IMAGE_MAX_SIZE="800"                        # Default: 800
CHAT_IMAGE_QUALITY_PERCENT="80"                  # Default: 80

# Profile settings (defaults shown)
PROFILE_IMAGE_MAX_SIZE="100"                     # Default: 100
PROFILE_IMAGE_QUALITY_PERCENT="80"               # Default: 80

# Marketplace
MARKETPLACE_QR_PREFIX=""                         # Default: ""
```

> **NOTE:** You can find all available configuration options and their default values in `lib/infrastructure/configuration/environment.dart`.

## VSCode Configuration

If you are using VS Code as your IDE, you can quickly set up your launch configuration for this project:

```bash
mkdir -p .vscode && cp templates/.example.launch.json .vscode/launch.json
```

This pre-defined configuration is set up to point to the appropriate environment file for your project. You can further customize this file to add or modify device IDs, change environment files, or extend it to suit your development needs.

## Run App on Simulator

Refer to Flutter's [Get Started](https://docs.flutter.dev/get-started/install) page to learn more about setting up your environment to run the Flutter application on simulators.

## Troubleshooting

### Firebase Configuration Issues

**Error:** `FirebaseException ([core/duplicate-app] A Firebase App named "[DEFAULT]" already exists)`

**Cause:** This error occurs when there's a mismatch between your Firebase configuration files and the environment variables in `configurations/.env`.

**Solution:** Ensure the following values match:

1. Values in `google-services.json` (Android) must match `FIREBASE_ANDROID_*` variables in `.env`.
2. Values in `GoogleService-Info.plist` (iOS or macOS) must match `FIREBASE_IOS_*` variables in `.env`.
3. Common values like `FIREBASE_PROJECT_ID`, `FIREBASE_MESSAGING_SENDER_ID`, and `FIREBASE_STORAGE_BUCKET` must match across both platform files.

**Reference:** See [Firebase duplicate-app](https://github.com/firebase/flutterfire/blob/main/packages/firebase_core/firebase_core_platform_interface/lib/src/firebase_core_exceptions.dart#L20-L25) error definition.

## Support & Feedback

If you face any issues or have suggestions, please don't hesitate to contact us using [this link](https://share.hsforms.com/1i-4HKZRXSsmENzXtPdIG4g8oa2v).

### Reporting Technical Issues

If you have a technical issue with the project's codebase, you can also create an issue directly in GitHub.

1. Ensure the bug was not already reported by searching on GitHub under
   [Issues](https://github.com/affinidi/affinidi-meetingplace-reference-app/issues).

2. If you're unable to find an open issue addressing the problem,
   [open a new one](https://github.com/affinidi/affinidi-meetingplace-reference-app/issues/new).
   Be sure to include a **title and clear description**, as much relevant information as possible,
   and a **code sample** or an **executable test case** demonstrating the expected behaviour that is not occurring.

## Contributing

Want to contribute?

Head over to our [CONTRIBUTING](https://github.com/affinidi/affinidi-meetingplace-reference-app/blob/main/CONTRIBUTING.md) guidelines.
