import 'package:flutter_test/flutter_test.dart';
import 'package:mpx_flutter_reference_app/infrastructure/extensions/map_path_extensions.dart';

void main() {
  group('MapPathExtensions.getPathValue', () {
    test('returns value at a shallow path', () {
      final map = <String, dynamic>{'key': 'value'};
      expect(map.getPathValue(['key']), 'value');
    });

    test('returns value at a deeply nested path', () {
      final map = <String, dynamic>{
        'a': <String, dynamic>{
          'b': <String, dynamic>{'c': 'deep'},
        },
      };
      expect(map.getPathValue(['a', 'b', 'c']), 'deep');
    });

    test('returns defaultValue when path is empty', () {
      final map = <String, dynamic>{'key': 'value'};
      expect(map.getPathValue([]), '');
      expect(map.getPathValue([], defaultValue: 'fallback'), 'fallback');
    });

    test('returns defaultValue when a key is missing', () {
      final map = <String, dynamic>{'a': <String, dynamic>{}};
      expect(map.getPathValue(['a', 'missing']), '');
      expect(map.getPathValue(['missing']), '');
    });

    test('returns defaultValue when an intermediate node is not a map', () {
      final map = <String, dynamic>{'a': 'not-a-map'};
      expect(map.getPathValue(['a', 'b']), '');
    });

    test('returns defaultValue when the final value is not a String', () {
      final map = <String, dynamic>{'key': 42};
      expect(map.getPathValue(['key']), '');
    });

    test('returns defaultValue when the final value is a Map not a String', () {
      final map = <String, dynamic>{
        'a': <String, dynamic>{'nested': 'value'},
      };
      expect(map.getPathValue(['a']), '');
    });

    test('returns custom defaultValue', () {
      final map = <String, dynamic>{};
      expect(map.getPathValue(['missing'], defaultValue: 'default'), 'default');
    });
  });

  group('MapPathExtensions.setPathValue', () {
    test('sets value at a shallow path', () {
      final map = <String, dynamic>{};
      map.setPathValue(['key'], 'value');
      expect(map['key'], 'value');
    });

    test('sets value at a deeply nested path, creating intermediate maps', () {
      final map = <String, dynamic>{};
      map.setPathValue(['a', 'b', 'c'], 'deep');
      expect(((map['a'] as Map)['b'] as Map)['c'], 'deep');
    });

    test('overwrites an existing value at the final key', () {
      final map = <String, dynamic>{'key': 'old'};
      map.setPathValue(['key'], 'new');
      expect(map['key'], 'new');
    });

    test('traverses an existing intermediate map', () {
      final existing = <String, dynamic>{'c': 'old'};
      final map = <String, dynamic>{'a': existing};
      map.setPathValue(['a', 'c'], 'new');
      expect(existing['c'], 'new');
    });

    test('does nothing when path is empty', () {
      final map = <String, dynamic>{'key': 'value'};
      map.setPathValue([], 'ignored');
      expect(map, <String, dynamic>{'key': 'value'});
    });

    test('creates missing intermediates within a partially-existing path', () {
      final existing = <String, dynamic>{'x': 'existing'};
      final map = <String, dynamic>{'a': existing};
      map.setPathValue(['a', 'b', 'c'], 'value');
      expect((existing['b'] as Map)['c'], 'value');
      expect(existing['x'], 'existing');
    });

    test('throws StateError when an intermediate node is not a map', () {
      final map = <String, dynamic>{'a': 'not-a-map'};
      expect(
        () => map.setPathValue(['a', 'b'], 'value'),
        throwsA(
          isA<StateError>().having(
            (e) => e.message,
            'message',
            contains("expected a map at key 'a'"),
          ),
        ),
      );
    });
  });
}
