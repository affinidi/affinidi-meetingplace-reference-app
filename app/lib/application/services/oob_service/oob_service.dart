import 'dart:async';

import 'package:meeting_place_core/meeting_place_core.dart'
    hide ContactCardType;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../domain/models/identity/identity.dart';
import '../../../infrastructure/exceptions/app_exception.dart';
import '../../../infrastructure/exceptions/app_exception_type.dart';
import '../../../infrastructure/extensions/contact_card_extensions.dart';
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
  CoreSDKStreamSubscription<OobStreamData>? _acceptOfferStreamSubscription;
  CoreSDKStreamSubscription<OobStreamData>? _publishOfferStreamSubscription;
  static const _logKey = 'OOBSVC';
  late final AppLogger _logger = ref.read(appLoggerProvider);

  @override
  OOBServiceState build() {
    ref.listen(
      identitiesServiceProvider.currentIdentityOrPrimary,
      (prev, next) {
        _currentIdentity = next;
      },
      fireImmediately: true,
    );

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
  Future<String> createOobFlow() async {
    final sdk = await ref.read(meetingPlaceSdkProvider.future);
    if (_currentIdentity == null) {
      throw AppException(
        'You need to select an identity first',
        code: AppExceptionType.missingIdentity.name,
      );
    }

    _logger.info('createOobFlow', name: _logKey);

    final contactCard = _currentIdentity!.card.toSdkContactCard(
      did: _currentIdentity!.did,
      type: ContactCardType.human.value,
    );

    final createOobFlowResult = await sdk.createOobFlow(
      contactCard: contactCard,
      did: _currentIdentity!.did,
    );

    if (_publishOfferStreamSubscription != null) {
      await _publishOfferStreamSubscription?.dispose();
      _publishOfferStreamSubscription = null;
    }

    _publishOfferStreamSubscription = createOobFlowResult.streamSubscription;

    _publishOfferStreamSubscription?.listen((data) async {
      final channel = data.channel;
      _handleConnectionEstablished(channel);
      _logger.info('createOobFlow connection established', name: _logKey);
    });

    return createOobFlowResult.oobUrl.toString();
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
  Future<void> acceptOobFlow(String oobUrl) async {
    final sdk = await ref.read(meetingPlaceSdkProvider.future);

    final oobUri = Uri.parse(oobUrl);
    if (_currentIdentity == null) {
      throw AppException(
        'You need to select an identity first',
        code: AppExceptionType.missingIdentity.name,
      );
    }

    _logger.info('acceptOobFlow', name: _logKey);

    final result = await sdk.acceptOobFlow(
      oobUri,
      contactCard: _currentIdentity!.card.toSdkContactCard(
        did: _currentIdentity!.did,
        type: ContactCardType.human.value,
      ),
      did: _currentIdentity!.did,
      externalRef: _currentIdentity!.id,
    );
    final acceptedOfferCompleter = Completer<void>();

    if (_acceptOfferStreamSubscription != null) {
      await _acceptOfferStreamSubscription?.dispose();
      _acceptOfferStreamSubscription = null;
    }

    _acceptOfferStreamSubscription = result.streamSubscription;

    _acceptOfferStreamSubscription?.timeout(
      const Duration(seconds: 60),
      () {
        _logger.info('acceptOobFlow timeout', name: _logKey);
        acceptedOfferCompleter.completeError(AppException(
          'Unable to process OOB offer',
          code: AppExceptionType.oobFlowFailed.name,
        ));
      },
    );

    _acceptOfferStreamSubscription?.listen((data) async {
      final channel = data.channel;
      _handleConnectionEstablished(channel);
      _logger.info('acceptOobFlow connection established', name: _logKey);
      acceptedOfferCompleter.complete();
    });

    await acceptedOfferCompleter.future;
  }

  /// Mark a connection as established and update state with the provided
  /// channel.
  ///
  /// [channel] - The channel associated with the newly established connection.
  void _handleConnectionEstablished(Channel channel) {
    state = state.copyWith(
      lastConnectionChannel: channel,
    );
  }
}
