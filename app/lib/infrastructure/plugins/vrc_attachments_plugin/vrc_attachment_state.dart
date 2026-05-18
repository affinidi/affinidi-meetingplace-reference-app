import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../domain/models/vrc/vrc_credential.dart';

part 'vrc_attachment_state.freezed.dart';

/// State for a single verifiable relationship credential attachment.
@freezed
class VrcAttachmentState with _$VrcAttachmentState {
  const factory VrcAttachmentState.initial() = _VrcAttachmentStateInitial;
  const factory VrcAttachmentState.loading() = _VrcAttachmentStateLoading;
  const factory VrcAttachmentState.success(VrcCredential credential) =
      _VrcAttachmentStateSuccess;
  const factory VrcAttachmentState.notFound() = _VrcAttachmentStateNotFound;
  const factory VrcAttachmentState.error(String message) =
      _VrcAttachmentStateError;
}
