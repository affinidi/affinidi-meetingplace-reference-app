import 'dart:convert';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../loggers/app_logger/app_logger.dart';
import '../../providers/app_logger_provider.dart';
import '../../providers/shared_preferences_provider.dart';
import 'unsent_messages_state.dart';

part 'unsent_messages_service.g.dart';

/// Service for managing unsent messages per contact.
///
/// This service persists draft messages to SharedPreferences, allowing them
/// to survive app restarts while keeping them separate from the main database.
@Riverpod(keepAlive: true)
class UnsentMessagesService extends _$UnsentMessagesService {
  late final AppLogger _logger = ref.read(appLoggerProvider);
  static const _logKey = 'UNSENTMSG';

  @override
  UnsentMessagesServiceState build() {
    final unsentMessages = _loadFromPrefs();
    return UnsentMessagesServiceState(unsentMessages: unsentMessages);
  }

  Map<String, String> _loadFromPrefs() {
    try {
      final prefs = ref.read(sharedPreferencesProvider);
      final json = prefs.getString(SharedPreferencesKeys.unsentMessages.name);
      if (json != null && json.isNotEmpty) {
        final decoded = jsonDecode(json) as Map<String, dynamic>;
        final messages = Map<String, String>.from(decoded);
        _logger.info(
          'Loaded ${messages.length} unsent messages from SharedPreferences',
          name: _logKey,
        );
        return messages;
      }
    } catch (e, st) {
      _logger.error(
        'Failed to load unsent messages from SharedPreferences',
        error: e,
        stackTrace: st,
        name: _logKey,
      );
    }
    return {};
  }

  Future<void> _saveToPrefs() async {
    try {
      final prefs = ref.read(sharedPreferencesProvider);
      if (state.unsentMessages.isEmpty) {
        await prefs.remove(SharedPreferencesKeys.unsentMessages.name);
      } else {
        final json = jsonEncode(state.unsentMessages);
        await prefs.setString(SharedPreferencesKeys.unsentMessages.name, json);
      }
    } catch (e, st) {
      _logger.error(
        'Failed to save unsent messages to SharedPreferences',
        error: e,
        stackTrace: st,
        name: _logKey,
      );
    }
  }

  Future<void> saveUnsentMessage(String contactId, String? text) async {
    final currentMessages = Map<String, String>.from(state.unsentMessages);

    if (text == null || text.isEmpty) {
      currentMessages.remove(contactId);
    } else {
      currentMessages[contactId] = text;
    }

    state = state.copyWith(unsentMessages: currentMessages);
    await _saveToPrefs();
  }

  String? getUnsentMessage(String contactId) {
    return state.unsentMessages[contactId];
  }

  Future<void> clearUnsentMessage(String contactId) async {
    final currentMessages = Map<String, String>.from(state.unsentMessages);
    currentMessages.remove(contactId);
    state = state.copyWith(unsentMessages: currentMessages);
    await _saveToPrefs();
  }

  Future<void> clearAll() async {
    state = const UnsentMessagesServiceState();
    await _saveToPrefs();
  }
}
