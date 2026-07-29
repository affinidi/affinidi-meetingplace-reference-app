## 0.0.1-dev.6

 - **FIX**: badge unread missed and declined calls for both parties (#244).

## 0.0.1-dev.5

 - **FEAT**: group call participant list with per-member ring (#261).

## 0.0.1-dev.4

 - **FIX**: clear stuck incoming call banner and ringing state after app background (#264).

## 0.0.1-dev.3

 - **FEAT**: group video call (#259).

## 0.0.1-dev.2

 - **FIX**: show participant tiles, names, and avatars in group audio calls (#252).

## 0.0.1-dev.1

 - **FEAT**: publish meeting_place_livekit_flutter (#248).
 - **FEAT**: add meeting_place_livekit_flutter package with audio/video call rendering (#196).

# Change Log

## 0.0.1-dev.0

### Added

- Flutter plugin for real-time audio and video call rendering via LiveKit and Matrix RTC signalling.

- `FlutterMatrixRTCDelegate` implementation for Matrix RTC signalling with `flutter_webrtc` peer connections.

- `FlutterLiveKitRoom` implementation bridging LiveKit client to Meeting Place domain models.

- `AudioVideoCallView` Flutter widget for rendering local and remote participant video tracks.

- Per-participant end-to-end encryption integration with Matrix RTC and LiveKit FrameCryptor.

- Participant extensions for mapping LiveKit participants to domain objects with DID correlation.

- Example app demonstrating integration with `meeting_place_matrix` SDK for audio/video calling.
