// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'r_cards_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Service that drives the R-Card feature.
///
/// Responsibilities:
/// - Exposes all stored [RCard]s as live state for the UI.
/// - Delegates all persistence operations to [MeetingPlaceCredentialsSDK]
///   so consumers only need one dependency for the full R-Card feature.

@ProviderFor(RCardsService)
final rCardsServiceProvider = RCardsServiceProvider._();

/// Service that drives the R-Card feature.
///
/// Responsibilities:
/// - Exposes all stored [RCard]s as live state for the UI.
/// - Delegates all persistence operations to [MeetingPlaceCredentialsSDK]
///   so consumers only need one dependency for the full R-Card feature.
final class RCardsServiceProvider
    extends $NotifierProvider<RCardsService, List<RCard>> {
  /// Service that drives the R-Card feature.
  ///
  /// Responsibilities:
  /// - Exposes all stored [RCard]s as live state for the UI.
  /// - Delegates all persistence operations to [MeetingPlaceCredentialsSDK]
  ///   so consumers only need one dependency for the full R-Card feature.
  RCardsServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'rCardsServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$rCardsServiceHash();

  @$internal
  @override
  RCardsService create() => RCardsService();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<RCard> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<RCard>>(value),
    );
  }
}

String _$rCardsServiceHash() => r'e2969909150c50523c0b03503aa55a68f41e124f';

/// Service that drives the R-Card feature.
///
/// Responsibilities:
/// - Exposes all stored [RCard]s as live state for the UI.
/// - Delegates all persistence operations to [MeetingPlaceCredentialsSDK]
///   so consumers only need one dependency for the full R-Card feature.

abstract class _$RCardsService extends $Notifier<List<RCard>> {
  List<RCard> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<List<RCard>, List<RCard>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<RCard>, List<RCard>>,
              List<RCard>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
