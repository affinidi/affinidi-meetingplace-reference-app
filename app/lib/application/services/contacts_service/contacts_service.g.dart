// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contacts_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Service responsible for managing contacts derived from channels and offers.
///
/// This service provides functionality to:
/// - Create contacts from invitation accepted events and approved offers
/// - Update contacts when a channel is inaugurated
/// - Persist, fetch, add, update and delete contacts via a repository
/// - Maintain contact-specific state such as badge counts and card updates
///
/// The service listens to control plane events to automatically create/update
/// contacts and exposes streams for processing and contact-card updates.

@ProviderFor(ContactsService)
const contactsServiceProvider = ContactsServiceProvider._();

/// Service responsible for managing contacts derived from channels and offers.
///
/// This service provides functionality to:
/// - Create contacts from invitation accepted events and approved offers
/// - Update contacts when a channel is inaugurated
/// - Persist, fetch, add, update and delete contacts via a repository
/// - Maintain contact-specific state such as badge counts and card updates
///
/// The service listens to control plane events to automatically create/update
/// contacts and exposes streams for processing and contact-card updates.
final class ContactsServiceProvider
    extends $NotifierProvider<ContactsService, ContactsServiceState> {
  /// Service responsible for managing contacts derived from channels and offers.
  ///
  /// This service provides functionality to:
  /// - Create contacts from invitation accepted events and approved offers
  /// - Update contacts when a channel is inaugurated
  /// - Persist, fetch, add, update and delete contacts via a repository
  /// - Maintain contact-specific state such as badge counts and card updates
  ///
  /// The service listens to control plane events to automatically create/update
  /// contacts and exposes streams for processing and contact-card updates.
  const ContactsServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'contactsServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$contactsServiceHash();

  @$internal
  @override
  ContactsService create() => ContactsService();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ContactsServiceState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ContactsServiceState>(value),
    );
  }
}

String _$contactsServiceHash() => r'7176c040aea752b6191aea03e62a5a7d6fc6d1ea';

/// Service responsible for managing contacts derived from channels and offers.
///
/// This service provides functionality to:
/// - Create contacts from invitation accepted events and approved offers
/// - Update contacts when a channel is inaugurated
/// - Persist, fetch, add, update and delete contacts via a repository
/// - Maintain contact-specific state such as badge counts and card updates
///
/// The service listens to control plane events to automatically create/update
/// contacts and exposes streams for processing and contact-card updates.

abstract class _$ContactsService extends $Notifier<ContactsServiceState> {
  ContactsServiceState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<ContactsServiceState, ContactsServiceState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ContactsServiceState, ContactsServiceState>,
              ContactsServiceState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
