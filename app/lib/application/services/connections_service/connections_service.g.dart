// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'connections_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

<<<<<<< HEAD
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Service responsible for managing connection offers and channels.
///
/// This service provides functionality to:
/// - Fetch current connection offers and channels
/// - Delete connection offers
/// - Approve and accept connection offers
/// - Publish new offers (including group offers)
/// - Validate and find offers by mnemonic/phrase
///
/// It interacts with the MeetingPlaceCoreSDK and exposes a stream for group
/// channel inauguration events.

@ProviderFor(ConnectionsService)
final connectionsServiceProvider = ConnectionsServiceProvider._();
=======
String _$connectionsServiceHash() =>
    r'0fe8b02bbcc0f44b0e051eab8f734ae277aed397';
>>>>>>> 5e6ffdbc (feat: add 1:1 chat transport selection gated by build-time env var (#127))

/// Service responsible for managing connection offers and channels.
///
/// This service provides functionality to:
/// - Fetch current connection offers and channels
/// - Delete connection offers
/// - Approve and accept connection offers
/// - Publish new offers (including group offers)
/// - Validate and find offers by mnemonic/phrase
///
/// It interacts with the MeetingPlaceCoreSDK and exposes a stream for group
/// channel inauguration events.
final class ConnectionsServiceProvider
    extends $NotifierProvider<ConnectionsService, ConnectionsServiceState> {
  /// Service responsible for managing connection offers and channels.
  ///
  /// This service provides functionality to:
  /// - Fetch current connection offers and channels
  /// - Delete connection offers
  /// - Approve and accept connection offers
  /// - Publish new offers (including group offers)
  /// - Validate and find offers by mnemonic/phrase
  ///
  /// It interacts with the MeetingPlaceCoreSDK and exposes a stream for group
  /// channel inauguration events.
  ConnectionsServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'connectionsServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$connectionsServiceHash();

  @$internal
  @override
  ConnectionsService create() => ConnectionsService();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ConnectionsServiceState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ConnectionsServiceState>(value),
    );
  }
}

String _$connectionsServiceHash() =>
    r'889b9b9fc149a6940b892bf30e55e703baf8741a';

/// Service responsible for managing connection offers and channels.
///
/// This service provides functionality to:
/// - Fetch current connection offers and channels
/// - Delete connection offers
/// - Approve and accept connection offers
/// - Publish new offers (including group offers)
/// - Validate and find offers by mnemonic/phrase
///
/// It interacts with the MeetingPlaceCoreSDK and exposes a stream for group
/// channel inauguration events.

abstract class _$ConnectionsService extends $Notifier<ConnectionsServiceState> {
  ConnectionsServiceState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<ConnectionsServiceState, ConnectionsServiceState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ConnectionsServiceState, ConnectionsServiceState>,
              ConnectionsServiceState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
