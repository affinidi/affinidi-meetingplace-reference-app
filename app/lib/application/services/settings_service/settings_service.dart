import 'dart:async';

import 'package:meeting_place_chat/meeting_place_chat.dart' as chat_sdk;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../infrastructure/configuration/environment.dart';
import '../../../infrastructure/loggers/app_logger/app_logger.dart';
import '../../../infrastructure/providers/app_logger_provider.dart';
import '../../../infrastructure/providers/shared_preferences_provider.dart';
import '../../../infrastructure/secure_storage/secure_storage.dart';
import 'settings_service_state.dart';

part 'settings_service.g.dart';

/// Service responsible for application settings and mediator configuration.
///
/// This service provides functionality to:
/// - Restore and persist the preferred mediator DID
/// - Load available default and custom mediators
/// - Manage debug mode toggling and its persistence
/// - Manage automatic media download preference and its persistence
/// - Track onboarding completion flag
///
/// It reads environment defaults and secure storage, exposes the combined list
/// of mediators, and updates persistent storage when settings change.
@Riverpod(keepAlive: true)
class SettingsService extends _$SettingsService {
  static const _logKey = 'STGSVC';
  late final AppLogger _logger = ref.read(appLoggerProvider);

  @override
  SettingsServiceState build() {
    final defaultMediatorDid = ref.read(environmentProvider).defaultMediatorDid;
    final isAutomaticMediaDownloadEnabled =
        _getAutomaticMediaDownloadPreference();

    _applyAutomaticMediaDownloadPreference(isAutomaticMediaDownloadEnabled);

    Future.microtask(() async {
      await _restorePreferredMediatorIdIfNeeded();
      await _restoreDebugMode();
      await _restoreShouldShowMeetingPlaceQr();
    });

    final alreadyOnboarded = _getFinishOnboarding();
    return SettingsServiceState(
      selectedMediatorDid: defaultMediatorDid,
      alreadyOnboarded: alreadyOnboarded,
      isAutomaticMediaDownloadEnabled: isAutomaticMediaDownloadEnabled,
    );
  }

  /// Restore the preferred mediator DID from secure storage if present.
  ///
  /// Reads the secure storage provider and, if a preferred mediator DID is
  /// found, updates provider state.
  Future<void> _restorePreferredMediatorIdIfNeeded() async {
    final provider = await ref.read(secureStorageProvider.future);
    final preferredMediatorDid = await provider.getPreferredMediatorDid();
    if (preferredMediatorDid == null) return;
    state = state.copyWith(selectedMediatorDid: preferredMediatorDid);
  }

  /// Select a mediator configuration and persist it in-memory.
  ///
  /// Updates the selected mediator DID in state and logs the operation.
  ///
  /// [mediatorDid] - The DID of the mediator to select.
  Future<void> selectMediatorConfig(String mediatorDid) async {
    _logger.info('Started updating mediator', name: _logKey);
    final provider = await ref.read(secureStorageProvider.future);
    await provider.setPreferredMediatorDid(mediatorDid);
    state = state.copyWith(selectedMediatorDid: mediatorDid);
    _logger.info('Completed updating mediator', name: _logKey);
  }

  /// Toggle the debug mode for the application and persist the setting.
  ///
  /// Enables or disables the debug log collector, updates state and writes the
  /// debug flag to secure storage.
  ///
  /// Returns:
  /// - `Future<void>` completes when the debug mode state and storage are
  ///  updated.
  Future<void> toggleDebugMode() async {
    final provider = await ref.read(secureStorageProvider.future);
    final newDebugMode = !state.isDebugMode;

    state = state.copyWith(isDebugMode: newDebugMode);
    await provider.saveDebugMode(newDebugMode);

    _logger.info(
      'Debug mode ${newDebugMode ? 'enabled' : 'disabled'}',
      name: _logKey,
    );
  }

  Future<void> toggleShouldShowMeetingPlaceQR() async {
    final newValue = !state.shouldShowMeetingPlaceQR;
    state = state.copyWith(shouldShowMeetingPlaceQR: newValue);

    final provider = await ref.read(secureStorageProvider.future);
    await provider.saveShouldShowMeetingPlaceQR(newValue);

    _logger.info(
      'Show connection offer QR code ${newValue ? 'enabled' : 'disabled'}',
      name: _logKey,
    );
  }

  Future<void> toggleAutomaticMediaDownload() async {
    final newValue = !state.isAutomaticMediaDownloadEnabled;
    final prefs = ref.read(sharedPreferencesProvider);

    state = state.copyWith(isAutomaticMediaDownloadEnabled: newValue);
    _applyAutomaticMediaDownloadPreference(newValue);
    await prefs.setBool(
      SharedPreferencesKeys.automaticMediaDownload.name,
      newValue,
    );

    _logger.info(
      'Automatic media download ${newValue ? 'enabled' : 'disabled'}',
      name: _logKey,
    );
  }

  /// Persist the onboarding completion flag in shared preferences.
  ///
  /// [value] - `true` when onboarding has completed, `false` otherwise.
  ///
  /// Returns:
  /// - `Future<void>` completes when the preference is saved and state updated.
  Future<void> setAlreadyOnboarded(bool value) async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setBool(SharedPreferencesKeys.alreadyOnboarded.name, value);
    state = state.copyWith(alreadyOnboarded: value);
  }

  /// Load the onboarding completion flag from shared preferences.
  ///
  /// Reads the onboarding flag and updates state. If not present, defaults to
  ///  `false`.
  bool _getFinishOnboarding() {
    final prefs = ref.read(sharedPreferencesProvider);
    return prefs.getBool(SharedPreferencesKeys.alreadyOnboarded.name) ?? false;
  }

  bool _getAutomaticMediaDownloadPreference() {
    final prefs = ref.read(sharedPreferencesProvider);
    return prefs.getBool(SharedPreferencesKeys.automaticMediaDownload.name) ??
        _isAutomaticDownloadEnabled();
  }

  /// Restore the "show meeting place QR" setting from secure storage.
  ///
  /// If a saved value exists, updates state accordingly.
  Future<void> _restoreShouldShowMeetingPlaceQr() async {
    final provider = await ref.read(secureStorageProvider.future);
    final showMeetingPlaceQr = await provider.getShouldShowMeetingPlaceQR();
    if (showMeetingPlaceQr == null) return;

    state = state.copyWith(shouldShowMeetingPlaceQR: showMeetingPlaceQr);
  }

  /// Restore debug mode value from secure storage and apply it.
  ///
  /// If a saved debug mode value exists, updates state and registers the
  /// debug log collector if enabled.
  Future<void> _restoreDebugMode() async {
    final provider = await ref.read(secureStorageProvider.future);
    final debugMode = await provider.getDebugMode();
    if (debugMode == null) return;

    state = state.copyWith(isDebugMode: debugMode);
  }

  void _applyAutomaticMediaDownloadPreference(bool isEnabled) {
    if (isEnabled) {
      _enableAutomaticDownload();
      return;
    }

    _disableAutomaticDownload();
  }

  bool _isAutomaticDownloadEnabled() {
    return chat_sdk.ChatSDK.isAutomaticDownloadEnabled();
  }

  void _enableAutomaticDownload() {
    chat_sdk.ChatSDK.enableAutomaticDownload();
  }

  void _disableAutomaticDownload() {
    chat_sdk.ChatSDK.disableAutomaticDownload();
  }
}
