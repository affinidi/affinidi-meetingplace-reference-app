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

enum AgentContext {
  work('ctx-0', 'work-ai');

  const AgentContext(this.routeKey, this.setupContextName);

  /// Canonical MPX/personal-agent wire context. These are app-level logical
  /// slots; backend domain mapping may resolve them to different physical VTA
  /// contexts per app instance.
  final String routeKey;
  final String setupContextName;

  static AgentContext fromRouteKey(String value) {
    final normalized = value.trim().toLowerCase();
    return switch (normalized) {
      'ctx-0' || 'work' || 'work-ai' => AgentContext.work,
      _ => AgentContext.work,
    };
  }
}

class ContextRoutingState {
  const ContextRoutingState({
    this.workContextUploaded = false,
    this.workContextFileName,
    this.workContextKilled = false,
    this.contactContexts = const {},
    this.initialized = false,
  });

  final bool workContextUploaded;
  final String? workContextFileName;
  final bool workContextKilled;
  final Map<String, AgentContext> contactContexts;
  final bool initialized;

  ContextRoutingState copyWith({
    bool? workContextUploaded,
    String? workContextFileName,
    bool clearWorkContextFileName = false,
    bool? workContextKilled,
    Map<String, AgentContext>? contactContexts,
    bool? initialized,
  }) {
    return ContextRoutingState(
      workContextUploaded: workContextUploaded ?? this.workContextUploaded,
      workContextFileName: clearWorkContextFileName
          ? null
          : workContextFileName ?? this.workContextFileName,
      workContextKilled: workContextKilled ?? this.workContextKilled,
      contactContexts: contactContexts ?? this.contactContexts,
      initialized: initialized ?? this.initialized,
    );
  }

  bool isContextUploaded(AgentContext context) {
    return workContextUploaded;
  }

  AgentContext contextForContactId(String contactId) {
    return contactContexts[contactId] ?? AgentContext.work;
  }

  String? fileNameForContext(AgentContext context) {
    return workContextFileName;
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
  static const _workFileNameKey = 'cierge_context_file_name_work';
  static const _workKilledKey = 'cierge_context_killed_work';
  static const _contactContextMapKey = 'cierge_contact_context_map';

  final Ref _ref;

  ContextRoutingStore get _store => _ref.read(contextRoutingStoreProvider);

  Future<void> _load() async {
    final rawMap = _store.getString(_contactContextMapKey);
    final decoded = _decodeContactMap(rawMap);
    state = state.copyWith(
      workContextUploaded: _store.getBool(_workUploadedKey) ?? false,
      workContextFileName: _store.getString(_workFileNameKey),
      workContextKilled: _store.getBool(_workKilledKey) ?? false,
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
    if (state.workContextKilled) return;

    state = state.copyWith(
      workContextUploaded: true,
      workContextFileName: fileName,
    );
    await _store.setBool(_workUploadedKey, true);
    await _store.setString(_workFileNameKey, fileName);
  }

  Future<void> clearContext({required AgentContext context}) async {
    final next = Map<String, AgentContext>.from(state.contactContexts)
      ..removeWhere((_, assigned) => assigned == context);

    state = state.copyWith(
      workContextUploaded: false,
      clearWorkContextFileName: true,
      contactContexts: next,
    );
    await _store.setBool(_workUploadedKey, false);
    await _store.setString(_workFileNameKey, '');

    await _store.setString(_contactContextMapKey, _encodeContactMap(next));
  }

  Future<void> killContext({required AgentContext context}) async {
    final next = Map<String, AgentContext>.from(state.contactContexts)
      ..removeWhere((_, assigned) => assigned == context);

    state = state.copyWith(
      workContextUploaded: false,
      clearWorkContextFileName: true,
      workContextKilled: true,
      contactContexts: next,
    );
    await _store.setBool(_workUploadedKey, false);
    await _store.setString(_workFileNameKey, '');
    await _store.setBool(_workKilledKey, true);
    await _store.setString(_contactContextMapKey, _encodeContactMap(next));
  }

  Map<String, AgentContext> _decodeContactMap(String? raw) {
    if (raw == null || raw.isEmpty) return const {};
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) return const {};
      final out = <String, AgentContext>{};
      for (final entry in decoded.entries) {
        out[entry.key] = AgentContext.fromRouteKey(entry.value.toString());
      }
      return out;
    } catch (_) {
      return const {};
    }
  }

  String _encodeContactMap(Map<String, AgentContext> map) {
    final serializable = map.map((k, v) => MapEntry(k, v.routeKey));
    return jsonEncode(serializable);
  }
}
