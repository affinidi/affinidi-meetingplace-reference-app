// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'connections_screen_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ConnectionsScreenController)
final connectionsScreenControllerProvider =
    ConnectionsScreenControllerProvider._();

final class ConnectionsScreenControllerProvider
    extends
        $NotifierProvider<ConnectionsScreenController, ConnectionsScreenState> {
  ConnectionsScreenControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'connectionsScreenControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$connectionsScreenControllerHash();

  @$internal
  @override
  ConnectionsScreenController create() => ConnectionsScreenController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ConnectionsScreenState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ConnectionsScreenState>(value),
    );
  }
}

String _$connectionsScreenControllerHash() =>
    r'c8fd0a49c97669a8368862676d20821d245745d4';

abstract class _$ConnectionsScreenController
    extends $Notifier<ConnectionsScreenState> {
  ConnectionsScreenState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<ConnectionsScreenState, ConnectionsScreenState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ConnectionsScreenState, ConnectionsScreenState>,
              ConnectionsScreenState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
