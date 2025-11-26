import 'dart:convert';
import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meeting_place_core/meeting_place_core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../application/services/connections_service/connections_service.dart';
import '../../../../application/services/contacts_service/contacts_service.dart';
import '../../../../application/services/identities_service/identities_service.dart';
import '../../../../application/services/mediator_service/mediator_service.dart';
import '../../../../application/services/settings_service/settings_service.dart';
import '../../../../domain/models/contacts/contact.dart';
import '../../../../domain/models/contacts/contact_status.dart';
import '../../../../infrastructure/exceptions/app_exception.dart';
import '../../../../infrastructure/exceptions/app_exception_type.dart';
import '../../../../infrastructure/extensions/vcard_extensions.dart';
import '../../../../infrastructure/providers/app_logger_provider.dart';
import '../../../../infrastructure/providers/meeting_place_sdk_provider.dart';
import '../../../../navigation/navigator.dart';
import '../../../widgets/async_loaders/async_loading_controller.dart';
import '../../../widgets/images/default_profile_image.dart';
import '../../../widgets/images/group_image.dart';
import 'connection_details_screen_state.dart';

part 'connection_details_screen_controller.g.dart';

@riverpod
class ConnectionDetailsScreenController
    extends _$ConnectionDetailsScreenController {
  late final displayNameController = TextEditingController();
  static const _logKey = 'CONNX';
  late final _logger = ref.read(appLoggerProvider);
  late final approveOfferLoadingController =
      AsyncLoadingController.provider('approveOfferLoadingController');
  late final rejectOfferLoadingController =
      AsyncLoadingController.provider('rejectOfferLoadingController');

  @override
  ConnectionDetailsScreenState build(String contactId) {
    ref.listen(
      settingsServiceProvider.select((state) => state.isDebugMode),
      (prev, next) {
        Future.microtask(() {
          state = state.copyWith(isDebugMode: next);
        });
      },
      fireImmediately: true,
    );

    displayNameController.addListener(_updateDisplayName);

    ref.onDispose(() {
      displayNameController.removeListener(_updateDisplayName);
      displayNameController.dispose();
    });

    final settings = ref.read(settingsServiceProvider);

    return ConnectionDetailsScreenState(
      showQrIcon: settings.shouldShowMeetingPlaceQR,
    );
  }

  Future<void> initialize() async {
    final contact = ref.read(contactsServiceProvider).getContactById(contactId);
    if (contact == null) {
      throw AppException(
        'Unable to find contact',
        code: AppExceptionType.missingContact.name,
      );
    }

    final connection = ref
        .read(connectionsServiceProvider)
        .getConnectionByOfferLink(contact.offerLink);

    final mediatorService = ref.read(mediatorServiceProvider.notifier);

    final mediator = mediatorService.findNearestMediatorBefore(
        dateTime: contact.dateAdded, did: contact.mediatorDid);

    final channelDid = contact.channelDid;
    if (channelDid == null) {
      throw AppException('Contact has not been associated to any channels',
          code: AppExceptionType.missingChannel.name);
    }
    _logger.info(
      'ChannelID: $channelDid',
      name: _logKey,
    );

    final coreSdk = await ref.read(meetingPlaceSdkProvider.future);
    final channel =
        await coreSdk.getChannelByOtherPartyPermanentDid(channelDid);

    if (channel == null) {
      throw AppException('Contact has not been associated to any channels',
          code: AppExceptionType.missingChannel.name);
    }

    var group = (connection is GroupConnectionOffer)
        ? await coreSdk.getGroupById(connection.groupId)
        : null;

    final identity = ref
        .read(identitiesServiceProvider)
        .getIdentityById(channel.externalRef);

    displayNameController.text = _makeContactName(contact, group, connection);

    state = state.copyWith(
      contact: contact,
      connection: connection,
      channel: channel,
      group: group,
      mediatorName: mediator?.mediatorName ?? '',
      identity: identity,
    );
  }

  String _makeContactName(
      Contact contact, Group? group, ConnectionOffer? connection) {
    var contactName = '';
    if (contact.displayName?.isNotEmpty == true) {
      contactName = contact.displayName!;
    } else if (group != null && (connection?.offerName.isNotEmpty ?? false)) {
      contactName = connection!.offerName;
    } else {
      contactName = contact.vCard.fullName;
    }
    return contactName;
  }

  Future<void> _updateDisplayName() async {
    final currentContact = state.contact;
    if (currentContact == null) return;

    final newDisplayName = displayNameController.text;
    final updatedContact = currentContact.copyWith(
      displayName: newDisplayName.isEmpty ? null : newDisplayName,
    );

    await ref
        .read(contactsServiceProvider.notifier)
        .updateContact(updatedContact);

    state = state.copyWith(contact: updatedContact);
  }

  Future<void> approveContact() async {
    final currentContact = state.contact;
    if (currentContact == null) return;

    await ref.read(approveOfferLoadingController.notifier).start(() async {
      final otherPartyPermanentChannelDid = currentContact.channelDid;
      if (otherPartyPermanentChannelDid == null) {
        throw AppException(
          '''Unable to approve a contact without the other party permanent channel Did''',
          code: AppExceptionType.missingOtherPartyChannelDid.name,
        );
      }

      final initialDisplayName = currentContact.vCard.fullName;
      final newDisplayName = displayNameController.text;
      final displayNameChanged = newDisplayName != initialDisplayName;

      final updatedContact = currentContact.copyWith(
        status: ContactStatus.pendingInauguration,
        displayName: displayNameChanged ? newDisplayName : null,
      );

      await ref
          .read(connectionsServiceProvider.notifier)
          .approveConnectionOffer(
            otherPartyPermanentChannelDid: otherPartyPermanentChannelDid,
            offerLink: currentContact.offerLink,
          );

      await ref
          .read(contactsServiceProvider.notifier)
          .updateContact(updatedContact);

      state = state.copyWith(contact: updatedContact);

      await Future(() {
        ref.read(navigatorProvider).pop();
      });
    });
  }

  Future<void> rejectContact() async {
    await ref.read(rejectOfferLoadingController.notifier).start(() async {
      final currentContact = state.contact;
      if (currentContact != null) {
        await ref
            .read(contactsServiceProvider.notifier)
            .deleteContacts([currentContact]);
        await Future(() {
          ref.read(navigatorProvider).pop();
        });
      }
    });
  }

  void showDeletedMembers(bool val) {
    state = state.copyWith(showDeletedMembers: val);
  }

  void showMnemonic(bool val) {
    if (!state.canRevealMnemonic) {
      state = state.copyWith(showMnemonic: false);
      return;
    }

    state = state.copyWith(showMnemonic: val);
  }

  Future<Uint8List> getImageBytes({
    required bool hasOtherPartyPic,
    required String? otherPartyProfilePic,
  }) async {
    if (hasOtherPartyPic && otherPartyProfilePic != null) {
      return base64Decode(otherPartyProfilePic);
    }

    final assetImage = state.isGroupChat ? groupImage : defaultProfileImage;

    final bundle = assetImage.bundle ??
        DefaultAssetBundle.of(
          WidgetsBinding.instance.rootElement!,
        );

    final bytes = await bundle
        .load(assetImage.keyName)
        .then((data) => data.buffer.asUint8List());

    return bytes;
  }

  Future<void> toggleShowQrView() async {
    state = state.copyWith(showQrView: !state.showQrView);
  }
}

extension ConnectionDetailsScreenControllerProviderSelector
    on ConnectionDetailsScreenControllerProvider {
  ProviderListenable<VCard?> get otherPartyVCard =>
      select((state) => state.channel?.otherPartyVCard);

  ProviderListenable<String> get otherPartyDisplayName => select((state) {
        final displayName = state.contact?.displayName;
        if (displayName != null && displayName.isNotEmpty) {
          return displayName;
        }

        if (state.group != null) {
          return state.connection?.offerName ?? '';
        }

        return state.channel?.otherPartyVCard?.firstName ?? '';
      });

  ProviderListenable<VCard?> get groupAdminVCard => select((state) {
        final group = state.group;
        if (group == null) return null;
        final groupAdmin = group.members.firstWhereOrNull(
            (member) => member.membershipType == GroupMembershipType.admin);
        return groupAdmin?.vCard;
      });

  ProviderListenable<bool> get isGroupChat =>
      select((state) => state.isGroupChat);

  ProviderListenable<String?> get groupName =>
      select((state) => state.isGroupChat ? state.connection?.offerName : null);

  ProviderListenable<bool> get canApprove => select((state) {
        if (state.contact == null) return false;

        final ownedByMe = state.connection?.ownedByMe ?? false;
        if (!ownedByMe) return false;

        final connectionStatus = state.connection?.status;
        if (![ConnectionOfferStatus.published, ConnectionOfferStatus.deleted]
            .contains(connectionStatus)) {
          return false;
        }

        final channelStatus = state.channel?.status;
        if (channelStatus == ChannelStatus.inaugurated) return false;

        return true;
      });

  ProviderListenable<List<GroupMember>> get members => select((state) =>
      state.group?.members
          .where((member) =>
              state.showDeletedMembers ||
              member.status != GroupMemberStatus.deleted)
          .toList() ??
      []);

  ProviderListenable<bool> get hasMembersAvailableToChat => select((state) =>
      (state.group?.members
              .where((member) => member.status != GroupMemberStatus.deleted)
              .length ??
          0) >
      1);

  ProviderListenable<bool> get isLoneMember =>
      select((state) => state.group?.members.length == 1);

  ProviderListenable<bool> get canRevealMnemonic =>
      select((state) => state.canRevealMnemonic);
}

extension _ConnectionDetailsScreenStateExtensions
    on ConnectionDetailsScreenState {
  bool get isGroupChat => contact?.isGroup ?? false;

  bool get canRevealMnemonic => connection?.ownedByMe ?? false;
}
