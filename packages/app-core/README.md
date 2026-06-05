# mpx_app_core

Shared extension interfaces for the Affinidi Meeting Place reference app.

## Exports

`mpx_app_core` currently exports:

- `LivenessCheckProvider`
- `AttachmentPlugin`
- `MessageAttachment`
- `AttachmentPluginPickResult`
- `Attachment`, `AttachmentData`, `AttachmentMediaType` (re-exported from `meeting_place_core`)

## LivenessCheckProvider

Use this when a liveness vendor needs **camera or native UI** on the liveness screen (Azure, AWS Face Liveness, etc.).

1. Implement `LivenessCheckProvider` in your app or plugin.
2. Map the vendor result to `LivenessEvidence` (from `meeting_place_credentials`).
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

### AttachmentPlugin

Use this to add custom attachment sources and renderers to chat.

Core responsibilities:

- expose an icon (`icon`)
- pick attachments from UI (`pickAttachments`)
- render one or many attachments (`renderAttachment`, `renderAttachments`)
- declare supported attachment formats (`supportsFormat`)
- provide localized label (`localizedName`)

### MessageAttachment

Use this as your plugin-level attachment model and convert it to DIDComm attachment payloads with `toAttachment()`.

### AttachmentPluginPickResult

Return this from `AttachmentPlugin.pickAttachments` to provide:

- `text`: optional composed text to send with picked attachments
- `attachments`: a list of `MessageAttachment` objects selected by the plugin

```dart
class MyPickedAttachment implements MessageAttachment {
  MyPickedAttachment({required super.pluginName, required this.bytes});

  final List<int> bytes;

  @override
  Attachment toAttachment() {
    // Build and return a meeting_place_core Attachment
    throw UnimplementedError();
  }
}
```

## Related

- Root README: [Liveness Credential pipeline](../../README.md#liveness-credential-pipeline)
