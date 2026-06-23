// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contacts_identities_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(contactsIdentitiesService)
const contactsIdentitiesServiceProvider = ContactsIdentitiesServiceProvider._();

final class ContactsIdentitiesServiceProvider
    extends
        $FunctionalProvider<
          ContactsIdentitiesService,
          ContactsIdentitiesService,
          ContactsIdentitiesService
        >
    with $Provider<ContactsIdentitiesService> {
  const ContactsIdentitiesServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'contactsIdentitiesServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$contactsIdentitiesServiceHash();

  @$internal
  @override
  $ProviderElement<ContactsIdentitiesService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ContactsIdentitiesService create(Ref ref) {
    return contactsIdentitiesService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ContactsIdentitiesService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ContactsIdentitiesService>(value),
    );
  }
}

String _$contactsIdentitiesServiceHash() =>
    r'1a3a24f190ed6b155e788b464099b455be065f08';
