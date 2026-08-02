class PendingSignRequestStore {
  final _entries = <String, _PendingEntry>{};
  static const _expiry = Duration(minutes: 5);

  void store(String conversationId, Map<String, dynamic> signRequest) {
    _pruneExpired();
    _entries[conversationId] = _PendingEntry(signRequest, DateTime.now());
  }

  Map<String, dynamic>? retrieve(String conversationId) {
    final entry = _entries[conversationId];
    if (entry == null) return null;
    if (DateTime.now().difference(entry.storedAt) > _expiry) {
      _entries.remove(conversationId);
      return null;
    }
    return entry.data;
  }

  void remove(String conversationId) => _entries.remove(conversationId);

  void _pruneExpired() {
    final now = DateTime.now();
    _entries.removeWhere((_, e) => now.difference(e.storedAt) > _expiry);
  }
}

class _PendingEntry {
  _PendingEntry(this.data, this.storedAt);

  final Map<String, dynamic> data;
  final DateTime storedAt;
}
