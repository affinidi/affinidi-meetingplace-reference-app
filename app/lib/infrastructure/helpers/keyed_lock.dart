import 'dart:async';

import 'package:synchronized/synchronized.dart';

/// Serializes asynchronous work per key.
///
/// Each key is backed by its own [Lock]; concurrent calls with the same key
/// run sequentially, while calls with different keys run independently.
/// Locks are retained for the lifetime of the registry — bound the key space
/// or scope the registry accordingly.
class KeyedLock<K> {
  final Map<K, Lock> _locks = {};

  Future<T> synchronized<T>(K key, FutureOr<T> Function() body) {
    return _locks.putIfAbsent(key, Lock.new).synchronized(body);
  }
}
