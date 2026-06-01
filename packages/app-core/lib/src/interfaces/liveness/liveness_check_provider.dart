import 'package:flutter/material.dart';
import 'package:meeting_place_credentials/meeting_place_credentials.dart';

/// Interactive liveness check for vendors that need UI (camera, native SDK).
///
/// For headless or demo flows, use `LivenessEvidenceSource` in the SDK instead.
/// Register an implementation via `livenessCheckProviderProvider` in the
/// host app.
/// See `packages/app-core/README.md` for integration steps.
abstract interface class LivenessCheckProvider {
  /// Vendor id stored on the credential, e.g. `azure_face_liveness`.
  String get providerId;

  /// Returns [LivenessEvidence] on success, or `null` if the user cancels.
  Future<LivenessEvidence?> collectEvidence({
    required BuildContext context,
    required String holderDid,
  });
}
