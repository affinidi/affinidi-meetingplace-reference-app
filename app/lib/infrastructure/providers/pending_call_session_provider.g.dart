// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pending_call_session_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Short-lived holder used to hand a pre-created [AudioVideoCallSession]
/// to the call screen on inbound-call accept.
///
/// The incoming-call banner or chat item calls [set] before navigating to the
/// call screen. The screen's controller reads and immediately calls [clear]
/// in `build()`.

@ProviderFor(PendingCallSession)
const pendingCallSessionProvider = PendingCallSessionProvider._();

/// Short-lived holder used to hand a pre-created [AudioVideoCallSession]
/// to the call screen on inbound-call accept.
///
/// The incoming-call banner or chat item calls [set] before navigating to the
/// call screen. The screen's controller reads and immediately calls [clear]
/// in `build()`.
final class PendingCallSessionProvider
    extends $NotifierProvider<PendingCallSession, AudioVideoCallSession?> {
  /// Short-lived holder used to hand a pre-created [AudioVideoCallSession]
  /// to the call screen on inbound-call accept.
  ///
  /// The incoming-call banner or chat item calls [set] before navigating to the
  /// call screen. The screen's controller reads and immediately calls [clear]
  /// in `build()`.
  const PendingCallSessionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pendingCallSessionProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pendingCallSessionHash();

  @$internal
  @override
  PendingCallSession create() => PendingCallSession();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AudioVideoCallSession? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AudioVideoCallSession?>(value),
    );
  }
}

String _$pendingCallSessionHash() =>
    r'9625b644681f4d589f1a120e9e76ca0ec73c03c3';

/// Short-lived holder used to hand a pre-created [AudioVideoCallSession]
/// to the call screen on inbound-call accept.
///
/// The incoming-call banner or chat item calls [set] before navigating to the
/// call screen. The screen's controller reads and immediately calls [clear]
/// in `build()`.

abstract class _$PendingCallSession extends $Notifier<AudioVideoCallSession?> {
  AudioVideoCallSession? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref as $Ref<AudioVideoCallSession?, AudioVideoCallSession?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AudioVideoCallSession?, AudioVideoCallSession?>,
              AudioVideoCallSession?,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
