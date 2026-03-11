// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_logger_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$appLoggerHash() => r'f33c31fa60711e20bec1a671bd6813515b933036';

/// A Riverpod provider that exposes the global [AppLogger] instance.
///
/// Useful for consistent logging across the app.
///
/// [ref] - The Riverpod reference used for dependency injection.
///
/// Copied from [appLogger].
@ProviderFor(appLogger)
final appLoggerProvider = Provider<AppLogger>.internal(
  appLogger,
  name: r'appLoggerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$appLoggerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AppLoggerRef = ProviderRef<AppLogger>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
