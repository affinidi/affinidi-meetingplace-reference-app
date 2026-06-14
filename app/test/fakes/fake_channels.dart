import 'package:meeting_place_core/meeting_place_core.dart';
import 'package:mpx_flutter_reference_app/infrastructure/extensions/contact_card_extensions.dart';

import 'fake_contacts.dart';

class FakeChannels {
  static Channel get individualChannel {
    final contact = FakeContacts.individualContact;
    return Channel(
      permanentChannelDid: contact.channelDid!,
      otherPartyPermanentChannelDid: contact.channelDid!,
      offerLink: contact.offerLink,
      contactCard: contact.card.toSdkContactCard(),
      otherPartyContactCard: contact.otherPartyCard?.toSdkContactCard(),
      otherPartyNotificationToken: 'fake-notification-token',
      seqNo: 0,
      type: ChannelType.individual,
      transport: ChannelTransport.matrix,
      publishOfferDid: 'did:key:individual-offer',
      mediatorDid: contact.mediatorDid,
      status: ChannelStatus.inaugurated,
      isConnectionInitiator: true,
    );
  }

  static Channel get groupChannel {
    final contact = FakeContacts.groupContact;
    return Channel(
      permanentChannelDid: contact.channelDid!,
      otherPartyPermanentChannelDid: contact.channelDid!,
      offerLink: contact.offerLink,
      contactCard: contact.card.toSdkContactCard(),
      otherPartyContactCard: contact.otherPartyCard?.toSdkContactCard(),
      otherPartyNotificationToken: 'fake-notification-token',
      seqNo: 3,
      type: ChannelType.group,
      transport: ChannelTransport.matrix,
      publishOfferDid: 'did:key:group-offer',
      mediatorDid: contact.mediatorDid,
      status: ChannelStatus.inaugurated,
      isConnectionInitiator: true,
    );
  }

  static Channel get oobChannel {
    final contact = FakeContacts.oobContact;
    return Channel(
      permanentChannelDid: contact.channelDid!,
      otherPartyPermanentChannelDid: contact.channelDid!,
      offerLink: contact.offerLink,
      contactCard: contact.card.toSdkContactCard(),
      otherPartyContactCard: contact.otherPartyCard?.toSdkContactCard(),
      otherPartyNotificationToken: null,
      seqNo: 0,
      type: ChannelType.oob,
      publishOfferDid: 'did:key:oob-offer',
      mediatorDid: contact.mediatorDid,
      status: ChannelStatus.inaugurated,
      isConnectionInitiator: true,
    );
  }

  static Channel get oobChannelDismissed {
    final contact = FakeContacts.oobContactDismissed;
    return Channel(
      permanentChannelDid: contact.channelDid!,
      otherPartyPermanentChannelDid: contact.channelDid!,
      offerLink: contact.offerLink,
      contactCard: contact.card.toSdkContactCard(),
      otherPartyContactCard: contact.otherPartyCard?.toSdkContactCard(),
      otherPartyNotificationToken: null,
      seqNo: 0,
      type: ChannelType.oob,
      publishOfferDid: 'did:key:oob-dismissed-offer',
      mediatorDid: contact.mediatorDid,
      status: ChannelStatus.inaugurated,
      isConnectionInitiator: true,
    );
  }

  static Map<String, Channel> get allChannels {
    return {
      FakeContacts.individualContact.channelDid!: individualChannel,
      FakeContacts.groupContact.channelDid!: groupChannel,
      FakeContacts.oobContact.channelDid!: oobChannel,
      FakeContacts.oobContactDismissed.channelDid!: oobChannelDismissed,
    };
  }
}
