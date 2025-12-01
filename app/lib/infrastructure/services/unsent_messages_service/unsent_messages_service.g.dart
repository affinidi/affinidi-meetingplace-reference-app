// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'unsent_messages_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$unsentMessagesServiceHash() =>
    r'fc6187b96a65ea4bb21bbb52dcf403559354f0d1';

/// Service for managing unsent messages per contact.
///
/// This service persists draft messages to SharedPreferences, allowing them
/// to survive app restarts while keeping them separate from the main database.
///
/// Copied from [UnsentMessagesService].
@ProviderFor(UnsentMessagesService)
final unsentMessagesServiceProvider = NotifierProvider<UnsentMessagesService,
    UnsentMessagesServiceState>.internal(
  UnsentMessagesService.new,
  name: r'unsentMessagesServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$unsentMessagesServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$UnsentMessagesService = Notifier<UnsentMessagesServiceState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
