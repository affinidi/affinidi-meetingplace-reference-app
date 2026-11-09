import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('bundles every Affinidi Sans weight, upright and italic', () async {
    final manifest =
        jsonDecode(await rootBundle.loadString('FontManifest.json')) as List;
    final family = manifest.cast<Map<String, dynamic>>().singleWhere(
      (entry) => entry['family'] == 'Affinidi Sans',
    );
    final assets = (family['fonts'] as List).cast<Map<String, dynamic>>();

    expect(assets, hasLength(12));
    for (final font in assets) {
      final data = await rootBundle.load(font['asset'] as String);
      expect(data.lengthInBytes, greaterThan(0));
    }
  });
}
