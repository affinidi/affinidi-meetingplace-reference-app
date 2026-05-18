import 'dart:convert';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../application/services/vrc_service/vrc_service.dart';
import '../../../domain/models/vrc/vrc_credential.dart';
import '../../../domain/models/vrc/vrc_credential_subject.dart';
import 'vrc_attachment_state.dart';

part 'vrc_attachment_controller.g.dart';

@riverpod
class VrcAttachmentController extends _$VrcAttachmentController {
  @override
  VrcAttachmentState build(String vcBlob) {
    Future.microtask(() => _resolveCredential(vcBlob));
    return const VrcAttachmentState.initial();
  }

  Future<void> _resolveCredential(String vcBlob) async {
    state = const VrcAttachmentState.loading();

    final credentials = ref.read(vrcServiceProvider);
    final stored = credentials.where((v) => v.vc == vcBlob).firstOrNull;
    if (stored != null) {
      state = VrcAttachmentState.success(stored);
      return;
    }

    try {
      final decoded = jsonDecode(vcBlob) as Map<String, dynamic>;
      final subject = decoded['credentialSubject'];
      final subjectMap = switch (subject) {
        final Map<String, dynamic> m => m,
        final List<dynamic> l when l.isNotEmpty =>
          l.first as Map<String, dynamic>,
        _ => <String, dynamic>{},
      };
      final credSubject = VrcCredentialSubject.fromJson(subjectMap);
      final synthetic = VrcCredential(
        id: decoded['id'] as String? ?? vcBlob.hashCode.toString(),
        vc: vcBlob,
        channelId: '',
        holderIdentityDid: credSubject.to.did,
        issuerIdentityDid: credSubject.from.did,
        issuedAt:
            DateTime.tryParse(decoded['validFrom'] as String? ?? '') ??
            DateTime.now(),
      );
      state = VrcAttachmentState.success(synthetic);
    } catch (_) {
      state = const VrcAttachmentState.notFound();
    }
  }
}
