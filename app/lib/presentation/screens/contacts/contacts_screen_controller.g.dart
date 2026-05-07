// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contacts_screen_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ContactsScreenController)
final contactsScreenControllerProvider = ContactsScreenControllerProvider._();

final class ContactsScreenControllerProvider
    extends $NotifierProvider<ContactsScreenController, ContactsScreenState> {
  ContactsScreenControllerProvider._()
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
    r'0cc452ac351112a5db444a3d9f64857e5b3c43cd';

abstract class _$ContactsScreenController
    extends $Notifier<ContactsScreenState> {
  ContactsScreenState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<ContactsScreenState, ContactsScreenState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ContactsScreenState, ContactsScreenState>,
              ContactsScreenState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
