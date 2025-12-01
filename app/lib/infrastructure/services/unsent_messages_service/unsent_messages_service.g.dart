// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'unsent_messages_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$unsentMessagesServiceHash() =>
    r'fcc3417eecfe942f742663070d860d82534bac67';

/// In-memory service for managing unsent messages per contact.
///
/// This service provides a lightweight, memory-only cache for draft messages
/// that users have typed but not sent.
///
/// Copied from [UnsentMessagesService].
@ProviderFor(UnsentMessagesService)
final unsentMessagesServiceProvider = AutoDisposeNotifierProvider<
    UnsentMessagesService, UnsentMessagesServiceState>.internal(
  UnsentMessagesService.new,
  name: r'unsentMessagesServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$unsentMessagesServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$UnsentMessagesService
    = AutoDisposeNotifier<UnsentMessagesServiceState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
