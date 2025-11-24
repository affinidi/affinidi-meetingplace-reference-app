import 'package:meeting_place_core/meeting_place_core.dart';

import 'fake_contacts.dart';

class FakeChannels {
  static Channel get individualChannel {
    final contact = FakeContacts.individualContact;
    return Channel(
      permanentChannelDid: contact.channelDid!,
      otherPartyPermanentChannelDid: contact.channelDid!,
      offerLink: contact.offerLink,
      vCard: contact.vCard,
      otherPartyVCard: contact.otherPartyVCard,
      otherPartyNotificationToken: 'fake-notification-token',
      seqNo: 0,
      type: ChannelType.individual,
      publishOfferDid: 'did:key:individual-offer',
      mediatorDid: contact.mediatorDid,
      status: ChannelStatus.inaugurated,
    );
  }

  static Channel get groupChannel {
    final contact = FakeContacts.groupContact;
    return Channel(
      permanentChannelDid: contact.channelDid!,
      otherPartyPermanentChannelDid: contact.channelDid!,
      offerLink: contact.offerLink,
      vCard: contact.vCard,
      otherPartyVCard: contact.otherPartyVCard,
      otherPartyNotificationToken: 'fake-notification-token',
      seqNo: 3,
      type: ChannelType.group,
      publishOfferDid: 'did:key:group-offer',
      mediatorDid: contact.mediatorDid,
      status: ChannelStatus.inaugurated,
    );
  }

  static Map<String, Channel> get allChannels {
    return {
      FakeContacts.individualContact.channelDid!: individualChannel,
      FakeContacts.groupContact.channelDid!: groupChannel,
    };
  }
}
