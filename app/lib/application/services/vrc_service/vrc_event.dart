import '../../../domain/models/vrc/vrc_credential.dart';

sealed class VrcEvent {
  const VrcEvent();
}

final class VrcReceived extends VrcEvent {
  const VrcReceived({required this.credential});

  final VrcCredential credential;
}
