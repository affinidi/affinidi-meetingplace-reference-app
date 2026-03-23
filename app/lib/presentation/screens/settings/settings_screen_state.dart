import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../domain/models/mediator/mediator.dart';
import '../../../infrastructure/configuration/app_info.dart';

part 'settings_screen_state.freezed.dart';

@Freezed(fromJson: false, toJson: false)
abstract class SettingsScreenState with _$SettingsScreenState {
  factory SettingsScreenState({
    AppInfo? appInfo,
    required int numberOfTapsToUnlockDebug,
    @Default([]) List<Mediator> mediators,
    @Default('') String selectedMediatorDid,
    @Default(false) bool isDebugMode,
    @Default(false) bool shouldShowMeetingPlaceQR,
    @Default(true) bool isAutomaticMediaDownloadEnabled,
  }) = _SettingsScreenState;
}
