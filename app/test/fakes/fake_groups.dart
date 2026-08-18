import 'package:meeting_place_core/meeting_place_core.dart' as sdk;
import 'fake_contacts.dart';

class FakeGroups {
  static const removableMemberDid = 'did:key:removable-member';
  static const removableMemberFirstName = 'Bob';
  static const removableMemberDisplayName = 'Bob Builder';
  static const multiWordMemberDid = 'did:key:multi-word-member';
  static const multiWordMemberFirstName = 'Earl Alice';
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
                'displayName': removableMemberDisplayName,
              },
            },
          ),
          publicKey: 'fake-public-key-2',
        ),
        sdk.GroupMember(
          did: multiWordMemberDid,
          dateAdded: DateTime.now(),
          status: sdk.GroupMemberStatus.approved,
          membershipType: sdk.GroupMembershipType.member,
          contactCard: sdk.ContactCard(
            did: multiWordMemberDid,
            type: FakeContacts.sdkContactCard.type,
            contactInfo: {
              'n': {
                'given': multiWordMemberFirstName,
                'surname': '',
                'displayName': '',
              },
            },
          ),
          publicKey: 'fake-public-key-4',
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
          publicKey: 'fake-public-key-3',
        ),
      ],
      created: DateTime.now(),
      publicKey: 'fake-public-key',
    );
  }
}
