import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mpx_flutter_reference_app/application/services/attachment_cache_service/chat_media_bytes_cache.dart';

void main() {
  group('ChatMediaBytesCache', () {
    test('retains stored bytes per contact', () {
      final cache = ChatMediaBytesCache(maxBytes: 1024);
      cache.put('contact-a', 'key-1', Uint8List.fromList([1, 2, 3]));

      final snapshot = cache.snapshotFor('contact-a');
      expect(snapshot.keys, ['key-1']);
      expect(snapshot['key-1'], [1, 2, 3]);
    });

    test('keeps each contact isolated', () {
      final cache = ChatMediaBytesCache(maxBytes: 1024);
      cache.put('contact-a', 'shared-key', Uint8List.fromList([1]));
      cache.put('contact-b', 'shared-key', Uint8List.fromList([2]));

      expect(cache.snapshotFor('contact-a')['shared-key'], [1]);
      expect(cache.snapshotFor('contact-b')['shared-key'], [2]);
    });

    test('ignores empty payloads so failure markers are not retained', () {
      final cache = ChatMediaBytesCache(maxBytes: 1024);
      cache.put('contact-a', 'key-1', Uint8List(0));

      expect(cache.snapshotFor('contact-a'), isEmpty);
    });

    test('ignores a single payload larger than the whole budget', () {
      final cache = ChatMediaBytesCache(maxBytes: 4);
      cache.put('contact-a', 'key-1', Uint8List.fromList([1, 2, 3, 4, 5]));

      expect(cache.snapshotFor('contact-a'), isEmpty);
    });

    test('evicts the least-recently-written entry when over budget', () {
      final cache = ChatMediaBytesCache(maxBytes: 6);
      cache.put('contact-a', 'key-1', Uint8List.fromList([1, 2, 3]));
      cache.put('contact-a', 'key-2', Uint8List.fromList([4, 5, 6]));

      // Adding a third 3-byte entry (total 9 > 6) evicts the oldest (key-1).
      cache.put('contact-a', 'key-3', Uint8List.fromList([7, 8, 9]));

      final snapshot = cache.snapshotFor('contact-a');
      expect(snapshot.keys, unorderedEquals(['key-2', 'key-3']));
      expect(snapshot.containsKey('key-1'), isFalse);
    });

    test('re-writing a key refreshes its recency and updates its bytes', () {
      final cache = ChatMediaBytesCache(maxBytes: 6);
      cache.put('contact-a', 'key-1', Uint8List.fromList([1, 2, 3]));
      cache.put('contact-a', 'key-2', Uint8List.fromList([4, 5, 6]));

      // Re-writing key-1 moves it to the most-recent end, so the next overflow
      // evicts key-2 instead.
      cache.put('contact-a', 'key-1', Uint8List.fromList([9, 9, 9]));
      cache.put('contact-a', 'key-3', Uint8List.fromList([7, 8, 9]));

      final snapshot = cache.snapshotFor('contact-a');
      expect(snapshot.keys, unorderedEquals(['key-1', 'key-3']));
      expect(snapshot['key-1'], [9, 9, 9]);
    });
  });
}
