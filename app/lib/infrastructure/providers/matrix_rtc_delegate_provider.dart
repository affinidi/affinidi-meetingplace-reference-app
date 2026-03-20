import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../services/matrix/flutter_matrix_rtc_delegate.dart';

part 'matrix_rtc_delegate_provider.g.dart';

/// A singleton `FlutterMatrixRTCDelegate` that is injected into the `VoIP`
/// instance. Kept alive so the call layer can install an
/// `EncryptionKeyProvider` on it before a call starts.
@Riverpod(keepAlive: true)
FlutterMatrixRTCDelegate matrixRtcDelegate(Ref ref) {
  return FlutterMatrixRTCDelegate();
}
