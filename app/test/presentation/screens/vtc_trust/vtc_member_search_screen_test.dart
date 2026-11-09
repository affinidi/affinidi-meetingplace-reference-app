import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:meeting_place_vtc/meeting_place_vtc.dart';
import 'package:mpx_flutter_reference_app/application/services/vtc_trust_service/vtc_trust_service.dart';
import 'package:mpx_flutter_reference_app/l10n/app_localizations.dart';
import 'package:mpx_flutter_reference_app/presentation/screens/vtc_trust/vtc_member_search_screen.dart';
import 'package:mpx_flutter_reference_app/presentation/themes/app_theme.dart';

/// A directory that answers every search with [found].
class _FakeTrustService extends Fake implements VtcTrustService {
  /// Pictures by the digest a member's entry names.
  Map<String, Uint8List> memberPictures = {};

  @override
  Future<Uint8List?> memberPicture(
    String communityDid, {
    required DirectoryEntry entry,
  }) async => memberPictures[entry.avatarSha256];
  List<DirectoryEntry> found = const [];
  final List<String> queries = [];

  @override
  Future<List<DirectoryEntry>> findMembers(
    String communityDid, {
    required String query,
  }) async {
    queries.add(query);
    return found;
  }
}

void main() {
  late _FakeTrustService service;

  setUp(() => service = _FakeTrustService());

  Future<void> pumpScreen(WidgetTester tester, String contactName) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [vtcTrustServiceProvider.overrideWithValue(service)],
        child: MaterialApp(
          theme: AppTheme.dark,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: VtcMemberSearchScreen(
            communityDid: 'did:webvh:QmClub:vtc.example',
            communityName: 'Football club',
            contactName: contactName,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('asks for a longer search before asking the community', (
    tester,
  ) async {
    await pumpScreen(tester, 'Bo');

    expect(find.text('Enter at least three letters.'), findsOneWidget);
    expect(service.queries, isEmpty);
  });

  testWidgets('says when nobody matches, and searches again', (tester) async {
    await pumpScreen(tester, 'Bob');
    expect(find.text('No members match.'), findsOneWidget);

    await tester.enterText(
      find.byKey(const Key('vtc_member_search_field')),
      'Robert',
    );
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle();

    expect(service.queries, ['Bob', 'Robert']);
  });
}
