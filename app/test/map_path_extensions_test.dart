import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mpx_flutter_reference_app/infrastructure/exceptions/app_exception.dart';
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

    test('returns defaultValue when an intermediate node is a List', () {
      final map = <String, dynamic>{'a': <dynamic>[]};
      expect(map.getPathValue(['a', 'b']), '');
    });

    test('returns empty string when the leaf value is an empty string', () {
      // Distinct from missing key: explicitly stored empty string.
      final map = <String, dynamic>{'key': ''};
      expect(map.getPathValue(['key']), '');
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

    test('throws AppException when an intermediate node is not a map', () {
      final map = <String, dynamic>{'a': 'not-a-map'};
      expect(
        () => map.setPathValue(['a', 'b'], 'value'),
        throwsA(
          isA<AppException>().having(
            (e) => e.message,
            'message',
            contains("expected a map at key 'a'"),
          ),
        ),
      );
    });

    test('throws AppException when an intermediate node is a List', () {
      final map = <String, dynamic>{'a': <dynamic>[]};
      expect(
        () => map.setPathValue(['a', 'b'], 'value'),
        throwsA(isA<AppException>()),
      );
    });

    test('replaces a nested map at the final key with a plain string', () {
      final map = <String, dynamic>{
        'a': <String, dynamic>{'nested': 'value'},
      };
      // 'a' is currently a Map; overwriting it at the final key is allowed.
      map.setPathValue(['a'], 'flat');
      expect(map['a'], 'flat');
    });

    test(
      'throws AppException when a later write passes through a leaf written by'
      ' an earlier write',
      () {
        // Simulates a future field conflict: ['n'] is set as a leaf, then
        // ['n', 'given'] tries to traverse it as a map.
        final map = <String, dynamic>{};
        map.setPathValue(['n'], 'flat-value');
        expect(
          () => map.setPathValue(['n', 'given'], 'first'),
          throwsA(isA<AppException>()),
        );
      },
    );
  });

  group('round-trip: setPathValue then getPathValue', () {
    test('round-trips an empty string value', () {
      final map = <String, dynamic>{};
      map.setPathValue(['key'], '');
      expect(map.getPathValue(['key']), '');
    });

    test('survives a JSON encode/decode cycle', () {
      // Simulates the actual migration: build the map, jsonEncode it,
      // then jsonDecode and read back with getPathValue.
      final map = <String, dynamic>{};
      map.setPathValue(['n', 'given'], 'Alice');
      map.setPathValue(['n', 'surname'], 'Smith');
      map.setPathValue(['email', 'type', 'work'], 'alice@example.com');
      map.setPathValue(['tel', 'type', 'cell'], '+1234567890');
      map.setPathValue(['x-meetingplace-identity-card-color'], '#FF0000');

      final decoded = jsonDecode(jsonEncode(map)) as Map<String, dynamic>;

      expect(decoded.getPathValue(['n', 'given']), 'Alice');
      expect(decoded.getPathValue(['n', 'surname']), 'Smith');
      expect(
        decoded.getPathValue(['email', 'type', 'work']),
        'alice@example.com',
      );
      expect(decoded.getPathValue(['tel', 'type', 'cell']), '+1234567890');
      expect(
        decoded.getPathValue(['x-meetingplace-identity-card-color']),
        '#FF0000',
      );
    });

    test('round-trips a shallow value', () {
      final map = <String, dynamic>{};
      map.setPathValue(['key'], 'value');
      expect(map.getPathValue(['key']), 'value');
    });

    test('round-trips a deeply nested value', () {
      final map = <String, dynamic>{};
      map.setPathValue(['a', 'b', 'c'], 'deep');
      expect(map.getPathValue(['a', 'b', 'c']), 'deep');
    });

    test('round-trips multiple values that share a common prefix', () {
      final map = <String, dynamic>{};
      map.setPathValue(['n', 'given'], 'Alice');
      map.setPathValue(['n', 'surname'], 'Smith');
      expect(map.getPathValue(['n', 'given']), 'Alice');
      expect(map.getPathValue(['n', 'surname']), 'Smith');
    });

    test(
      'round-trips all four contact-card migration paths without conflict',
      () {
        final map = <String, dynamic>{};
        map.setPathValue(['n', 'given'], 'Alice');
        map.setPathValue(['n', 'surname'], 'Smith');
        map.setPathValue(['email', 'type', 'work'], 'alice@example.com');
        map.setPathValue(['tel', 'type', 'cell'], '+1234567890');
        map.setPathValue(['x-meetingplace-identity-card-color'], '#FF0000');

        expect(map.getPathValue(['n', 'given']), 'Alice');
        expect(map.getPathValue(['n', 'surname']), 'Smith');
        expect(
          map.getPathValue(['email', 'type', 'work']),
          'alice@example.com',
        );
        expect(map.getPathValue(['tel', 'type', 'cell']), '+1234567890');
        expect(
          map.getPathValue(['x-meetingplace-identity-card-color']),
          '#FF0000',
        );
      },
    );
  });
}
