import 'dart:async';

import 'package:clock/clock.dart';
import 'package:meeting_place_chat/meeting_place_chat.dart' as chat;

import '../../../domain/models/contacts/contact_presence_status.dart';
import '../../../infrastructure/helpers/timed_action.dart';

/// Encapsulates all presence handling logic for the chat screen:
/// - tracking group member presence with per-member expiry timers
/// - tracking 1:1 contact presence with a heartbeat-expiry timed action
///
/// Mirrors the structure of ChatMentionsService: pure logic object that
/// accepts callbacks for state updates, keeping Riverpod state manipulation in
/// the controller.
class ChatPresenceService {
  ChatPresenceService({required int presenceIntervalInSeconds})
    : _presenceIntervalInSeconds = presenceIntervalInSeconds;

  // Grace period added to the interval to prevent blinking of the indicator.
  static const int _gracePeriodSeconds = 1;

  final int _presenceIntervalInSeconds;
  final Map<String, Timer> _memberPresenceTimers = {};
  TimedAction? _contactPresenceTimedAction;

  /// Updates a group member's presence status from a `chatPresence` message.
  ///
  /// [message] is the incoming presence plain-text message.
  /// [onStatusChanged] is called with `(did, status)` immediately and again
  /// when the heartbeat expiry timer fires (to set the member offline).
  void updateGroupMemberPresence(
    chat.PlainTextMessage message,
    void Function(String did, ContactPresenceStatus status) onStatusChanged,
  ) {
    final senderDid = message.from;
    final presenceStr = message.body?['presence'] as String?;
    if (senderDid == null || presenceStr == null) return;

    // Matrix presence values: online, unavailable (away/idle), offline.
    // Treat anything except explicit 'offline' as online.
    final isOnline = presenceStr != 'offline';
    onStatusChanged(
      senderDid,
      isOnline ? ContactPresenceStatus.online : ContactPresenceStatus.offline,
    );

    // Reset the expiry timer on each online event;
    // cancel it on explicit offline.
    _memberPresenceTimers[senderDid]?.cancel();
    if (isOnline) {
      _memberPresenceTimers[senderDid] = Timer(
        Duration(seconds: _presenceIntervalInSeconds + _gracePeriodSeconds),
        () {
          onStatusChanged(senderDid, ContactPresenceStatus.offline);
          _memberPresenceTimers.remove(senderDid);
        },
      );
    } else {
      _memberPresenceTimers.remove(senderDid);
    }
  }

  /// Updates the 1:1 contact's presence based on the heartbeat [datePresence]
  /// timestamp. [onStatusChanged] is called with the new status whenever it
  /// changes.
  void updateContactPresence(
    DateTime datePresence,
    void Function(ContactPresenceStatus status) onStatusChanged,
  ) {
    _contactPresenceTimedAction?.cancel();

    _contactPresenceTimedAction ??= TimedAction(
      onRun: (args) {
        final now = clock.now();
        final ts = args?[0] as DateTime? ?? now;
        final hasReceivedAnyActivity = ts.toLocal().isAfter(
          now.subtract(Duration(seconds: _presenceIntervalInSeconds)),
        );
        onStatusChanged(
          hasReceivedAnyActivity
              ? ContactPresenceStatus.online
              : ContactPresenceStatus.offline,
        );
      },
      onComplete: () {
        Future.microtask(() => onStatusChanged(ContactPresenceStatus.offline));
      },
      duration: Duration(
        seconds: _presenceIntervalInSeconds + _gracePeriodSeconds,
      ),
    );

    _contactPresenceTimedAction?.start(args: [datePresence]);
  }

  /// Cancels all active presence timers. Must be called when the service is
  /// no longer needed (e.g. in the controller's onDispose).
  void dispose() {
    for (final t in _memberPresenceTimers.values) {
      t.cancel();
    }
    _memberPresenceTimers.clear();
    _contactPresenceTimedAction?.cancel();
  }
}
