import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:meeting_place_core/meeting_place_core.dart'
    show $IdentityCopyWith, Identity;

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
  }) = _IdentityFormScreenState;
}
