// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mnemonic_configured_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Tracks whether a mnemonic has been stored for the current wallet.
///
/// Backed by SharedPreferences so the value is correct synchronously on every
/// app launch — no async race with the router guard or SDK provider.
/// SDK-dependent services must not be initialized until this is `true`.

@ProviderFor(MnemonicConfigured)
const mnemonicConfiguredProvider = MnemonicConfiguredProvider._();

/// Tracks whether a mnemonic has been stored for the current wallet.
///
/// Backed by SharedPreferences so the value is correct synchronously on every
/// app launch — no async race with the router guard or SDK provider.
/// SDK-dependent services must not be initialized until this is `true`.
final class MnemonicConfiguredProvider
    extends $NotifierProvider<MnemonicConfigured, bool> {
  /// Tracks whether a mnemonic has been stored for the current wallet.
  ///
  /// Backed by SharedPreferences so the value is correct synchronously on every
  /// app launch — no async race with the router guard or SDK provider.
  /// SDK-dependent services must not be initialized until this is `true`.
  const MnemonicConfiguredProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'mnemonicConfiguredProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$mnemonicConfiguredHash();

  @$internal
  @override
  MnemonicConfigured create() => MnemonicConfigured();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$mnemonicConfiguredHash() =>
    r'e4c148c7afec4cf913e429cc52c954c496e9df0b';

/// Tracks whether a mnemonic has been stored for the current wallet.
///
/// Backed by SharedPreferences so the value is correct synchronously on every
/// app launch — no async race with the router guard or SDK provider.
/// SDK-dependent services must not be initialized until this is `true`.

abstract class _$MnemonicConfigured extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
