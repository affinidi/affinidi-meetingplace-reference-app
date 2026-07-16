# Affinidi Meeting Place - LiveKit Flutter

![Affinidi Meeting Place](https://raw.githubusercontent.com/affinidi/affinidi-meetingplace-sdk-dart/main/assets/images/meetingplace-banner.png)

The Affinidi Meeting Place - LiveKit Flutter plugin provides real-time audio and video call rendering for the Meeting Place SDK via LiveKit with Matrix RTC signalling. It bridges the Matrix transport layer to LiveKit media transport with per-participant end-to-end encryption, and integrates with the `meeting_place_matrix` SDK to enable audio/video calls in Matrix-backed chat sessions.

> **DISCLAIMER:** Affinidi provides this SDK as a developer tool to facilitate decentralised messaging. Any personal data exchanged or stored via this tool is entirely initiated and controlled by end-users. Affinidi does not collect, access, or process such data. Implementing parties are responsible for ensuring that their applications comply with applicable privacy laws.

## Core Concepts

- **[LiveKit](https://livekit.io/)** - An open-source, scalable Selective Forwarding Unit (SFU) for real-time media transport of audio and video calls.
- **[WebRTC](https://webrtc.org/)** - An open standard for peer-to-peer multimedia communication over IP networks, enabling audio and video streaming.
- **Matrix RTC** - Matrix extension for managing call signalling and end-to-end encryption of real-time media via Matrix rooms.
- **End-to-End Encryption (E2EE)** - Per-participant encryption of call media streams using keys distributed by Matrix RTC, ensuring only authorised participants can decrypt media.

## Key Features

- Concrete `LiveKitRoom` implementation bridging LiveKit client to Meeting Place domain models.
- `FlutterMatrixRTCDelegate` for Matrix RTC signalling via `flutter_webrtc` and LiveKit peer connections.
- Per-participant E2EE with Matrix-distributed encryption keys and LiveKit FrameCryptor integration.
- `AudioVideoCallView` widget for rendering video tracks of local and remote participants.
- Participant extensions for mapping LiveKit participants to domain objects with DID correlation.

## Requirements

- Flutter `>=3.24.0`.
- Dart SDK `>=3.8.0`.
- [`meeting_place_matrix`](https://pub.dev/packages/meeting_place_matrix) SDK with `MatrixConfig` that includes `livekitServiceUrl` and `livekitSfuUrl`.
- Vodozemac encryption runtime initialized once in `main()` before creating the SDK (see [`meeting_place_matrix` README](https://pub.dev/packages/meeting_place_matrix#initializing-the-encryption-runtime)).

## Installation

Run:

```bash
flutter pub add meeting_place_livekit_flutter
```

or manually, add the package into your `pubspec.yaml` file:

```yaml
dependencies:
  meeting_place_livekit_flutter: ^<version_number>
```

and then run the command below to install the package:

```bash
flutter pub get
```

Visit the pub.dev [install page](https://pub.dev/packages/meeting_place_livekit_flutter) of the Dart package for more information.

## Usage

Integrate the plugin into `MeetingPlaceMatrixSDK.create()` to handle audio and video calls. Set up in this order:

1. Initialize vodozemac in `main()`:

```dart
import 'package:flutter_vodozemac/flutter_vodozemac.dart' as fvod;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await fvod.init();
  // Continue with app startup
}
```

2. Create `MatrixConfig` with LiveKit endpoints:

```dart
config: MatrixConfig(
  // ... other settings ...
  livekitServiceUrl: Uri.parse('https://your-livekit-jwt-service'),
  livekitSfuUrl: Uri.parse('wss://your-livekit-sfu'),
)
```

3. Pass the RTC delegate and room factory when creating the Matrix SDK:

```dart
import 'package:flutter/widgets.dart';
import 'package:meeting_place_livekit_flutter/meeting_place_livekit_flutter.dart';
import 'package:meeting_place_matrix/meeting_place_matrix.dart';

final matrixSDK = await MeetingPlaceMatrixSDK.create(
  wallet: wallet,
  repositoryConfig: repositoryConfig,
  config: matrixConfig,  // With livekitServiceUrl and livekitSfuUrl
  rtcDelegate: FlutterMatrixRTCDelegate(),
  roomFactory: (_) => FlutterLiveKitRoom(),
  options: MeetingPlaceMatrixSdkOptions(
    // ... options
  ),
);
```

4. Initialize the Matrix chat SDK from a channel:

```dart
final chatSDK = await MeetingPlaceMatrixChatSDK.initialiseFromChannel(
  channel,
  coreSDK: matrixSDK,
  chatRepository: chatRepository,
);

final chat = await chatSDK.startChatSession();
```

Once set up, audio and video calls within Matrix rooms use Matrix RTC for signalling and LiveKit for media transport, with per-participant end-to-end encryption handled automatically.

For more sample usage, go to the [example folder](https://github.com/affinidi/affinidi-meetingplace-reference-app/tree/main/packages/meeting_place_livekit_flutter/example).

## Support & feedback

If you face any issues or have suggestions, please don't hesitate to contact us using [this link](https://share.hsforms.com/1i-4HKZRXSsmENzXtPdIG4g8oa2v).

### Reporting technical issues

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
