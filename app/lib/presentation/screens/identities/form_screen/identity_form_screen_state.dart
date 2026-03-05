import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../domain/models/identity/identity.dart';
import '../../../config/persona_field_config.dart';

part 'identity_form_screen_state.freezed.dart';

@Freezed(fromJson: false, toJson: false)
abstract class IdentityFormScreenState with _$IdentityFormScreenState {
  factory IdentityFormScreenState({
    required Identity identity,
    @Default(true) bool canSave,
    @Default(true) bool canDelete,
    @Default(false) bool hasEnteredAnyInfo,
    @Default(false) bool hasSaved,
    @Default(false) bool hasDeleted,
    @Default(true) bool isAliasMirroringFirstName,
    @Default({}) Set<PersonaField> showingErrorFields,
  }) = _IdentityFormScreenState;
}
