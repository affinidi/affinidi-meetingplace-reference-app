import 'package:flutter_test/flutter_test.dart';
import 'package:mpx_flutter_reference_app/domain/models/trust_task/trust_task_record.dart';

void main() {
  group('TrustTaskRecord.fromAuditEntry', () {
    test('maps a successful signing row to a signed record', () {
      final record = TrustTaskRecord.fromAuditEntry({
        'id': 'log:1',
        'timestamp': 1700000000,
        'action': 'vault.sign-trust-task',
        'actor': 'did:key:zConnector',
        'resource': 'entry-42',
        'outcome': 'success',
        'context_id': 'ctx-0',
      });

      expect(record.id, 'log:1');
      expect(record.status, TrustTaskStatus.signed);
      expect(record.entryId, 'entry-42');
      expect(record.actor, 'did:key:zConnector');
      expect(record.contextId, 'ctx-0');
      expect(record.deniedCode, isNull);
      expect(
        record.timestamp.toUtc(),
        DateTime.fromMillisecondsSinceEpoch(1700000000 * 1000, isUtc: true),
      );
    });

    test('preserves the unmodified raw audit entry', () {
      final entry = <String, dynamic>{
        'id': 'log:9',
        'timestamp': 42,
        'outcome': 'success',
        'channel': 'trust_task',
        'detail': {'kind': 'agent-response'},
      };
      final record = TrustTaskRecord.fromAuditEntry(entry);

      expect(record.raw, equals(entry));
      expect(record.raw['channel'], 'trust_task');
      expect(record.raw['detail'], {'kind': 'agent-response'});
    });

    test('maps a denied row and extracts the denial code', () {
      final record = TrustTaskRecord.fromAuditEntry({
        'id': 'log:2',
        'timestamp': 1700000100,
        'outcome': 'denied:auth/step-up/required',
      });

      expect(record.status, TrustTaskStatus.denied);
      expect(record.deniedCode, 'auth/step-up/required');
    });

    test('classifies an unrecognised outcome as unknown', () {
      final record = TrustTaskRecord.fromAuditEntry({
        'id': 'log:3',
        'timestamp': 1,
        'outcome': 'weird',
      });

      expect(record.status, TrustTaskStatus.unknown);
      expect(record.deniedCode, isNull);
    });

    test('tolerates missing/blank fields', () {
      final record = TrustTaskRecord.fromAuditEntry({});
      expect(record.id, '');
      expect(record.status, TrustTaskStatus.unknown);
      expect(record.entryId, isNull);
      expect(record.contextId, isNull);
    });
  });

  group('TrustTaskHistoryPage.fromResponse', () {
    test('parses entries and pagination metadata', () {
      final page = TrustTaskHistoryPage.fromResponse({
        'entries': [
          {'id': 'a', 'timestamp': 2, 'outcome': 'success'},
          {'id': 'b', 'timestamp': 1, 'outcome': 'denied:x'},
        ],
        'total': 5,
        'page': 1,
        'page_size': 2,
        'total_pages': 3,
      });

      expect(page.records, hasLength(2));
      expect(page.total, 5);
      expect(page.page, 1);
      expect(page.totalPages, 3);
      expect(page.hasMore, isTrue);
    });

    test('hasMore is false on the last page', () {
      final page = TrustTaskHistoryPage.fromResponse({
        'entries': const <Map<String, dynamic>>[],
        'total': 2,
        'page': 2,
        'page_size': 20,
        'total_pages': 2,
      });
      expect(page.hasMore, isFalse);
      expect(page.records, isEmpty);
    });
  });
}
