import 'package:meeting_place_core/meeting_place_core.dart' as sdk;
import 'fake_contacts.dart';

class FakeGroups {
  static const removableMemberDid = 'did:key:removable-member';
  static const removableMemberFirstName = 'Bob';
  static const adminMemberDid = 'did:key:admin-member';
  static const adminMemberFirstName = 'Carol';

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
        ),
        sdk.GroupMember(
          did: adminMemberDid,
          dateAdded: DateTime.now(),
          status: sdk.GroupMemberStatus.approved,
          membershipType: sdk.GroupMembershipType.admin,
          contactCard: sdk.ContactCard(
            did: adminMemberDid,
            type: FakeContacts.sdkContactCard.type,
            contactInfo: {
              'n': {
                'given': adminMemberFirstName,
                'surname': 'Owner',
                'displayName': 'Display Carol',
              },
            },
          ),
        ),
      ],
      created: DateTime.now(),
    );
  }
}
