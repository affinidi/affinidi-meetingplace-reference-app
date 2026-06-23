// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'oob_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Service responsible for creating and accepting out-of-band (OOB) flows.
///
/// This service provides functionality to:
/// - Create an OOB offer that can be shared (e.g., via QR) to initiate a
///  connection.
/// - Accept an incoming OOB offer URL and complete the connection flow.
/// - Observe control plane events to finalize connections and update state.
/// - Expose the last established channel and the current OOB offer in state.

@ProviderFor(OOBService)
const oOBServiceProvider = OOBServiceProvider._();

/// Service responsible for creating and accepting out-of-band (OOB) flows.
///
/// This service provides functionality to:
/// - Create an OOB offer that can be shared (e.g., via QR) to initiate a
///  connection.
/// - Accept an incoming OOB offer URL and complete the connection flow.
/// - Observe control plane events to finalize connections and update state.
/// - Expose the last established channel and the current OOB offer in state.
final class OOBServiceProvider
    extends $NotifierProvider<OOBService, OOBServiceState> {
  /// Service responsible for creating and accepting out-of-band (OOB) flows.
  ///
  /// This service provides functionality to:
  /// - Create an OOB offer that can be shared (e.g., via QR) to initiate a
  ///  connection.
  /// - Accept an incoming OOB offer URL and complete the connection flow.
  /// - Observe control plane events to finalize connections and update state.
  /// - Expose the last established channel and the current OOB offer in state.
  const OOBServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'oOBServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$oOBServiceHash();

  @$internal
  @override
  OOBService create() => OOBService();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(OOBServiceState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<OOBServiceState>(value),
    );
  }
}

String _$oOBServiceHash() => r'aed2221c2ba5b5b0767d55cef845097c851530d0';

/// Service responsible for creating and accepting out-of-band (OOB) flows.
///
/// This service provides functionality to:
/// - Create an OOB offer that can be shared (e.g., via QR) to initiate a
///  connection.
/// - Accept an incoming OOB offer URL and complete the connection flow.
/// - Observe control plane events to finalize connections and update state.
/// - Expose the last established channel and the current OOB offer in state.

abstract class _$OOBService extends $Notifier<OOBServiceState> {
  OOBServiceState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<OOBServiceState, OOBServiceState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<OOBServiceState, OOBServiceState>,
              OOBServiceState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
