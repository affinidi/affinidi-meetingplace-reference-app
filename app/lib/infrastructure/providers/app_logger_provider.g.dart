// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_logger_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// A Riverpod provider that exposes the global [AppLogger] instance.
///
/// Useful for consistent logging across the app.
///
/// [ref] - The Riverpod reference used for dependency injection.

@ProviderFor(appLogger)
const appLoggerProvider = AppLoggerProvider._();

/// A Riverpod provider that exposes the global [AppLogger] instance.
///
/// Useful for consistent logging across the app.
///
/// [ref] - The Riverpod reference used for dependency injection.

final class AppLoggerProvider
    extends $FunctionalProvider<AppLogger, AppLogger, AppLogger>
    with $Provider<AppLogger> {
  /// A Riverpod provider that exposes the global [AppLogger] instance.
  ///
  /// Useful for consistent logging across the app.
  ///
  /// [ref] - The Riverpod reference used for dependency injection.
  const AppLoggerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appLoggerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appLoggerHash();

  @$internal
  @override
  $ProviderElement<AppLogger> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AppLogger create(Ref ref) {
    return appLogger(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppLogger value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppLogger>(value),
    );
  }
}

String _$appLoggerHash() => r'f33c31fa60711e20bec1a671bd6813515b933036';
