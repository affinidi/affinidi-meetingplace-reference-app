// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'call_participants_ring_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Tracks the per-member re-ring state for a group call's participant list,
/// keyed by the member's DID.
///
/// Drives the bell -> ringing -> timeout affordance in the participant sheet
/// and sends the targeted call-invite to that member through the SDK. State is
/// held here (not in the sheet) so it survives the sheet closing and reopening
/// while a ring is still in flight.

@ProviderFor(CallParticipantsRingController)
const callParticipantsRingControllerProvider =
    CallParticipantsRingControllerFamily._();

/// Tracks the per-member re-ring state for a group call's participant list,
/// keyed by the member's DID.
///
/// Drives the bell -> ringing -> timeout affordance in the participant sheet
/// and sends the targeted call-invite to that member through the SDK. State is
/// held here (not in the sheet) so it survives the sheet closing and reopening
/// while a ring is still in flight.
final class CallParticipantsRingControllerProvider
    extends
        $NotifierProvider<
          CallParticipantsRingController,
          Map<String, CallRingState>
        > {
  /// Tracks the per-member re-ring state for a group call's participant list,
  /// keyed by the member's DID.
  ///
  /// Drives the bell -> ringing -> timeout affordance in the participant sheet
  /// and sends the targeted call-invite to that member through the SDK. State is
  /// held here (not in the sheet) so it survives the sheet closing and reopening
  /// while a ring is still in flight.
  const CallParticipantsRingControllerProvider._({
    required CallParticipantsRingControllerFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'callParticipantsRingControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$callParticipantsRingControllerHash();

  @override
  String toString() {
    return r'callParticipantsRingControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  CallParticipantsRingController create() => CallParticipantsRingController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Map<String, CallRingState> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Map<String, CallRingState>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is CallParticipantsRingControllerProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$callParticipantsRingControllerHash() =>
    r'1a79afb7907610c1bc2e50825e636e7d0f564f07';

/// Tracks the per-member re-ring state for a group call's participant list,
/// keyed by the member's DID.
///
/// Drives the bell -> ringing -> timeout affordance in the participant sheet
/// and sends the targeted call-invite to that member through the SDK. State is
/// held here (not in the sheet) so it survives the sheet closing and reopening
/// while a ring is still in flight.

final class CallParticipantsRingControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          CallParticipantsRingController,
          Map<String, CallRingState>,
          Map<String, CallRingState>,
          Map<String, CallRingState>,
          String
        > {
  const CallParticipantsRingControllerFamily._()
    : super(
        retry: null,
        name: r'callParticipantsRingControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Tracks the per-member re-ring state for a group call's participant list,
  /// keyed by the member's DID.
  ///
  /// Drives the bell -> ringing -> timeout affordance in the participant sheet
  /// and sends the targeted call-invite to that member through the SDK. State is
  /// held here (not in the sheet) so it survives the sheet closing and reopening
  /// while a ring is still in flight.

  CallParticipantsRingControllerProvider call(String contactId) =>
      CallParticipantsRingControllerProvider._(argument: contactId, from: this);

  @override
  String toString() => r'callParticipantsRingControllerProvider';
}

/// Tracks the per-member re-ring state for a group call's participant list,
/// keyed by the member's DID.
///
/// Drives the bell -> ringing -> timeout affordance in the participant sheet
/// and sends the targeted call-invite to that member through the SDK. State is
/// held here (not in the sheet) so it survives the sheet closing and reopening
/// while a ring is still in flight.

abstract class _$CallParticipantsRingController
    extends $Notifier<Map<String, CallRingState>> {
  late final _$args = ref.$arg as String;
  String get contactId => _$args;

  Map<String, CallRingState> build(String contactId);
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(_$args);
    final ref =
        this.ref
            as $Ref<Map<String, CallRingState>, Map<String, CallRingState>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                Map<String, CallRingState>,
                Map<String, CallRingState>
              >,
              Map<String, CallRingState>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
