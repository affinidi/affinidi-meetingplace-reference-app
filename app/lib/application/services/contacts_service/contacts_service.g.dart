// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contacts_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$contactsServiceHash() => r'23fd47a3c57e6b258e9cc6c7699bda2a3d6faf74';

/// Service responsible for managing contacts derived from channels and offers.
///
/// This service provides functionality to:
/// - Create contacts from invitation accepted events and approved offers
/// - Update contacts when a channel is inaugurated
/// - Persist, fetch, add, update and delete contacts via a repository
/// - Maintain contact-specific state such as badge counts and vCard updates
///
/// The service listens to control plane events to automatically create/update
/// contacts and exposes streams for processing and contact-card updates.
///
/// Copied from [ContactsService].
@ProviderFor(ContactsService)
final contactsServiceProvider =
    NotifierProvider<ContactsService, ContactsServiceState>.internal(
  ContactsService.new,
  name: r'contactsServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$contactsServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ContactsService = Notifier<ContactsServiceState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
