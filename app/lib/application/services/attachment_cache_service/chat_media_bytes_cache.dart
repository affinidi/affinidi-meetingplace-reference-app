import 'dart:collection';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'chat_media_bytes_cache.g.dart';

/// Total decrypted bytes the warm cache may hold across all chats before it
/// starts evicting the least-recently-written entries.
const _maxWarmCacheBytes = 32 * 1024 * 1024;

/// A process-lifetime, byte-bounded LRU cache of decrypted chat media bytes.
///
/// `AttachmentCacheService` is scoped to an open chat and drops its in-memory
/// bytes when the screen closes, so re-entering a chat would otherwise re-fetch
/// and re-decrypt every image and show a spinner each time. This cache outlives
/// individual chat screens so a returning chat renders its already-decrypted
/// media immediately. It is intentionally capped so it cannot grow without
/// bound, and it holds nothing on disk.
class ChatMediaBytesCache {
  ChatMediaBytesCache({int maxBytes = _maxWarmCacheBytes})
    : _maxBytes = maxBytes;

  final int _maxBytes;
  int _currentBytes = 0;

  // Keyed by "contactId\u0000cacheKey". LinkedHashMap preserves insertion
  // order; re-inserting on write moves an entry to the most-recently-used end,
  // so eviction always removes the oldest entry first.
  final LinkedHashMap<String, _CacheEntry> _entries = LinkedHashMap();

  String _compositeKey(String contactId, String cacheKey) =>
      '$contactId\u0000$cacheKey';

  /// Stores [bytes] for [cacheKey] in [contactId]. Empty payloads (download
  /// failure markers) and payloads larger than the whole budget are ignored.
  void put(String contactId, String cacheKey, Uint8List bytes) {
    if (bytes.isEmpty || bytes.length > _maxBytes) return;

    final composite = _compositeKey(contactId, cacheKey);
    final existing = _entries.remove(composite);
    if (existing != null) _currentBytes -= existing.bytes.length;

    _entries[composite] = _CacheEntry(cacheKey: cacheKey, bytes: bytes);
    _currentBytes += bytes.length;

    while (_currentBytes > _maxBytes && _entries.isNotEmpty) {
      final oldest = _entries.keys.first;
      final removed = _entries.remove(oldest);
      if (removed != null) _currentBytes -= removed.bytes.length;
    }
  }

  /// Returns every retained entry for [contactId] as a `cacheKey -> bytes` map,
  /// used to seed a freshly opened chat's cache so it renders without spinners.
  Map<String, Uint8List> snapshotFor(String contactId) {
    final prefix = '$contactId\u0000';
    final snapshot = <String, Uint8List>{};
    for (final composite in _entries.keys) {
      if (!composite.startsWith(prefix)) continue;
      snapshot[_entries[composite]!.cacheKey] = _entries[composite]!.bytes;
    }
    return snapshot;
  }
}

class _CacheEntry {
  _CacheEntry({required this.cacheKey, required this.bytes});

  final String cacheKey;
  final Uint8List bytes;
}

/// Process-lifetime warm cache shared by every per-chat
/// `AttachmentCacheService` instance.
@Riverpod(keepAlive: true)
ChatMediaBytesCache chatMediaBytesCache(Ref ref) => ChatMediaBytesCache();
