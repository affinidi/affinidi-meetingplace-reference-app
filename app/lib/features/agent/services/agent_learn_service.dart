import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Fire-and-forget observation service that ships outbound messages to the
/// agent learning backend. The toggle state survives app restarts via
/// [SharedPreferences].
///
/// [observeOutboundMessage] is intentionally synchronous at the call site —
/// it never throws or blocks, and silently drops observations when learning
/// is disabled or the backend URL is not configured.
class AgentLearnService {
  AgentLearnService({
    required SharedPreferences prefs,
    required http.Client client,
    required String backendUrl,
  }) : _prefs = prefs,
       _client = client,
       _backendUrl = backendUrl;

  final SharedPreferences _prefs;
  final http.Client _client;
  final String _backendUrl;

  static const _toggleKey = 'agent_learning_enabled';

  bool get isLearningEnabled => _prefs.getBool(_toggleKey) ?? false;

  Future<void> setLearningEnabled(bool value) =>
      _prefs.setBool(_toggleKey, value);

  /// Call this at every outbound message. Safe to call from any context —
  /// returns immediately and performs the HTTP call in the background.
  void observeOutboundMessage({
    required String ownerDid,
    required String conversationId,
    required String recipientDid,
    required String messageText,
    List<Map<String, dynamic>>? recentHistory,
  }) {
    if (!isLearningEnabled) {
      debugPrint('[AgentLearn] skipped — learning toggle is OFF');
      return;
    }
    if (_backendUrl.isEmpty) {
      debugPrint('[AgentLearn] skipped — AGENT_BACKEND_URL is not configured');
      return;
    }
    debugPrint(
      '[AgentLearn] sending message to backend (ownerDid: $ownerDid, conv: $conversationId)',
    );
    unawaited(
      _sendObservation(
        ownerDid: ownerDid,
        conversationId: conversationId,
        recipientDid: recipientDid,
        messageText: messageText,
        recentHistory: recentHistory,
      ),
    );
  }

  Future<void> _sendObservation({
    required String ownerDid,
    required String conversationId,
    required String recipientDid,
    required String messageText,
    List<Map<String, dynamic>>? recentHistory,
  }) async {
    try {
      final response = await _client.post(
        Uri.parse('$_backendUrl/learn'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'ownerDid': ownerDid,
          'conversationId': conversationId,
          'recipientDid': recipientDid,
          'messageText': messageText,
          'recentHistory': recentHistory ?? [],
          'timestamp': DateTime.now().toIso8601String(),
        }),
      );
      debugPrint(
        '[AgentLearn] /learn response: ${response.statusCode} — ${response.body}',
      );
    } catch (e) {
      debugPrint('[AgentLearn] /learn error: $e');
    }
  }
}
