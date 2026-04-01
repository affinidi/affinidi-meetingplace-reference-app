import 'dart:async';

import 'package:meeting_place_core/meeting_place_core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../domain/models/identity/identity.dart';
import '../../../infrastructure/exceptions/app_exception.dart';
import '../../../infrastructure/exceptions/app_exception_type.dart';
import '../../../infrastructure/loggers/app_logger/app_logger.dart';
import '../../../infrastructure/providers/app_logger_provider.dart';
import '../../../infrastructure/providers/meeting_place_sdk_provider.dart';
import '../identities_service/identities_service.dart';
import 'oob_service_state.dart';

part 'oob_service.g.dart';

/// Service responsible for creating and accepting out-of-band (OOB) flows.
///
/// This service provides functionality to:
/// - Create an OOB offer that can be shared (e.g., via QR) to initiate a
///  connection.
/// - Accept an incoming OOB offer URL and complete the connection flow.
/// - Observe control plane events to finalize connections and update state.
/// - Expose the last established channel and the current OOB offer in state.
@riverpod
class OOBService extends _$OOBService {
  Identity? _currentIdentity;
  CoreSDKStreamSubscription<OobStreamData, void>?
  _acceptOfferStreamSubscription;
  CoreSDKStreamSubscription<OobStreamData, void>?
  _publishOfferStreamSubscription;
  static const _logKey = 'OOBSVC';
  late final AppLogger _logger = ref.read(appLoggerProvider);

  @override
  OOBServiceState build() {
    ref.listen(identitiesServiceProvider.currentIdentityOrPrimary, (
      prev,
      next,
    ) {
      _currentIdentity = next;
    }, fireImmediately: true);

    ref.onDispose(() {
      _acceptOfferStreamSubscription?.dispose();
      _publishOfferStreamSubscription?.dispose();
    });

    return OOBServiceState();
  }

  /// Create a new out-of-band (OOB) flow and return the created connection
  ///  offer.
  ///
  /// This will call the SDK to create an OOB flow and set `currentOobOffer`
  /// in state on success. The SDK `onDone` callback is also wired to mark the
  /// connection as established when the remote party connects.
  ///
  /// Returns:
  /// - `Future<String>` the created connection offer link
  ///
  Future<String> createOobFlow({String? type}) async {
    final sdk = await ref.read(meetingPlaceSdkProvider.future);
    if (_currentIdentity == null) {
      throw AppException(
        'You need to select an identity first',
        code: AppExceptionType.missingIdentity.name,
      );
    }

    _logger.info('createOobFlow', name: _logKey);

    state = state.copyWith(lastConnectionChannel: null);
    final contactCard = _currentIdentity!.toSdkContactCard();

    final oobOfferSession = await sdk.createOobFlow(
      contactCard: contactCard,
      externalRef: _currentIdentity!.id,
      type: type,
    );

    if (_publishOfferStreamSubscription != null) {
      await _publishOfferStreamSubscription?.dispose();
      _publishOfferStreamSubscription = null;
    }

    _publishOfferStreamSubscription = oobOfferSession.stream;

    _publishOfferStreamSubscription?.listen((data) async {
      final channel = data.channel;
      _handleConnectionEstablished(channel);
      _logger.info('createOobFlow connection established', name: _logKey);
    });

    return oobOfferSession.oobUrl.toString();
  }

  /// Accept an OOB flow given its URL and return the created Contact if
  ///  available.
  ///
  /// This method attempts to parse [oobUrl], call the SDK to accept the OOB
  /// flow and waits for the SDK `onDone` callback. On timeout the state is
  /// updated with an error.
  ///
  /// [oobUrl] - The OOB URL to accept (string).
  ///
  /// Throws [AppException] if:
  /// - The acceptance fails unexpectedly; an AppException wrapping the error
  /// is thrown.
  Future<void> acceptOobFlow(String oobUrl, {String? type}) async {
    final sdk = await ref.read(meetingPlaceSdkProvider.future);

    final oobUri = Uri.tryParse(oobUrl);
    if (oobUri == null) {
      throw AppException(
        'Invalid OOB URL',
        code: AppExceptionType.invalidQrCode.name,
      );
    }

    if (_currentIdentity == null) {
      throw AppException(
        'You need to select an identity first',
        code: AppExceptionType.missingIdentity.name,
      );
    }

    _logger.info('acceptOobFlow $oobUrl', name: _logKey);

    final acceptedOfferCompleter = Completer<void>();

    try {
      final result = await sdk.acceptOobFlow(
        oobUri,
        contactCard: _currentIdentity!.toSdkContactCard(),
        externalRef: _currentIdentity!.id,
        type: type,
      );

      if (_acceptOfferStreamSubscription != null) {
        await _acceptOfferStreamSubscription?.dispose();
        _acceptOfferStreamSubscription = null;
      }

      _acceptOfferStreamSubscription = result.stream;

      _acceptOfferStreamSubscription?.timeout(const Duration(seconds: 60), () {
        _logger.info('acceptOobFlow timeout', name: _logKey);
        if (acceptedOfferCompleter.isCompleted) return;

        acceptedOfferCompleter.completeError(
          AppException(
            'Unable to process OOB offer - timed out',
            code: AppExceptionType.oobFlowTimedOut.name,
          ),
        );
      });

      _acceptOfferStreamSubscription?.listen((data) async {
        final channel = data.channel;
        _handleConnectionEstablished(channel);
        _logger.info('acceptOobFlow connection established', name: _logKey);
        if (acceptedOfferCompleter.isCompleted) return;

        acceptedOfferCompleter.complete();
      });
    } on MeetingPlaceCoreSDKException catch (e, stackTrace) {
      _logger.error(
        '''Unable to process OOB offer - MeetingPlaceCoreSDKException: ${e.message}''',
        error: e,
        stackTrace: stackTrace,
        name: _logKey,
      );

      acceptedOfferCompleter.completeError(
        AppException(
          'Unable to process OOB offer - SDK error: ${e.message}',
          code: e.code,
        ),
      );
    } catch (e, stackTrace) {
      _logger.error(
        'Unable to process OOB offer',
        error: e,
        stackTrace: stackTrace,
        name: _logKey,
      );

      acceptedOfferCompleter.completeError(
        AppException(
          'Unable to process OOB offer - unexpected error: $e',
          code: AppExceptionType.other.name,
        ),
      );
    }

    await acceptedOfferCompleter.future;
  }

  /// Mark a connection as established and update state with the provided
  /// channel.
  ///
  /// [channel] - The channel associated with the newly established connection.
  void _handleConnectionEstablished(Channel channel) {
    state = state.copyWith(lastConnectionChannel: channel);
  }
}
