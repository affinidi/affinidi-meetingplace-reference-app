// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vrc_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Service that manages Verifiable Relationship Credentials (VRC).
///
/// Responsibilities:
/// - Exposes all stored [VrcCredential]s as live state for the UI.
/// - Provides methods to save, delete, and query VRCs.

@ProviderFor(VrcService)
final vrcServiceProvider = VrcServiceProvider._();

/// Service that manages Verifiable Relationship Credentials (VRC).
///
/// Responsibilities:
/// - Exposes all stored [VrcCredential]s as live state for the UI.
/// - Provides methods to save, delete, and query VRCs.
final class VrcServiceProvider
    extends $NotifierProvider<VrcService, List<VrcCredential>> {
  /// Service that manages Verifiable Relationship Credentials (VRC).
  ///
  /// Responsibilities:
  /// - Exposes all stored [VrcCredential]s as live state for the UI.
  /// - Provides methods to save, delete, and query VRCs.
  VrcServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'vrcServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$vrcServiceHash();

  @$internal
  @override
  VrcService create() => VrcService();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<VrcCredential> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<VrcCredential>>(value),
    );
  }
}

String _$vrcServiceHash() => r'4fc1d3bd8ca0a86f5d2b63ef4b1b37e8a30f8ed1';

/// Service that manages Verifiable Relationship Credentials (VRC).
///
/// Responsibilities:
/// - Exposes all stored [VrcCredential]s as live state for the UI.
/// - Provides methods to save, delete, and query VRCs.

abstract class _$VrcService extends $Notifier<List<VrcCredential>> {
  List<VrcCredential> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<List<VrcCredential>, List<VrcCredential>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<VrcCredential>, List<VrcCredential>>,
              List<VrcCredential>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
