import 'package:flutter_test/flutter_test.dart';
import 'package:meeting_place_matrix/meeting_place_matrix.dart';
import 'package:mpx_flutter_reference_app/domain/models/call_log/call_log_entry.dart';
import 'package:mpx_flutter_reference_app/l10n/app_localizations.dart';
import 'package:mpx_flutter_reference_app/presentation/screens/call_log/call_log_screen.dart';

import '../../../mocks/fake_app_localizations.dart';

CallLogEntry _groupEntry({
  required int participantCount,
  List<String>? participantNames,
}) => CallLogEntry(
  contactId: 'contact-1',
  displayLabel: 'Group chat',
  mediaType: CallMediaType.audio,
  status: CallStatus.ended,
  timestamp: DateTime.utc(2026, 1, 1),
  durationMs: 60000,
  isFromMe: true,
  isGroupCall: true,
  participantCount: participantCount,
  participantNames: participantNames,
);

void main() {
  group('resolveCallLogParticipantsLabel', () {
    late AppLocalizations l10n;

    setUp(() {
      l10n = FakeAppLocalizations();
    });

    test('returns null for a 1:1 call', () {
      final entry = CallLogEntry(
        contactId: 'contact-1',
        displayLabel: 'Alice',
        mediaType: CallMediaType.audio,
        status: CallStatus.ended,
        timestamp: DateTime.utc(2026, 1, 1),
        durationMs: 60000,
        isFromMe: true,
        isGroupCall: false,
        participantCount: 1,
      );

      expect(resolveCallLogParticipantsLabel(l10n, entry), isNull);
    });

    test('falls back to the count label when no name resolved', () {
      final entry = _groupEntry(participantCount: 3);

      expect(
        resolveCallLogParticipantsLabel(l10n, entry),
        l10n.callLogParticipantsCount(3),
      );
    });

    test('joins names with no remainder when every peer resolved', () {
      final entry = _groupEntry(
        participantCount: 2,
        participantNames: ['Alice', 'Bob'],
      );

      expect(resolveCallLogParticipantsLabel(l10n, entry), 'Alice, Bob');
    });

    test('appends the unresolved remainder when some, but not all, peers '
        'resolved to a known contact', () {
      final entry = _groupEntry(
        participantCount: 3,
        participantNames: ['Alice'],
      );

      expect(
        resolveCallLogParticipantsLabel(l10n, entry),
        l10n.callLogParticipantsNamesAndOthers('Alice', 2),
      );
    });

    test('never understates the roster: never shows fewer people than '
        'participantCount', () {
      final entry = _groupEntry(
        participantCount: 3,
        participantNames: ['Alice'],
      );

      final label = resolveCallLogParticipantsLabel(l10n, entry)!;

      expect(label, contains('Alice'));
      expect(label, contains('2'));
    });
  });
}
