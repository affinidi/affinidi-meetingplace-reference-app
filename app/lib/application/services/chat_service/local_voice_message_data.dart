import 'dart:typed_data';

/// Locally cached payload for a voice message sent from this device.
///
/// Retained while the chat session is open so the echoed hosted message can
/// render from memory instead of re-downloading the sender's own upload.
class LocalVoiceMessageData {
  const LocalVoiceMessageData({
    required this.bytes,
    required this.durationMs,
    required this.waveform,
  });

  final Uint8List bytes;
  final int durationMs;
  final List<int> waveform;
}
