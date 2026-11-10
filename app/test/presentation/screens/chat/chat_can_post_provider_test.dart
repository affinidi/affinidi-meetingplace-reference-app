import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meeting_place_core/meeting_place_core.dart';
import 'package:meeting_place_matrix/meeting_place_matrix.dart';
import 'package:mpx_flutter_reference_app/application/services/contacts_service/contacts_service.dart';
import 'package:mpx_flutter_reference_app/infrastructure/providers/app_logger_provider.dart';
import 'package:mpx_flutter_reference_app/infrastructure/providers/meeting_place_sdk_provider.dart';
import 'package:mpx_flutter_reference_app/presentation/screens/chat/chat_can_post_provider.dart';
import 'package:mpx_flutter_reference_app/presentation/screens/chat/chat_screen_controller.dart';
import 'package:mpx_flutter_reference_app/presentation/screens/chat/chat_screen_state.dart';

import '../../../fakes/fake_channels.dart';
import '../../../fakes/fake_contacts.dart';
import '../../../mocks/fake_app_logger.dart';
import '../../../mocks/fake_contacts_service.dart';

class _FakeSdk extends Fake implements MeetingPlaceMatrixSDK {
  bool canPost = true;
  bool isChatUnreachable = false;

  @override
  Future<Channel?> findChannelByOtherPartyPermanentDid(String did) async =>
      did == FakeContacts.groupContact.channelDid
      ? FakeChannels.groupChannel
      : null;

  @override
  Future<bool> canPostInGroup(Channel channel) async {
    if (isChatUnreachable) {
      throw MeetingPlaceCoreSDKException(
        message: 'chat unreachable',
        code: 'generic',
        innerException: StateError('chat unreachable'),
      );
    }
    return canPost;
  }
}

class _ChatController extends ChatScreenController {
  _ChatController({required this.isGroupChat});

  final bool isGroupChat;

  @override
  ChatScreenState build(String contactId) => ChatScreenState(
    group: isGroupChat
        ? Group(
            id: 'chat-1',
            did: 'did:test:group',
            offerLink: FakeContacts.groupContact.offerLink,
            created: DateTime.utc(2026, 11),
            members: const <GroupMember>[],
          )
        : null,
  );
}

void main() {
  final contactId = FakeContacts.groupContact.id;
  late _FakeSdk sdk;

  ProviderContainer containerFor({bool isGroupChat = true}) {
    final container = ProviderContainer(
      overrides: [
        appLoggerProvider.overrideWithValue(FakeAppLogger()),
        contactsServiceProvider.overrideWith(
          () => FakeContactsService(contacts: [FakeContacts.groupContact]),
        ),
        meetingPlaceSdkProvider.overrideWith((ref) async => sdk),
        chatScreenControllerProvider(
          contactId,
        ).overrideWith(() => _ChatController(isGroupChat: isGroupChat)),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  setUp(() => sdk = _FakeSdk());

  test('answers as the group chat says', () async {
    sdk.canPost = false;

    expect(
      await containerFor().read(chatCanPostProvider(contactId).future),
      isFalse,
    );
  });

  test('lets a member post in a chat that is no group chat', () async {
    sdk.canPost = false;

    expect(
      await containerFor(
        isGroupChat: false,
      ).read(chatCanPostProvider(contactId).future),
      isTrue,
    );
  });

  test('leaves posting to the chat itself while it cannot be read', () async {
    sdk.isChatUnreachable = true;

    expect(
      await containerFor().read(chatCanPostProvider(contactId).future),
      isTrue,
    );
  });
}
