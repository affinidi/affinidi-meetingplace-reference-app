// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contacts_repository_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(contactsRepository)
final contactsRepositoryProvider = ContactsRepositoryProvider._();

final class ContactsRepositoryProvider
    extends
        $FunctionalProvider<
          AsyncValue<ContactsRepository>,
          ContactsRepository,
          FutureOr<ContactsRepository>
        >
    with
        $FutureModifier<ContactsRepository>,
        $FutureProvider<ContactsRepository> {
  ContactsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'contactsRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$contactsRepositoryHash();

  @$internal
  @override
  $FutureProviderElement<ContactsRepository> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<ContactsRepository> create(Ref ref) {
    return contactsRepository(ref);
  }
}

String _$contactsRepositoryHash() =>
    r'a48ce3f44315ec6be628881f8fd10a9420d67723';
