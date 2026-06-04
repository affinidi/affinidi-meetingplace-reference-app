import 'package:meeting_place_core/meeting_place_core.dart' as sdk;
import 'fake_contacts.dart';

class FakeGroups {
  static const removableMemberDid = 'did:key:removable-member';
  static const removableMemberFirstName = 'Bob';

  static sdk.Group approvedGroup() {
    return sdk.Group(
      id: 'group-id',
      did: 'group-did',
      offerLink: FakeContacts.groupContact.offerLink,
      members: [
        sdk.GroupMember(
          did: 'did:key:member',
          dateAdded: DateTime.now(),
          status: sdk.GroupMemberStatus.approved,
          membershipType: sdk.GroupMembershipType.member,
          contactCard: FakeContacts.sdkContactCard,
          publicKey: 'fake-public-key',
        ),
        sdk.GroupMember(
          did: removableMemberDid,
          dateAdded: DateTime.now(),
          status: sdk.GroupMemberStatus.approved,
          membershipType: sdk.GroupMembershipType.member,
          contactCard: sdk.ContactCard(
            did: removableMemberDid,
            type: FakeContacts.sdkContactCard.type,
            contactInfo: {
              'n': {
                'given': removableMemberFirstName,
                'surname': 'Builder',
                'displayName': 'Display Bob',
              },
            },
          ),
          publicKey: 'fake-public-key-2',
        ),
      ],
      created: DateTime.now(),
      publicKey: 'fake-public-key',
    );
  }
}
