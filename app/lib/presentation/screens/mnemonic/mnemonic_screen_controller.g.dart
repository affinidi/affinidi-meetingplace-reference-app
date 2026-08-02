// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mnemonic_screen_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(MnemonicScreenController)
const mnemonicScreenControllerProvider = MnemonicScreenControllerProvider._();

final class MnemonicScreenControllerProvider
    extends $NotifierProvider<MnemonicScreenController, MnemonicScreenState> {
  const MnemonicScreenControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'mnemonicScreenControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$mnemonicScreenControllerHash();

  @$internal
  @override
  MnemonicScreenController create() => MnemonicScreenController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MnemonicScreenState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MnemonicScreenState>(value),
    );
  }
}

String _$mnemonicScreenControllerHash() =>
    r'7905423a53b4fd536484a3245648964284e869d5';

abstract class _$MnemonicScreenController
    extends $Notifier<MnemonicScreenState> {
  MnemonicScreenState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<MnemonicScreenState, MnemonicScreenState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<MnemonicScreenState, MnemonicScreenState>,
              MnemonicScreenState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
