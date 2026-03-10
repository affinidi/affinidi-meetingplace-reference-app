// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contacts_connections_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$contactsConnectionsServiceHash() =>
    r'11bdd3951e0935c3e2a219cf666de00006e63f11';

/// Provider that exposes a single ContactsConnectionsService instance.
///
/// The provider is kept alive for the app lifetime and constructs the service
/// which registers cross-service listeners to keep contact cards and
/// connections in sync.
///
/// [ref] - Riverpod Ref passed by the provider system.
///
/// Returns:
/// - `ContactsConnectionsService` instance with listeners registered.
///
/// Copied from [contactsConnectionsService].
@ProviderFor(contactsConnectionsService)
final contactsConnectionsServiceProvider =
    Provider<ContactsConnectionsService>.internal(
      contactsConnectionsService,
      name: r'contactsConnectionsServiceProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$contactsConnectionsServiceHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ContactsConnectionsServiceRef = ProviderRef<ContactsConnectionsService>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
