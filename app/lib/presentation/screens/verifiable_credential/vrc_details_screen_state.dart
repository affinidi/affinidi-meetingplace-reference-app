import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../domain/models/vrc/vrc_credential_subject.dart';

part 'vrc_details_screen_state.freezed.dart';

@Freezed(fromJson: false, toJson: false)
abstract class VrcDetailsScreenState with _$VrcDetailsScreenState {
  factory VrcDetailsScreenState({
    VrcCredentialSubject? subject,
    @Default([]) List<String> credentialTypes,
  }) = _VrcDetailsScreenState;
}
