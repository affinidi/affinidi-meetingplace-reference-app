// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'identities_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Service responsible for managing identities and the current contact card.
///
/// This service provides functionality to:
/// - Load and persist identities via a repository
/// - Add, update and delete identities
/// - Resolve and manage the currently selected identity
/// - Expose the current contact card derived from the selected identity
///
/// The service initializes by loading identities and keeps the current identity
/// in sync with environment defaults and repository state.

@ProviderFor(IdentitiesService)
const identitiesServiceProvider = IdentitiesServiceProvider._();

/// Service responsible for managing identities and the current contact card.
///
/// This service provides functionality to:
/// - Load and persist identities via a repository
/// - Add, update and delete identities
/// - Resolve and manage the currently selected identity
/// - Expose the current contact card derived from the selected identity
///
/// The service initializes by loading identities and keeps the current identity
/// in sync with environment defaults and repository state.
final class IdentitiesServiceProvider
    extends $NotifierProvider<IdentitiesService, IdentitiesServiceState> {
  /// Service responsible for managing identities and the current contact card.
  ///
  /// This service provides functionality to:
  /// - Load and persist identities via a repository
  /// - Add, update and delete identities
  /// - Resolve and manage the currently selected identity
  /// - Expose the current contact card derived from the selected identity
  ///
  /// The service initializes by loading identities and keeps the current identity
  /// in sync with environment defaults and repository state.
  const IdentitiesServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'identitiesServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$identitiesServiceHash();

  @$internal
  @override
  IdentitiesService create() => IdentitiesService();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(IdentitiesServiceState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<IdentitiesServiceState>(value),
    );
  }
}

String _$identitiesServiceHash() => r'8e71d9deae681da21d20290e3405c7fc0ccdc520';

/// Service responsible for managing identities and the current contact card.
///
/// This service provides functionality to:
/// - Load and persist identities via a repository
/// - Add, update and delete identities
/// - Resolve and manage the currently selected identity
/// - Expose the current contact card derived from the selected identity
///
/// The service initializes by loading identities and keeps the current identity
/// in sync with environment defaults and repository state.

abstract class _$IdentitiesService extends $Notifier<IdentitiesServiceState> {
  IdentitiesServiceState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref as $Ref<IdentitiesServiceState, IdentitiesServiceState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<IdentitiesServiceState, IdentitiesServiceState>,
              IdentitiesServiceState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
