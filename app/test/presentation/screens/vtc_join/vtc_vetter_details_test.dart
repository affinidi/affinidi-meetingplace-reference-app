import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meeting_place_vtc/meeting_place_vtc.dart';
import 'package:mpx_flutter_reference_app/l10n/app_localizations.dart';
import 'package:mpx_flutter_reference_app/presentation/screens/vtc_join/vtc_vetter_details.dart';

void main() {
  final l10n = lookupAppLocalizations(const Locale('en'));

  test('lists what the vetter published, then their DID', () {
    const vetter = ListedVetter(
      did: 'did:key:bob',
      methods: [VettingMethod.inPerson, VettingMethod.priorAcquaintance],
      displayName: 'Bob',
      languages: ['de', 'en'],
      place: 'Berlin, DE',
      acceptsDocumentation: ['passport', 'none'],
      availability: 'Weekday evenings',
      contactHint: 'At the club bar',
      events: ['Club day'],
    );

    expect(
      vtcVetterDetails(l10n, vetter.did, vetter),
      'How they vet: in person, people they already know\n'
      'Languages: de, en\n'
      'Where: Berlin, DE\n'
      'Documents: Passport, none, they know you\n'
      'Available: Weekday evenings\n'
      'Getting a ticket: At the club bar\n'
      'Events: Club day\n'
      'DID: did:key:bob',
    );
  });

  test('gives only the DID when the listing was not read', () {
    expect(vtcVetterDetails(l10n, 'did:key:bob', null), 'DID: did:key:bob');
  });
}
