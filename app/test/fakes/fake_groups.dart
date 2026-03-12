import 'package:meeting_place_core/meeting_place_core.dart' as sdk;
import 'fake_contacts.dart';

class FakeGroups {
  static sdk.Group approvedGroup() {
    return sdk.Group(
      id: 'group-id',
      did: 'group-did',
      offerLink: 'fake-offer-link',
      members: [
        sdk.GroupMember(
          did: 'did:key:member',
          dateAdded: DateTime.now(),
          status: sdk.GroupMemberStatus.approved,
          membershipType: sdk.GroupMembershipType.member,
          contactCard: FakeContacts.sdkContactCard,
          publicKey: 'fake-public-key',
        ),
      ],
      created: DateTime.now(),
      publicKey: 'fake-public-key',
    );
  }
}
