// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'connections_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$connectionsServiceHash() =>
    r'0988c2ee99aa289e19d1001e2465214e5624ddfa';

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
///
/// Copied from [ConnectionsService].
@ProviderFor(ConnectionsService)
final connectionsServiceProvider =
    NotifierProvider<ConnectionsService, ConnectionsServiceState>.internal(
  ConnectionsService.new,
  name: r'connectionsServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$connectionsServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ConnectionsService = Notifier<ConnectionsServiceState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
