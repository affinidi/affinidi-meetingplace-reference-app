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
import '../../../infrastructure/providers/r_cards_repository_provider.dart';
import '../../../infrastructure/providers/relationship_sdk_provider.dart';

part 'r_cards_service.g.dart';

/// Service that drives the R-Card feature.
///
/// Responsibilities:
/// - Exposes all stored [ReceivedRCard]s as live state for the UI.
/// - Subscribes to `MeetingPlaceRelationshipSDK.receivedRCards` and persists
///   every verified card via `RCardRepository.upsertFromVdip`.
@Riverpod(keepAlive: true)
class RCardsService extends _$RCardsService {
  static const _logKey = 'RCARDSVC';

  late final AppLogger _logger = ref.read(appLoggerProvider);

  StreamSubscription<ReceivedRCard>? _incomingSubscription;
  StreamSubscription<List<ReceivedRCard>>? _watchSubscription;

  @override
  List<ReceivedRCard> build() {
    unawaited(_init());

    ref.onDispose(() {
      _incomingSubscription?.cancel();
      _watchSubscription?.cancel();
    });

    return const [];
  }

  Future<void> _init() async {
    await Future.wait([_startWatching(), _listenForIncoming()]);
  }

  Future<void> _startWatching() async {
    final repository = await ref.read(rCardsRepositoryProvider.future);

    await _watchSubscription?.cancel();
    _watchSubscription = repository.watchAll().listen(
      (cards) => state = cards,
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

  /// Subscribes to [MeetingPlaceRelationshipSDK.receivedRCards] and persists
  /// each verified card to the repository.
  Future<void> _listenForIncoming() async {
    try {
      final relationshipSDK = await ref.read(relationshipSdkProvider.future);
      final repository = await ref.read(rCardsRepositoryProvider.future);

      _incomingSubscription = relationshipSDK.receivedRCards.listen(
        (rCard) async {
          try {
            await repository.upsertFromVdip(
              subjectDid: rCard.subjectDid,
              issuerDid: rCard.issuerDid,
              vcBlob: rCard.vcBlob,
              issuanceDate: rCard.issuanceDate,
              threadId: rCard.threadId,
              contactChannelDid: rCard.contactChannelDid,
              receivedAt: rCard.receivedAt,
            );
          } catch (error, stackTrace) {
            _logger.error(
              'Failed to persist incoming R-Card',
              error: error,
              stackTrace: stackTrace,
              name: _logKey,
            );
          }
        },
        onError: (Object error, StackTrace stackTrace) {
          _logger.error(
            'Error on receivedRCards stream',
            error: error,
            stackTrace: stackTrace,
            name: _logKey,
          );
        },
      );
    } catch (error, stackTrace) {
      _logger.error(
        'Failed to start incoming R-Card listener',
        error: error,
        stackTrace: stackTrace,
        name: _logKey,
      );
    }
  }

  Future<XFile> exportAllAsVcf() async {
    final repository = await ref.read(rCardsRepositoryProvider.future);
    final cards = await repository.listAll();

    final blocks = cards.map(_toVCard).whereType<String>().join();
    return _writeVcfFile(blocks, fileName: 'R-Cards.vcf');
  }

  Future<XFile?> exportSingleAsVcf(ReceivedRCard card) async {
    final vCard = _toVCard(card);
    if (vCard == null) return null;

    return _writeVcfFile(vCard, fileName: 'R-Card.vcf');
  }

  Future<void> deleteBySubjectDid(String subjectDid) async {
    final repository = await ref.read(rCardsRepositoryProvider.future);
    await repository.deleteBySubjectDid(subjectDid);
  }

  Future<void> updateNotes(String subjectDid, String? notes) async {
    final repository = await ref.read(rCardsRepositoryProvider.future);
    await repository.updateNotes(subjectDid, notes);
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

  String? _toVCard(ReceivedRCard card) {
    final subject = RCardSubject.fromVcBlob(card.vcBlob);
    if (subject == null) {
      _logger.warning(
        'Skipping R-Card export: failed to parse vcBlob for ${card.subjectDid}',
        name: _logKey,
      );
      return null;
    }

    return subject.toVCard();
  }
}
