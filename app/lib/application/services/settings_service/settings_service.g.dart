// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$settingsServiceHash() => r'd6b38f6aa0564888d5b503eb1af89a682517f29f';

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
///
/// Copied from [SettingsService].
@ProviderFor(SettingsService)
final settingsServiceProvider =
    NotifierProvider<SettingsService, SettingsServiceState>.internal(
      SettingsService.new,
      name: r'settingsServiceProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$settingsServiceHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$SettingsService = Notifier<SettingsServiceState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
