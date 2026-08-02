// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contacts_screen_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ContactsScreenController)
const contactsScreenControllerProvider = ContactsScreenControllerProvider._();

final class ContactsScreenControllerProvider
    extends $NotifierProvider<ContactsScreenController, ContactsScreenState> {
  const ContactsScreenControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'contactsScreenControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$contactsScreenControllerHash();

  @$internal
  @override
  ContactsScreenController create() => ContactsScreenController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ContactsScreenState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ContactsScreenState>(value),
    );
  }
}

String _$contactsScreenControllerHash() =>
    r'8b01210dbc327998f6fc57459bdd686c54a4834e';

abstract class _$ContactsScreenController
    extends $Notifier<ContactsScreenState> {
  ContactsScreenState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<ContactsScreenState, ContactsScreenState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ContactsScreenState, ContactsScreenState>,
              ContactsScreenState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
