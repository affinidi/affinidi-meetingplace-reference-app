import 'dart:convert';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../application/services/vrc_service/vrc_service.dart';
import '../../../domain/models/vrc/vrc_credential_subject.dart';
import '../../../infrastructure/loggers/app_logger/app_logger.dart';
import '../../../infrastructure/providers/app_logger_provider.dart';
import 'vrc_details_screen_state.dart';

part 'vrc_details_screen_controller.g.dart';

@riverpod
class VrcDetailsScreenController extends _$VrcDetailsScreenController {
  static const _logKey = 'VRCDTLCTRL';

  late final AppLogger _logger = ref.read(appLoggerProvider);

  @override
  VrcDetailsScreenState build(String credentialId, {String? vcBlob}) {
    final storeVc = ref
        .read(vrcServiceProvider)
        .where((v) => v.id == credentialId)
        .firstOrNull
        ?.vc;
    final vc = storeVc ?? vcBlob ?? '';

    return VrcDetailsScreenState(
      subject: _parseSubject(vc),
      credentialTypes: _parseCredentialTypes(vc),
    );
  }

  VrcCredentialSubject? _parseSubject(String vcJson) {
    if (vcJson.isEmpty) return null;
    try {
      final decoded = jsonDecode(vcJson) as Map<String, dynamic>?;
      if (decoded == null) return null;
      final subject = decoded['credentialSubject'];
      final subjectMap = switch (subject) {
        final Map<String, dynamic> m => m,
        final List<dynamic> l when l.isNotEmpty =>
          l.first as Map<String, dynamic>?,
        _ => null,
      };
      return subjectMap != null
          ? VrcCredentialSubject.fromJson(subjectMap)
          : null;
    } catch (e, st) {
      _logger.error(
        'Failed to parse VRC credentialSubject for $credentialId',
        error: e,
        stackTrace: st,
        name: _logKey,
      );
      return null;
    }
  }

  List<String> _parseCredentialTypes(String vcJson) {
    if (vcJson.isEmpty) return [];
    try {
      final decoded = jsonDecode(vcJson) as Map<String, dynamic>?;
      return (decoded?['type'] as List?)?.cast<String>() ?? [];
    } catch (e, st) {
      _logger.error(
        'Failed to parse VRC credential types for $credentialId',
        error: e,
        stackTrace: st,
        name: _logKey,
      );
      return [];
    }
  }
}
