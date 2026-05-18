import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cross_file/cross_file.dart';
import 'package:meeting_place_relationship/meeting_place_relationship.dart';
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../../infrastructure/loggers/app_logger/app_logger.dart';
import '../../../infrastructure/providers/app_logger_provider.dart';
import '../../../infrastructure/providers/relationship_sdk_provider.dart';

part 'r_cards_service.g.dart';

/// Service that drives the R-Card feature.
///
/// Responsibilities:
/// - Exposes all stored [RCard]s as live state for the UI.
/// - Delegates all persistence operations to [MeetingPlaceRelationshipSDK]
///   so consumers only need one dependency for the full R-Card feature.
@Riverpod(keepAlive: true)
class RCardsService extends _$RCardsService {
  static const _logKey = 'RCARDSVC';

  late final AppLogger _logger = ref.read(appLoggerProvider);

  StreamSubscription<List<RCard>>? _watchSubscription;

  @override
  List<RCard> build() {
    unawaited(_startWatching());

    ref.onDispose(() {
      _watchSubscription?.cancel();
    });

    return const [];
  }

  Future<void> _startWatching() async {
    final sdk = await ref.read(relationshipSdkProvider.future);

    await _watchSubscription?.cancel();
    _watchSubscription = sdk.watchReceivedRCards().listen(
      (List<RCard> cards) => state = cards,
      onError: (Object error, StackTrace stackTrace) {
        _logger.error(
          'Failed to watch R-Cards',
          error: error,
          stackTrace: stackTrace,
          name: _logKey,
        );
      },
    );
  }

  Future<XFile> exportAllAsVcf() async {
    final sdk = await ref.read(relationshipSdkProvider.future);
    final cards = await sdk.listReceivedRCards();

    final blocks = cards.map(_toVCard).whereType<String>().join();
    return _writeVcfFile(blocks, fileName: 'R-Cards.vcf');
  }

  Future<XFile?> exportSingleAsVcf(RCard card) async {
    final vCard = _toVCard(card);
    if (vCard == null) return null;

    return _writeVcfFile(vCard, fileName: 'R-Card.vcf');
  }

  Future<void> deleteBySubjectDid(String subjectDid) async {
    final sdk = await ref.read(relationshipSdkProvider.future);
    await sdk.deleteReceivedRCard(subjectDid);
  }

  Future<void> updateNotes(String subjectDid, String? notes) async {
    final sdk = await ref.read(relationshipSdkProvider.future);
    await sdk.updateReceivedRCardNotes(subjectDid, notes);
  }

  Future<XFile> _writeVcfFile(
    String content, {
    required String fileName,
  }) async {
    final directory = await getTemporaryDirectory();
    final safeName = '${const Uuid().v4()}_$fileName';
    final filePath = '${directory.path}/$safeName';

    final file = File(filePath);
    await file.writeAsString(content, encoding: utf8);

    return XFile(filePath, mimeType: 'text/vcard', name: fileName);
  }

  String? _toVCard(RCard card) {
    final RCardSubject subject;
    try {
      subject = RCardSubject.fromVcBlob(card.vcBlob);
    } on FormatException {
      _logger.warning(
        'Skipping R-Card export: failed to parse vcBlob for ${card.subjectDid}',
        name: _logKey,
      );
      return null;
    }

    return subject.toVCard();
  }
}
