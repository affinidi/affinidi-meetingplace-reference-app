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
    r'78925798433e1cf3fc87a8ef3168c115aeaf75ac';

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

/// The offer links of the channels of [communityDid]: its groups' chats.

@ProviderFor(communityChannelOfferLinks)
const communityChannelOfferLinksProvider = CommunityChannelOfferLinksFamily._();

/// The offer links of the channels of [communityDid]: its groups' chats.

final class CommunityChannelOfferLinksProvider
    extends
        $FunctionalProvider<
          AsyncValue<Set<String>>,
          Set<String>,
          FutureOr<Set<String>>
        >
    with $FutureModifier<Set<String>>, $FutureProvider<Set<String>> {
  /// The offer links of the channels of [communityDid]: its groups' chats.
  const CommunityChannelOfferLinksProvider._({
    required CommunityChannelOfferLinksFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'communityChannelOfferLinksProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$communityChannelOfferLinksHash();

  @override
  String toString() {
    return r'communityChannelOfferLinksProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Set<String>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<Set<String>> create(Ref ref) {
    final argument = this.argument as String;
    return communityChannelOfferLinks(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is CommunityChannelOfferLinksProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$communityChannelOfferLinksHash() =>
    r'6ac48372fb38b98caa04338b9a019bf1ee74b4e0';

/// The offer links of the channels of [communityDid]: its groups' chats.

final class CommunityChannelOfferLinksFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Set<String>>, String> {
  const CommunityChannelOfferLinksFamily._()
    : super(
        retry: null,
        name: r'communityChannelOfferLinksProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The offer links of the channels of [communityDid]: its groups' chats.

  CommunityChannelOfferLinksProvider call(String communityDid) =>
      CommunityChannelOfferLinksProvider._(argument: communityDid, from: this);

  @override
  String toString() => r'communityChannelOfferLinksProvider';
}
