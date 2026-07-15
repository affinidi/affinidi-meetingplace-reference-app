import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../infrastructure/providers/shared_preferences_provider.dart';

enum AgentContext { work, personal }

class ContextRoutingState {
  const ContextRoutingState({
    this.workContextUploaded = false,
    this.personalContextUploaded = false,
    this.workContextFileName,
    this.personalContextFileName,
    this.contactContexts = const {},
    this.initialized = false,
  });

  final bool workContextUploaded;
  final bool personalContextUploaded;
  final String? workContextFileName;
  final String? personalContextFileName;
  final Map<String, AgentContext> contactContexts;
  final bool initialized;

  ContextRoutingState copyWith({
    bool? workContextUploaded,
    bool? personalContextUploaded,
    String? workContextFileName,
    bool clearWorkContextFileName = false,
    String? personalContextFileName,
    bool clearPersonalContextFileName = false,
    Map<String, AgentContext>? contactContexts,
    bool? initialized,
  }) {
    return ContextRoutingState(
      workContextUploaded: workContextUploaded ?? this.workContextUploaded,
      personalContextUploaded:
          personalContextUploaded ?? this.personalContextUploaded,
      workContextFileName: clearWorkContextFileName
          ? null
          : workContextFileName ?? this.workContextFileName,
      personalContextFileName: clearPersonalContextFileName
          ? null
          : personalContextFileName ?? this.personalContextFileName,
      contactContexts: contactContexts ?? this.contactContexts,
      initialized: initialized ?? this.initialized,
    );
  }

  bool isContextUploaded(AgentContext context) {
    return context == AgentContext.work
        ? workContextUploaded
        : personalContextUploaded;
  }

  AgentContext contextForContactId(String contactId) {
    return contactContexts[contactId] ?? AgentContext.personal;
  }

  String? fileNameForContext(AgentContext context) {
    return context == AgentContext.work
        ? workContextFileName
        : personalContextFileName;
  }
}

final contextRoutingServiceProvider =
    StateNotifierProvider<ContextRoutingService, ContextRoutingState>(
      ContextRoutingService.new,
    );

class ContextRoutingService extends StateNotifier<ContextRoutingState> {
  ContextRoutingService(this._ref) : super(const ContextRoutingState()) {
    _load();
  }

  static const _workUploadedKey = 'cierge_context_uploaded_work';
  static const _personalUploadedKey = 'cierge_context_uploaded_personal';
  static const _workFileNameKey = 'cierge_context_file_name_work';
  static const _personalFileNameKey = 'cierge_context_file_name_personal';
  static const _contactContextMapKey = 'cierge_contact_context_map';

  final Ref _ref;

  SharedPreferences get _prefs => _ref.read(sharedPreferencesProvider);

  Future<void> _load() async {
    final rawMap = _prefs.getString(_contactContextMapKey);
    final decoded = _decodeContactMap(rawMap);
    state = state.copyWith(
      workContextUploaded: _prefs.getBool(_workUploadedKey) ?? false,
      personalContextUploaded: _prefs.getBool(_personalUploadedKey) ?? false,
      workContextFileName: _prefs.getString(_workFileNameKey),
      personalContextFileName: _prefs.getString(_personalFileNameKey),
      contactContexts: decoded,
      initialized: true,
    );
  }

  Future<void> assignContactContext(
    String contactId,
    AgentContext context,
  ) async {
    final next = Map<String, AgentContext>.from(state.contactContexts)
      ..[contactId] = context;

    state = state.copyWith(contactContexts: next);
    await _prefs.setString(_contactContextMapKey, _encodeContactMap(next));
  }

  Future<void> markContextUploaded({
    required AgentContext context,
    required String fileName,
  }) async {
    if (context == AgentContext.work) {
      state = state.copyWith(
        workContextUploaded: true,
        workContextFileName: fileName,
      );
      await _prefs.setBool(_workUploadedKey, true);
      await _prefs.setString(_workFileNameKey, fileName);
      return;
    }

    state = state.copyWith(
      personalContextUploaded: true,
      personalContextFileName: fileName,
    );
    await _prefs.setBool(_personalUploadedKey, true);
    await _prefs.setString(_personalFileNameKey, fileName);
  }

  Map<String, AgentContext> _decodeContactMap(String? raw) {
    if (raw == null || raw.isEmpty) return const {};
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) return const {};
      final out = <String, AgentContext>{};
      for (final entry in decoded.entries) {
        final v = entry.value.toString().trim().toLowerCase();
        out[entry.key] = v == 'work'
            ? AgentContext.work
            : AgentContext.personal;
      }
      return out;
    } catch (_) {
      return const {};
    }
  }

  String _encodeContactMap(Map<String, AgentContext> map) {
    final serializable = map.map(
      (k, v) => MapEntry(k, v == AgentContext.work ? 'work' : 'personal'),
    );
    return jsonEncode(serializable);
  }
}
