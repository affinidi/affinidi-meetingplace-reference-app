// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contacts_connections_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
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

@ProviderFor(contactsConnectionsService)
final contactsConnectionsServiceProvider =
    ContactsConnectionsServiceProvider._();

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

final class ContactsConnectionsServiceProvider
    extends
        $FunctionalProvider<
          ContactsConnectionsService,
          ContactsConnectionsService,
          ContactsConnectionsService
        >
    with $Provider<ContactsConnectionsService> {
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
  ContactsConnectionsServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'contactsConnectionsServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$contactsConnectionsServiceHash();

  @$internal
  @override
  $ProviderElement<ContactsConnectionsService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ContactsConnectionsService create(Ref ref) {
    return contactsConnectionsService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ContactsConnectionsService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ContactsConnectionsService>(value),
    );
  }
}

String _$contactsConnectionsServiceHash() =>
    r'11bdd3951e0935c3e2a219cf666de00006e63f11';
