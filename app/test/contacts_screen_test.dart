import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meeting_place_core/meeting_place_core.dart';
import 'package:mpx_flutter_reference_app/domain/models/contacts/contact_status.dart';
import 'package:mpx_flutter_reference_app/infrastructure/extensions/contact_extensions.dart';

import 'fakes/fake_channels.dart';
import 'fakes/fake_contacts.dart';
import 'fakes/fake_identities.dart';
import 'fakes/fake_meeting_place_sdk.dart';
import 'utils/app.dart';

Future<void> navigateToContactsScreen(WidgetTester tester) async {
  await navigateToLocation(
    tester,
    '/contacts',
    isAuthenticated: true,
    alreadyOnboarded: true,
    identities: [FakeIdentities.primaryIdentity],
    contacts: [
      FakeContacts.individualContact,
      FakeContacts.groupContact,
      FakeContacts.pendingContact,
      FakeContacts.oobContact,
    ],
  );
  await tester.pumpAndSettle();
}

Finder findContactByName(String name) => find.text(name);
Finder findGridViewToggle() => find.byKey(const Key('toggle_grid_view_button'));
Finder findListViewToggle() => find.byKey(const Key('toggle_list_view_button'));
Finder findSearchIcon() => find.byKey(const Key('toggle_filter_button'));
Finder findNewConnectionButton() =>
    find.byKey(const Key('new_connection_button'));

void main() {
  group('When opening the contacts screen', () {
    testWidgets('should show the contacts screen with title', (tester) async {
      final l10n = await getL10n();
      await navigateToContactsScreen(tester);

      expect(find.text(l10n.tabsTitle('contacts')), findsWidgets);
    });

    testWidgets('should show the contacts panel subtitle', (tester) async {
      final l10n = await getL10n();
      await navigateToContactsScreen(tester);

      expect(find.text(l10n.contactsPanelSubtitle), findsOneWidget);
    });

    testWidgets('should show the new connection button', (tester) async {
      await navigateToContactsScreen(tester);

      expect(findNewConnectionButton(), findsOneWidget);
    });

    testWidgets('should show the grid/list view toggle buttons', (
      tester,
    ) async {
      await navigateToContactsScreen(tester);

      expect(findGridViewToggle(), findsOneWidget);
      expect(findListViewToggle(), findsOneWidget);
    });

    testWidgets('should show the search icon', (tester) async {
      await navigateToContactsScreen(tester);

      expect(findSearchIcon(), findsOneWidget);
    });
  });

  group('When displaying contacts in grid view', () {
    testWidgets('should show all contacts in a grid', (tester) async {
      await navigateToContactsScreen(tester);

      expect(find.byType(GridView), findsOneWidget);
    });

    testWidgets('should display individual contact in grid', (tester) async {
      await navigateToContactsScreen(tester);

      final contactName =
          FakeContacts.individualContact.displayName ?? 'Contact';
      expect(findContactByName(contactName), findsWidgets);
    });

    testWidgets('should display group contact in grid', (tester) async {
      await navigateToContactsScreen(tester);

      final groupContact = FakeContacts.groupContact;
      final card = groupContact.card;
      final groupName = [
        card.firstName,
        card.lastName ?? '',
      ].where((s) => s.isNotEmpty).join(' ');
      expect(findContactByName(groupName), findsWidgets);
    });

    testWidgets('should show badge count when greater than 0', (tester) async {
      await navigateToContactsScreen(tester);

      expect(find.text('3'), findsOneWidget);
    });
  });

  group('When displaying contacts in list view', () {
    testWidgets('should switch to list view when list toggle is tapped', (
      tester,
    ) async {
      await navigateToContactsScreen(tester);

      await tester.tap(findListViewToggle());
      await tester.pumpAndSettle();

      expect(find.byType(ListView), findsOneWidget);
    });

    testWidgets('should display all contacts in list', (tester) async {
      await navigateToContactsScreen(tester);

      await tester.tap(findListViewToggle());
      await tester.pumpAndSettle();

      final contactName1 =
          FakeContacts.individualContact.displayName ?? 'Contact';
      final contactName2 = FakeContacts.groupContact.displayName ?? 'Group';

      expect(findContactByName(contactName1), findsWidgets);
      expect(findContactByName(contactName2), findsWidgets);
    });

    testWidgets('should show badge count in list view', (tester) async {
      await navigateToContactsScreen(tester);

      await tester.tap(findListViewToggle());
      await tester.pumpAndSettle();

      expect(find.text('3'), findsOneWidget);
    });

    testWidgets('should show date added for contacts', (tester) async {
      await navigateToContactsScreen(tester);

      await tester.tap(findListViewToggle());
      await tester.pumpAndSettle();

      expect(find.textContaining('Jan'), findsWidgets);
    });
  });

  group('When toggling between grid and list views', () {
    testWidgets('should switch from grid to list view', (tester) async {
      await navigateToContactsScreen(tester);

      expect(find.byType(GridView), findsOneWidget);

      await tester.tap(findListViewToggle());
      await tester.pumpAndSettle();

      expect(find.byType(ListView), findsOneWidget);
      expect(find.byType(GridView), findsNothing);
    });

    testWidgets('should switch from list to grid view', (tester) async {
      await navigateToContactsScreen(tester);

      await tester.tap(findListViewToggle());
      await tester.pumpAndSettle();

      expect(find.byType(ListView), findsOneWidget);

      await tester.tap(findGridViewToggle());
      await tester.pumpAndSettle();

      expect(find.byType(GridView), findsOneWidget);
      expect(find.byType(ListView), findsNothing);
    });
  });

  group('When interacting with contacts', () {
    testWidgets('should show active contact as tappable', (tester) async {
      await navigateToContactsScreen(tester);

      final contactName =
          FakeContacts.individualContact.displayName ?? 'Contact';
      final contactWidget = findContactByName(contactName).first;

      expect(contactWidget, findsOneWidget);

      await tester.tap(contactWidget);
      await tester.pumpAndSettle();
    });

    testWidgets(
      'should navigate to connection details when tapping pending contact',
      (tester) async {
        await navigateToContactsScreen(tester);

        final contactName =
            FakeContacts.pendingContact.displayName ?? 'Pending';
        await tester.tap(findContactByName(contactName).first);
        await tester.pumpAndSettle();
      },
    );

    testWidgets('should show contact avatar when tapped', (tester) async {
      await navigateToContactsScreen(tester);

      final avatarFinder = find.byType(CircleAvatar);
      expect(avatarFinder, findsWidgets);
    });
  });

  group('When handling empty states', () {
    testWidgets('should show message when no contacts exist', (tester) async {
      final l10n = await getL10n();
      await navigateToLocation(
        tester,
        '/contacts',
        isAuthenticated: true,
        alreadyOnboarded: true,
        identities: [FakeIdentities.primaryIdentity],
        contacts: [],
      );
      await tester.pumpAndSettle();

      expect(find.text(l10n.noContactsYet), findsOneWidget);
    });

    testWidgets('should show different message when no contacts match filter', (
      tester,
    ) async {
      final l10n = await getL10n();
      await navigateToContactsScreen(tester);

      await tester.tap(findSearchIcon());
      await tester.pumpAndSettle();

      final searchField = find.byType(TextField);
      await tester.enterText(searchField, 'NonExistentContact');
      await tester.pumpAndSettle();

      expect(find.text(l10n.noContactsMatchFilter), findsOneWidget);
    });
  });

  group('When searching contacts', () {
    testWidgets('should open search field when search icon is tapped', (
      tester,
    ) async {
      await navigateToContactsScreen(tester);

      await tester.tap(findSearchIcon());
      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('should filter contacts by first name', (tester) async {
      await navigateToContactsScreen(tester);

      await tester.tap(findSearchIcon());
      await tester.pumpAndSettle();

      final searchField = find.byType(TextField);
      await tester.enterText(searchField, 'Alice');
      await tester.pumpAndSettle();

      final contactName =
          FakeContacts.individualContact.displayName ?? 'Contact';
      expect(findContactByName(contactName), findsWidgets);

      final groupName = FakeContacts.groupContact.displayName ?? 'Group';
      expect(findContactByName(groupName), findsNothing);
    });

    testWidgets('should filter contacts by last name', (tester) async {
      await navigateToContactsScreen(tester);

      await tester.tap(findSearchIcon());
      await tester.pumpAndSettle();

      final searchField = find.byType(TextField);
      await tester.enterText(searchField, 'Brown');
      await tester.pumpAndSettle();

      final pendingName = FakeContacts.pendingContact.displayName ?? 'Pending';
      expect(findContactByName(pendingName), findsWidgets);
    });

    testWidgets('should filter contacts case-insensitively', (tester) async {
      await navigateToContactsScreen(tester);

      await tester.tap(findSearchIcon());
      await tester.pumpAndSettle();

      final searchField = find.byType(TextField);
      await tester.enterText(searchField, 'alice');
      await tester.pumpAndSettle();

      final contactName =
          FakeContacts.individualContact.displayName ?? 'Contact';
      expect(findContactByName(contactName), findsWidgets);
    });

    testWidgets('should show all contacts when search is cleared', (
      tester,
    ) async {
      await navigateToContactsScreen(tester);

      await tester.tap(findSearchIcon());
      await tester.pumpAndSettle();

      final searchField = find.byType(TextField);
      await tester.enterText(searchField, 'Alice');
      await tester.pumpAndSettle();

      final clearButton = find.byIcon(Icons.clear);
      await tester.tap(clearButton);
      await tester.pumpAndSettle();

      final contactName1 =
          FakeContacts.individualContact.displayName ?? 'Contact';
      final groupContact = FakeContacts.groupContact;
      final card = groupContact.card;
      final groupName = [
        card.firstName,
        card.lastName ?? '',
      ].where((s) => s.isNotEmpty).join(' ');
      expect(findContactByName(contactName1), findsWidgets);
      expect(findContactByName(groupName), findsWidgets);
    });
  });

  group('When displaying contact badges', () {
    testWidgets('should show badge count when messages are unread', (
      tester,
    ) async {
      await navigateToContactsScreen(tester);

      expect(find.text('3'), findsOneWidget);
    });

    testWidgets('should not show badge when count is 0', (tester) async {
      await navigateToContactsScreen(tester);

      final contactWithNoBadge = FakeContacts.individualContact;
      expect(contactWithNoBadge.badgeCount, equals(0));
    });

    testWidgets('should show badge count of 1 when contact is first created', (
      tester,
    ) async {
      await navigateToLocation(
        tester,
        '/contacts',
        isAuthenticated: true,
        alreadyOnboarded: true,
        identities: [FakeIdentities.primaryIdentity],
        contacts: [FakeContacts.newContactWithMessage],
      );
      await tester.pumpAndSettle();

      expect(find.text('1'), findsWidgets);
      expect(FakeContacts.newContactWithMessage.badgeCount, equals(1));
    });

    testWidgets('should reset badge count to 0 after clicking contact with new '
        'messages', (tester) async {
      await navigateToLocation(
        tester,
        '/contacts',
        isAuthenticated: true,
        alreadyOnboarded: true,
        identities: [FakeIdentities.primaryIdentity],
        contacts: [FakeContacts.newContactWithMessage],
      );
      await tester.pumpAndSettle();

      expect(find.text('1'), findsWidgets);

      final contactName =
          FakeContacts.newContactWithMessage.displayName ?? 'Contact';
      await tester.tap(findContactByName(contactName).first);
      await tester.pumpAndSettle();
    });

    testWidgets('should update badge count when new message is received', (
      tester,
    ) async {
      final fakeSdk = FakeMeetingPlaceSDK(
        channels: {
          FakeChannels.individualChannel.otherPartyPermanentChannelDid!:
              FakeChannels.individualChannel,
        },
      );

      final contactWithMessages = FakeContacts.individualContact;

      await navigateToLocation(
        tester,
        '/contacts',
        isAuthenticated: true,
        alreadyOnboarded: true,
        identities: [FakeIdentities.primaryIdentity],
        contacts: [contactWithMessages],
        meetingPlaceCoreSDK: fakeSdk,
      );
      await tester.pumpAndSettle();

      expect(find.text('0'), findsNothing);

      final updatedChannel = Channel(
        permanentChannelDid: FakeChannels.individualChannel.permanentChannelDid,
        otherPartyPermanentChannelDid:
            FakeChannels.individualChannel.otherPartyPermanentChannelDid,
        offerLink: FakeChannels.individualChannel.offerLink,
        contactCard: FakeChannels.individualChannel.contactCard,
        otherPartyContactCard:
            FakeChannels.individualChannel.otherPartyContactCard,
        otherPartyNotificationToken:
            FakeChannels.individualChannel.otherPartyNotificationToken,
        seqNo: 3,
        type: FakeChannels.individualChannel.type,
        publishOfferDid: FakeChannels.individualChannel.publishOfferDid,
        mediatorDid: FakeChannels.individualChannel.mediatorDid,
        status: ChannelStatus.inaugurated,
        isConnectionInitiator: true,
      );

      fakeSdk.simulateChannelActivity(updatedChannel);
      await tester.pumpAndSettle();

      expect(find.text('3'), findsWidgets);
    });

    testWidgets(
      'should show OOB notification off icon for direct interactive contacts',
      (tester) async {
        await navigateToContactsScreen(tester);
        expect(find.byIcon(Icons.notifications_off_outlined), findsOneWidget);
      },
    );

    testWidgets('should show new channel dot badge for unopened channels', (
      tester,
    ) async {
      await navigateToContactsScreen(tester);

      final pendingContact = FakeContacts.pendingContact;
      expect(pendingContact.hasBeenOpened, isFalse);
    });
  });

  group('When handling swipe to delete in list view', () {
    testWidgets('should show delete option when swiping contact', (
      tester,
    ) async {
      await navigateToContactsScreen(tester);

      await tester.tap(findListViewToggle());
      await tester.pumpAndSettle();

      final dismissible = find.byType(Dismissible).first;
      await tester.drag(dismissible, const Offset(-500, 0));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('dismissible_delete_background')),
        findsOneWidget,
      );
      expect(find.byKey(const Key('dismissible_delete_text')), findsOneWidget);
    });

    testWidgets(
      'should show localized error snackbar when leaveChannel fails',
      (tester) async {
        final l10n = await getL10n();
        final fakeSdk = FakeMeetingPlaceSDK(
          shouldFailToLeaveChannel: true,
          channels: FakeChannels.allChannels,
        );

        await navigateToLocation(
          tester,
          '/contacts',
          isAuthenticated: true,
          alreadyOnboarded: true,
          identities: [FakeIdentities.primaryIdentity],
          contacts: [FakeContacts.individualContact],
          meetingPlaceCoreSDK: fakeSdk,
        );
        await tester.pumpAndSettle();

        // Switch to list view
        await tester.tap(findListViewToggle());
        await tester.pumpAndSettle();

        // Long press the contact to show delete dialog
        final contactName =
            FakeContacts.individualContact.displayName ?? 'Contact';
        await tester.longPress(findContactByName(contactName).first);
        await tester.pumpAndSettle();

        // Verify dialog appeared
        expect(find.text(l10n.contactDeleteHeading), findsOneWidget);

        // Confirm deletion
        final deleteButton = find.text(l10n.generalDelete).last;
        await tester.tap(deleteButton);
        await tester.pump();
        await tester.pump(const Duration(seconds: 1));

        expect(find.text(l10n.error('deleteContactFailed')), findsOneWidget);
      },
    );
  });

  group('When handling contact status', () {
    testWidgets('should show active status for active contacts', (
      tester,
    ) async {
      await navigateToContactsScreen(tester);

      final activeContact = FakeContacts.individualContact;
      expect(activeContact.status, equals(ContactStatus.active));
    });

    testWidgets('should show pending status for pending contacts', (
      tester,
    ) async {
      await navigateToContactsScreen(tester);

      final pendingContact = FakeContacts.pendingContact;
      expect(pendingContact.status, equals(ContactStatus.pendingApproval));
    });
  });

  group('When displaying contact borders', () {
    testWidgets(
      'should display appropriate border color in list view for pending '
      'contact',
      (tester) async {
        await navigateToContactsScreen(tester);

        final listViewToggle = findListViewToggle();
        if (listViewToggle.evaluate().isNotEmpty) {
          await tester.tap(listViewToggle);
          await tester.pumpAndSettle();
        }

        final pendingContactTile = find.ancestor(
          of: find.text('Display Charlie'),
          matching: find.byType(ListTile),
        );
        expect(pendingContactTile, findsOneWidget);

        final listTile = tester.widget<ListTile>(pendingContactTile);
        final shape = listTile.shape as RoundedRectangleBorder;

        final context = tester.element(pendingContactTile);
        final expectedColor = FakeContacts.pendingContact.getStatusColor(
          context,
          asAvatar: true,
        );

        expect(shape.side.color, expectedColor);
        expect(shape.side.width, 2);
      },
    );

    testWidgets(
      'should display transparent border in list view for active contact '
      'that has been opened',
      (tester) async {
        await navigateToContactsScreen(tester);

        final listViewToggle = findListViewToggle();
        if (listViewToggle.evaluate().isNotEmpty) {
          await tester.tap(listViewToggle);
          await tester.pumpAndSettle();
        }

        final activeContactTile = find.ancestor(
          of: find.text('Display Alice'),
          matching: find.byType(ListTile),
        );
        expect(activeContactTile, findsOneWidget);

        final listTile = tester.widget<ListTile>(activeContactTile);
        final shape = listTile.shape as RoundedRectangleBorder;

        expect(shape.side.color, Colors.transparent);
      },
    );

    testWidgets(
      'should display appropriate border color in grid view for pending '
      'contact',
      (tester) async {
        await navigateToContactsScreen(tester);

        final gridViewToggle = findGridViewToggle();
        if (gridViewToggle.evaluate().isNotEmpty) {
          await tester.tap(gridViewToggle);
          await tester.pumpAndSettle();
        }

        final allContainers = find.byType(Container);
        final containers = tester.widgetList<Container>(allContainers);

        final borderedContainers = containers.where((container) {
          final decoration = container.decoration;
          return decoration is BoxDecoration &&
              decoration.border != null &&
              decoration.shape == BoxShape.circle;
        }).toList();

        expect(borderedContainers.isNotEmpty, isTrue);

        final pendingIndex = borderedContainers.indexWhere((container) {
          final decoration = container.decoration as BoxDecoration;
          final border = decoration.border as Border;
          final element = find.byWidget(container).evaluate().first;
          final color = FakeContacts.pendingContact.getStatusColor(
            element,
            asAvatar: true,
          );
          return border.top.color == color && border.top.width == 2;
        });

        expect(pendingIndex, greaterThanOrEqualTo(0));
      },
    );

    testWidgets(
      'should display transparent border in grid view for active contact '
      'that has been opened',
      (tester) async {
        await navigateToContactsScreen(tester);

        final gridViewToggle = findGridViewToggle();
        if (gridViewToggle.evaluate().isNotEmpty) {
          await tester.tap(gridViewToggle);
          await tester.pumpAndSettle();
        }

        final allContainers = find.byType(Container);
        final containers = tester.widgetList<Container>(allContainers);

        final borderedContainers = containers.where((container) {
          final decoration = container.decoration;
          return decoration is BoxDecoration &&
              decoration.border != null &&
              decoration.shape == BoxShape.circle;
        }).toList();

        expect(borderedContainers.isNotEmpty, isTrue);

        final transparentIndex = borderedContainers.indexWhere((container) {
          final decoration = container.decoration as BoxDecoration;
          final border = decoration.border as Border;
          return border.top.color == Colors.transparent;
        });

        expect(transparentIndex, greaterThanOrEqualTo(0));
      },
    );
  });

  group('When displaying contact types', () {
    testWidgets('should display individual contacts correctly', (tester) async {
      await navigateToContactsScreen(tester);

      final individualContact = FakeContacts.individualContact;
      final contactName = individualContact.displayName ?? 'Contact';

      expect(findContactByName(contactName), findsWidgets);
      expect(individualContact.isIndividual, isTrue);
    });

    testWidgets('should display group contacts correctly', (tester) async {
      await navigateToContactsScreen(tester);

      final groupContact = FakeContacts.groupContact;
      final card = groupContact.card;
      final groupName = [
        card.firstName,
        card.lastName ?? '',
      ].where((s) => s.isNotEmpty).join(' ');

      expect(findContactByName(groupName), findsWidgets);
      expect(groupContact.isGroup, isTrue);
    });
  });
}
