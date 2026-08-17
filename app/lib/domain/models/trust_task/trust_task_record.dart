/// Outcome of a trust task, derived from the VTA audit log `outcome` field.
enum TrustTaskStatus {
  /// The signing task completed successfully (`outcome == "success"`).
  signed,

  /// The task was rejected (`outcome` starts with `"denied"`), e.g. because a
  /// step-up approval was required and not (yet) satisfied.
  denied,

  /// The outcome could not be classified.
  unknown,
}

/// A single trust-task history entry, mapped from a VTA `/audit/logs` row.
///
/// The connector signs documents/messages via the VTA `vault/sign-trust-task`
/// trust task; every attempt (autonomous or step-up gated) is recorded in the
/// VTA audit log with `action == "vault.sign-trust-task"`. This model is the
/// app-facing projection of one such audit row.
class TrustTaskRecord {
  const TrustTaskRecord({
    required this.id,
    required this.timestamp,
    required this.status,
    required this.rawOutcome,
    this.entryId,
    this.resourceLabel,
    this.actor,
    this.contextId,
    this.detail,
    this.raw = const <String, dynamic>{},
  });

  /// Builds a record from a raw VTA audit-log entry map.
  factory TrustTaskRecord.fromAuditEntry(Map<String, dynamic> entry) {
    final rawOutcome = (entry['outcome'] as String?)?.trim() ?? '';
    final timestampSeconds = _asInt(entry['timestamp']) ?? 0;

    return TrustTaskRecord(
      id: entry['id'] as String? ?? '',
      timestamp: DateTime.fromMillisecondsSinceEpoch(
        timestampSeconds * 1000,
        isUtc: true,
      ).toLocal(),
      status: _statusFromOutcome(rawOutcome),
      rawOutcome: rawOutcome,
      entryId: entry['resource'] as String?,
      actor: entry['actor'] as String?,
      contextId: entry['context_id'] as String?,
      detail: entry['detail'] is String ? entry['detail'] as String : null,
      raw: Map<String, dynamic>.from(entry),
    );
  }

  /// Stable audit-row id (used as a list key and for de-duplication).
  final String id;

  /// When the task was recorded.
  final DateTime timestamp;

  /// Classified outcome.
  final TrustTaskStatus status;

  /// The raw `outcome` string from the audit row (e.g. `"success"`,
  /// `"denied:auth/step-up/required"`). Kept for display of the denial code.
  final String rawOutcome;

  /// The vault entry that was signed (`resource` in the audit row).
  final String? entryId;

  /// Human-readable label resolved from the vault after connect;
  /// null until resolved.
  final String? resourceLabel;

  /// The DID that performed the task (the connector's VTA signing identity).
  final String? actor;

  /// The VTA application context id the task ran under, when present.
  final String? contextId;

  /// Optional human-readable rationale supplied by the actor.
  final String? detail;

  /// The unmodified audit-log entry as returned by the VTA API, surfaced in the
  /// UI's expandable "full details" view.
  final Map<String, dynamic> raw;

  /// The denial code portion of a `denied:<code>` outcome, or `null`.
  String? get deniedCode {
    if (status != TrustTaskStatus.denied) return null;
    final idx = rawOutcome.indexOf(':');
    if (idx < 0 || idx + 1 >= rawOutcome.length) return null;
    return rawOutcome.substring(idx + 1);
  }

  static TrustTaskStatus _statusFromOutcome(String outcome) {
    final normalized = outcome.toLowerCase();
    if (normalized == 'success') return TrustTaskStatus.signed;
    if (normalized.startsWith('denied')) return TrustTaskStatus.denied;
    return TrustTaskStatus.unknown;
  }

  static int? _asInt(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }
}

/// A page of trust-task history plus the pagination metadata needed to know
/// whether more rows are available.
class TrustTaskHistoryPage {
  const TrustTaskHistoryPage({
    required this.records,
    required this.page,
    required this.pageSize,
    required this.total,
    required this.totalPages,
  });

  const TrustTaskHistoryPage.empty()
    : records = const [],
      page = 1,
      pageSize = 0,
      total = 0,
      totalPages = 0;

  /// Builds a page from a raw VTA `/audit/logs` response body.
  factory TrustTaskHistoryPage.fromResponse(Map<String, dynamic> body) {
    final entries = (body['entries'] as List?) ?? const [];
    return TrustTaskHistoryPage(
      records: entries
          .whereType<Map>()
          .map((e) => TrustTaskRecord.fromAuditEntry(e.cast<String, dynamic>()))
          .toList(growable: false),
      page: _asInt(body['page']) ?? 1,
      pageSize: _asInt(body['page_size']) ?? entries.length,
      total: _asInt(body['total']) ?? entries.length,
      totalPages: _asInt(body['total_pages']) ?? 1,
    );
  }

  final List<TrustTaskRecord> records;
  final int page;
  final int pageSize;
  final int total;
  final int totalPages;

  /// Whether a subsequent page exists.
  bool get hasMore => page < totalPages;

  static int? _asInt(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }
}
