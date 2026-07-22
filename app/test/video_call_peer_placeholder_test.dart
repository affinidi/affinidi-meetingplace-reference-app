import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mpx_flutter_reference_app/application/services/contacts_service/contacts_service.dart';
import 'package:mpx_flutter_reference_app/application/services/identities_service/identities_service.dart';
import 'package:mpx_flutter_reference_app/application/services/identities_service/identities_service_state.dart';
import 'package:mpx_flutter_reference_app/domain/models/contacts/contact.dart';
import 'package:mpx_flutter_reference_app/infrastructure/providers/cache_manager_provider.dart';
import 'package:mpx_flutter_reference_app/presentation/themes/app_theme.dart';
import 'package:mpx_flutter_reference_app/presentation/widgets/call/video_call_peer_placeholder.dart';
import 'package:mpx_flutter_reference_app/presentation/widgets/profile_circle_avatar.dart';

import 'fakes/fake_cache_manager.dart';
import 'fakes/fake_contacts.dart';
import 'fakes/fake_contacts_service.dart';
import 'fakes/fake_identities.dart';
import 'fakes/fake_identities_service.dart';

/// 1x1 transparent PNG.
const _pngBase64 =
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk'
    'YPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==';

Widget _wrap({
  required String contactId,
  required List<Contact> contacts,
  bool showCurrentIdentity = false,
  IdentitiesServiceState? identitiesState,
}) {
  return ProviderScope(
    overrides: [
      contactsServiceProvider.overrideWith(
        () => FakeContactsService(contacts: contacts),
      ),
      identitiesServiceProvider.overrideWith(
        () =>
            FakeIdentitiesService(identitiesState ?? IdentitiesServiceState()),
      ),
      cacheManagerProvider.overrideWith((ref) => FakeCacheManager()),
    ],
    child: MaterialApp(
      theme: AppTheme.dark,
      home: Scaffold(
        body: VideoCallPeerPlaceholder(
          contactId: contactId,
          showCurrentIdentity: showCurrentIdentity,
        ),
      ),
    ),
  );
}

void main() {
  group('When peer has a profile picture', () {
    testWidgets('it shows the peer profile picture', (tester) async {
      final contact = FakeContacts.individualContact.copyWith(
        card: FakeContacts.individualContact.card.copyWith(
          profilePic: _pngBase64,
        ),
      );

      await tester.pumpWidget(
        _wrap(contactId: contact.id, contacts: [contact]),
      );
      await tester.pump();

      final avatar = tester.widget<ProfileCircleAvatar>(
        find.byType(ProfileCircleAvatar),
      );
      expect(avatar.image, isNotNull);
    });
  });

  group('When peer has no profile picture', () {
    testWidgets('it shows a person icon fallback', (tester) async {
      await tester.pumpWidget(
        _wrap(
          contactId: FakeContacts.individualContact.id,
          contacts: [FakeContacts.individualContact],
        ),
      );
      await tester.pump();

      final avatar = tester.widget<ProfileCircleAvatar>(
        find.byType(ProfileCircleAvatar),
      );
      expect(avatar.image, isNull);
      expect(find.byIcon(Icons.person), findsOneWidget);
    });

    testWidgets(
      'it prefers the current identity picture when asked to show self',
      (tester) async {
        final identity = FakeIdentities.primaryIdentity.copyWith(
          card: FakeIdentities.primaryIdentity.card.copyWith(
            profilePic: _pngBase64,
          ),
        );

        await tester.pumpWidget(
          _wrap(
            contactId: FakeContacts.groupContact.id,
            contacts: [FakeContacts.groupContact],
            showCurrentIdentity: true,
            identitiesState: IdentitiesServiceState(currentIdentity: identity),
          ),
        );
        await tester.pump();

        final avatar = tester.widget<ProfileCircleAvatar>(
          find.byType(ProfileCircleAvatar),
        );
        expect(avatar.image, isNotNull);
      },
    );
  });

  group('When the contact is unknown', () {
    testWidgets('it shows a person icon fallback', (tester) async {
      await tester.pumpWidget(
        _wrap(contactId: 'missing-contact', contacts: const []),
      );
      await tester.pump();

      final avatar = tester.widget<ProfileCircleAvatar>(
        find.byType(ProfileCircleAvatar),
      );
      expect(avatar.image, isNull);
      expect(find.byIcon(Icons.person), findsOneWidget);
    });
  });
}
