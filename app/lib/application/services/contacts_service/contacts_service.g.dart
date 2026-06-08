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
final contactsServiceProvider = ContactsServiceProvider._();

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
  ContactsServiceProvider._()
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

String _$contactsServiceHash() => r'd4cd569fa4e3d5a8c5131e80b0a03309e4db52ab';

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
    final ref = this.ref as $Ref<ContactsServiceState, ContactsServiceState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ContactsServiceState, ContactsServiceState>,
              ContactsServiceState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
