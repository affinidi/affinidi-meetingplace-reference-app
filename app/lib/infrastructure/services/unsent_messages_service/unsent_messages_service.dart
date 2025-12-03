import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../loggers/app_logger/app_logger.dart';
import '../../providers/app_logger_provider.dart';
import '../../secure_storage/secure_storage.dart';
import 'unsent_messages_state.dart';

part 'unsent_messages_service.g.dart';

/// Service for managing unsent messages per contact.
///
/// This service persists draft messages to secure storage (encrypted),
/// allowing them to survive app restarts while keeping them secure and
/// separate from the main database.
@Riverpod(keepAlive: true)
class UnsentMessagesService extends _$UnsentMessagesService {
  late final AppLogger _logger = ref.read(appLoggerProvider);
  static const _logKey = 'UNSENTMSG';

  @override
  UnsentMessagesServiceState build() {
    return const UnsentMessagesServiceState();
  }

  Future<void>? initializing;
  Future<void> ensureInitialized() async {
    initializing ??= _loadFromSecureStorage();
    await initializing;
  }

  Future<void> _loadFromSecureStorage() async {
    try {
      final storage = await ref.read(secureStorageProvider.future);
      final messages = await storage.getUnsentMessages();
      state = state.copyWith(unsentMessages: messages);
      _logger.info(
        'Loaded ${messages.length} unsent messages from secure storage',
        name: _logKey,
      );
    } catch (e, st) {
      _logger.error(
        'Failed to load unsent messages from secure storage',
        error: e,
        stackTrace: st,
        name: _logKey,
      );
    }
  }

  Future<void> _saveToSecureStorage() async {
    try {
      final storage = await ref.read(secureStorageProvider.future);
      await storage.saveUnsentMessages(state.unsentMessages);
    } catch (e, st) {
      _logger.error(
        'Failed to save unsent messages to secure storage',
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
    await _saveToSecureStorage();
  }

  String? getUnsentMessage(String contactId) {
    return state.unsentMessages[contactId];
  }
}
