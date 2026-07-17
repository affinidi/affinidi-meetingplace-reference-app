// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'group_audio_call_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Controller for group audio call state.

@ProviderFor(GroupAudioCallController)
const groupAudioCallControllerProvider = GroupAudioCallControllerFamily._();

/// Controller for group audio call state.
final class GroupAudioCallControllerProvider
    extends $NotifierProvider<GroupAudioCallController, GroupAudioCallState> {
  /// Controller for group audio call state.
  const GroupAudioCallControllerProvider._({
    required GroupAudioCallControllerFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'groupAudioCallControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$groupAudioCallControllerHash();

  @override
  String toString() {
    return r'groupAudioCallControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  GroupAudioCallController create() => GroupAudioCallController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GroupAudioCallState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GroupAudioCallState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is GroupAudioCallControllerProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$groupAudioCallControllerHash() =>
    r'29b53316f6818c54f0332e913d3ce780b363c534';

/// Controller for group audio call state.

final class GroupAudioCallControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          GroupAudioCallController,
          GroupAudioCallState,
          GroupAudioCallState,
          GroupAudioCallState,
          String
        > {
  const GroupAudioCallControllerFamily._()
    : super(
        retry: null,
        name: r'groupAudioCallControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Controller for group audio call state.

  GroupAudioCallControllerProvider call(String groupContactId) =>
      GroupAudioCallControllerProvider._(argument: groupContactId, from: this);

  @override
  String toString() => r'groupAudioCallControllerProvider';
}

/// Controller for group audio call state.

abstract class _$GroupAudioCallController
    extends $Notifier<GroupAudioCallState> {
  late final _$args = ref.$arg as String;
  String get groupContactId => _$args;

  GroupAudioCallState build(String groupContactId);
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(_$args);
    final ref = this.ref as $Ref<GroupAudioCallState, GroupAudioCallState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<GroupAudioCallState, GroupAudioCallState>,
              GroupAudioCallState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
