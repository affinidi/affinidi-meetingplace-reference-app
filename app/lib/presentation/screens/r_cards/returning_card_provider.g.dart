// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'returning_card_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider used to trigger the "return" animation when navigating back
/// from [RCardDetailsScreen].

@ProviderFor(ReturningCard)
const returningCardProvider = ReturningCardProvider._();

/// Provider used to trigger the "return" animation when navigating back
/// from [RCardDetailsScreen].
final class ReturningCardProvider
    extends $NotifierProvider<ReturningCard, String?> {
  /// Provider used to trigger the "return" animation when navigating back
  /// from [RCardDetailsScreen].
  const ReturningCardProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'returningCardProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$returningCardHash();

  @$internal
  @override
  ReturningCard create() => ReturningCard();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }
}

String _$returningCardHash() => r'afb72c0cfd6d90b9ed7f44dbbb0e95ba0e6c6894';

/// Provider used to trigger the "return" animation when navigating back
/// from [RCardDetailsScreen].

abstract class _$ReturningCard extends $Notifier<String?> {
  String? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<String?, String?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String?, String?>,
              String?,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
