import 'package:freezed_annotation/freezed_annotation.dart';

part 'settings_service_state.freezed.dart';

@Freezed(fromJson: false, toJson: false)
abstract class SettingsServiceState with _$SettingsServiceState {
  factory SettingsServiceState({
    required String selectedMediatorDid,
    @Default(false) bool isDebugMode,
    required bool alreadyOnboarded,
    @Default(false) bool shouldShowMeetingPlaceQR,
    @Default(true) bool isAutomaticMediaDownloadEnabled,
  }) = _SettingsServiceState;
}
