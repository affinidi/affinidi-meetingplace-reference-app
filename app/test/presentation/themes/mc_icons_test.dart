import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mpx_flutter_reference_app/presentation/themes/tokens/mc_icons.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('bundles the Phosphor line font', () async {
    final manifest =
        jsonDecode(await rootBundle.loadString('FontManifest.json')) as List;
    final family = manifest.cast<Map<String, dynamic>>().singleWhere(
      (entry) => entry['family'] == McIcons.fontFamily,
    );
    final asset = ((family['fonts'] as List).single as Map)['asset'] as String;

    expect((await rootBundle.load(asset)).lengthInBytes, greaterThan(0));
  });

  test('draws every icon from Phosphor in its line weight', () {
    const icons = [
      McIcons.contacts,
      McIcons.communities,
      McIcons.connections,
      McIcons.identities,
      McIcons.rCards,
      McIcons.credentials,
      McIcons.settings,
      McIcons.callLog,
      McIcons.mockCredentials,
      McIcons.add,
      McIcons.back,
      McIcons.close,
      McIcons.copy,
      McIcons.delete,
      McIcons.edit,
      McIcons.filter,
      McIcons.findOffer,
      McIcons.menu,
      McIcons.search,
      McIcons.publishOffer,
      McIcons.person,
      McIcons.badge,
      McIcons.email,
      McIcons.phone,
    ];

    for (final icon in icons) {
      expect(icon.fontFamily, McIcons.fontFamily);
    }
  });
}
