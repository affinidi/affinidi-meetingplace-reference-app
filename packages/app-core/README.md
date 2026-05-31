# mpx_app_core

Shared extension interfaces for the Affinidi Meeting Place reference app.

## LivenessCheckProvider

Use this when a liveness vendor needs **camera or native UI** on the liveness screen (Azure, AWS Face Liveness, etc.).

1. Implement `LivenessCheckProvider` in your app or plugin.
2. Map the vendor result to `LivenessEvidence` (from `meeting_place_relationship`).
3. Register it in `livenessCheckProviderProvider` (see `app/lib/infrastructure/providers/liveness_check_provider.dart`).

```dart
class AzureFaceLivenessProvider implements LivenessCheckProvider {
  @override
  String get providerId => 'azure_face_liveness';

  @override
  Future<LivenessEvidence?> collectEvidence({
    required BuildContext context,
    required String holderDid,
  }) async {
    // Run vendor UI, return LivenessEvidence or null if cancelled
  }
}
```

If you do not register a provider, the reference app uses demo evidence instead.
Credential issuance, ZKP, and chat proof flow stay unchanged.

## Other exports

- `AttachmentPlugin` — custom chat attachment pickers and renderers

## Related

- Root README: [Liveness Credential pipeline](../../README.md#liveness-credential-pipeline)
