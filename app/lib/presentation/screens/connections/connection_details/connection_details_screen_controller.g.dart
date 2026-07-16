// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'connection_details_screen_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ConnectionDetailsScreenController)
const connectionDetailsScreenControllerProvider =
    ConnectionDetailsScreenControllerFamily._();

final class ConnectionDetailsScreenControllerProvider
    extends
        $NotifierProvider<
          ConnectionDetailsScreenController,
          ConnectionDetailsScreenState
        > {
  const ConnectionDetailsScreenControllerProvider._({
    required ConnectionDetailsScreenControllerFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'connectionDetailsScreenControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() =>
      _$connectionDetailsScreenControllerHash();

  @override
  String toString() {
    return r'connectionDetailsScreenControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  ConnectionDetailsScreenController create() =>
      ConnectionDetailsScreenController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ConnectionDetailsScreenState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ConnectionDetailsScreenState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ConnectionDetailsScreenControllerProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$connectionDetailsScreenControllerHash() =>
    r'1f9c1d5e32674695110db20135db64b3ac4671db';

final class ConnectionDetailsScreenControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          ConnectionDetailsScreenController,
          ConnectionDetailsScreenState,
          ConnectionDetailsScreenState,
          ConnectionDetailsScreenState,
          String
        > {
  const ConnectionDetailsScreenControllerFamily._()
    : super(
        retry: null,
        name: r'connectionDetailsScreenControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ConnectionDetailsScreenControllerProvider call(String contactId) =>
      ConnectionDetailsScreenControllerProvider._(
        argument: contactId,
        from: this,
      );

  @override
  String toString() => r'connectionDetailsScreenControllerProvider';
}

abstract class _$ConnectionDetailsScreenController
    extends $Notifier<ConnectionDetailsScreenState> {
  late final _$args = ref.$arg as String;
  String get contactId => _$args;

  ConnectionDetailsScreenState build(String contactId);
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(_$args);
    final ref =
        this.ref
            as $Ref<ConnectionDetailsScreenState, ConnectionDetailsScreenState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                ConnectionDetailsScreenState,
                ConnectionDetailsScreenState
              >,
              ConnectionDetailsScreenState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
