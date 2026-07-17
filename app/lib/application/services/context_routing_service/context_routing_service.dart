import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

abstract class ContextRoutingStore {
  bool? getBool(String key);
  String? getString(String key);
  Future<void> setBool(String key, bool value);
  Future<void> setString(String key, String value);
}

final contextRoutingStoreProvider = Provider<ContextRoutingStore>(
  (_) => throw UnimplementedError(
    'contextRoutingStoreProvider must be overridden in composition root',
  ),
  name: 'contextRoutingStoreProvider',
);

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

  ContextRoutingStore get _store => _ref.read(contextRoutingStoreProvider);

  Future<void> _load() async {
    final rawMap = _store.getString(_contactContextMapKey);
    final decoded = _decodeContactMap(rawMap);
    state = state.copyWith(
      workContextUploaded: _store.getBool(_workUploadedKey) ?? false,
      personalContextUploaded: _store.getBool(_personalUploadedKey) ?? false,
      workContextFileName: _store.getString(_workFileNameKey),
      personalContextFileName: _store.getString(_personalFileNameKey),
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
    await _store.setString(_contactContextMapKey, _encodeContactMap(next));
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
      await _store.setBool(_workUploadedKey, true);
      await _store.setString(_workFileNameKey, fileName);
      return;
    }

    state = state.copyWith(
      personalContextUploaded: true,
      personalContextFileName: fileName,
    );
    await _store.setBool(_personalUploadedKey, true);
    await _store.setString(_personalFileNameKey, fileName);
  }

  Future<void> clearContext({required AgentContext context}) async {
    final next = Map<String, AgentContext>.from(state.contactContexts)
      ..removeWhere((_, assigned) => assigned == context);

    if (context == AgentContext.work) {
      state = state.copyWith(
        workContextUploaded: false,
        clearWorkContextFileName: true,
        contactContexts: next,
      );
      await _store.setBool(_workUploadedKey, false);
      await _store.setString(_workFileNameKey, '');
    } else {
      state = state.copyWith(
        personalContextUploaded: false,
        clearPersonalContextFileName: true,
        contactContexts: next,
      );
      await _store.setBool(_personalUploadedKey, false);
      await _store.setString(_personalFileNameKey, '');
    }

    await _store.setString(_contactContextMapKey, _encodeContactMap(next));
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
