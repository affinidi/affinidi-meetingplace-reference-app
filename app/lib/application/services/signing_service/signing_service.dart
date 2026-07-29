import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:bip39_mnemonic/bip39_mnemonic.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:meeting_place_core/meeting_place_core.dart';
import 'package:meeting_place_vta_client/meeting_place_vta_client.dart';
import 'package:ssi/ssi.dart';

import '../../../domain/models/trust_task/trust_task_record.dart';
import '../../../infrastructure/configuration/environment.dart';
import '../../../infrastructure/loggers/app_logger/app_logger.dart';
import '../../../infrastructure/providers/app_logger_provider.dart';
import '../../../infrastructure/providers/meeting_place_sdk_provider.dart';
import '../../../infrastructure/providers/mnemonic_hash_provider.dart';
import '../../../infrastructure/vta/app_vta_auth_signer.dart';
import '../../../infrastructure/vta/authenticated_websocket_channel.dart';
import '../../../infrastructure/vta/mediator_auth_helper.dart';
import '../../../infrastructure/vta/plaintext_didcomm_packer.dart';

enum SigningServiceStatus { disconnected, connecting, connected, failed }

class PendingApproval {
  PendingApproval(this.approveRequest, this.completer);

  final Map<String, dynamic> approveRequest;
  final Completer<bool> completer;
}

class SigningServiceState {
  const SigningServiceState({
    this.status = SigningServiceStatus.disconnected,
    this.pendingApproval,
    this.errorMessage,
  });

  final SigningServiceStatus status;
  final PendingApproval? pendingApproval;
  final String? errorMessage;

  SigningServiceState copyWith({
    SigningServiceStatus? status,
    PendingApproval? Function()? pendingApproval,
    String? Function()? errorMessage,
  }) {
    return SigningServiceState(
      status: status ?? this.status,
      pendingApproval: pendingApproval != null
          ? pendingApproval()
          : this.pendingApproval,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
    );
  }
}

final signingServiceProvider =
    StateNotifierProvider<SigningService, SigningServiceState>(
      SigningService.new,
    );

class SigningService extends StateNotifier<SigningServiceState> {
  SigningService(this._ref) : super(const SigningServiceState()) {
    _logger = _ref.read(appLoggerProvider);
    unawaited(_initialize());
  }

  static const _logKey = 'SIGNSVC';

  final Ref _ref;
  late final AppLogger _logger;

  VtaAuthWorkflow? _authWorkflow;
  VtaClient? _vtaClient;
  VtaDidCommChannel? _channel;
  VtaMediatorSession? _mediatorSession;
  VtaStepUpApprovalCoordinator? _coordinator;
  VtaStepUpApprovalOperation? _approvalOp;

  static const _vtaKeyId = "m/44'/60'/0'/0'/0'";

  Future<void> _initialize() async {
    final env = _ref.read(environmentProvider);
    final vtaMediatorDid = env.vtaMediatorDid;

    final mnemonicData = await _ref.read(mnemonicHashProvider.future);
    final mnemonicHash = mnemonicData?.hash;
    final vtaBaseUrl = env.vtaBaseUrl(mnemonicHash ?? '');
    final vtaDid = env.vtaDid(mnemonicHash ?? '');

    if (vtaBaseUrl == null ||
        vtaBaseUrl.isEmpty ||
        vtaDid == null ||
        vtaDid.isEmpty ||
        vtaMediatorDid.isEmpty) {
      _logger.info(
        'VTA not configured '
        '(WALLET_CONFIG.vtaDid / WALLET_CONFIG.vtaBaseUrl / VTA_MEDIATOR_DID missing), '
        'skipping',
        name: _logKey,
      );
      return;
    }

    state = state.copyWith(status: SigningServiceStatus.connecting);

    try {
      final mnemonic = mnemonicData?.mnemonic;
      if (mnemonic == null || mnemonic.isEmpty) {
        _logger.warning('No mnemonic available', name: _logKey);
        state = state.copyWith(
          status: SigningServiceStatus.failed,
          errorMessage: () => 'No mnemonic available',
        );
        return;
      }

      final seed = Uint8List.fromList(
        Mnemonic.fromSentence(mnemonic, Language.english).seed,
      );
      final ed25519Wallet = Bip32Ed25519Wallet.fromSeed(seed);
      await ed25519Wallet.generateKey(keyId: _vtaKeyId);

      final didManager = DidKeyManager(
        store: InMemoryDidStore(),
        wallet: ed25519Wallet,
      );
      await didManager.addVerificationMethod(_vtaKeyId);
      final didDoc = await didManager.getDidDocument();
      final holderDid = didDoc.id;
      final verificationMethod =
          '$holderDid#${holderDid.substring('did:key:'.length)}';

      _logger.info('VTA holder DID (Ed25519): $holderDid', name: _logKey);

      final vtaClient = VtaClient(baseUrl: vtaBaseUrl);
      _vtaClient = vtaClient;
      final signer = AppVtaAuthSigner(
        wallet: ed25519Wallet,
        rootKeyId: _vtaKeyId,
        holderDid: holderDid,
        verificationMethod: verificationMethod,
      );
      final protocol = TrustTaskVtaAuthProtocol(signer: signer);
      _authWorkflow = VtaAuthWorkflow(
        client: vtaClient,
        holderDid: holderDid,
        vtaDid: vtaDid,
        protocol: protocol,
      );

      _logger.info('Authenticating with VTA...', name: _logKey);
      final authResult = await _authWorkflow!.connect();
      _logger.info('Authenticated, setting up mediator...', name: _logKey);

      final mediatorDidDoc = await UniversalDIDResolver().resolveDid(
        vtaMediatorDid,
      );
      final mediatorAccessToken = await MediatorAuthHelper.authenticate(
        mediatorDidDocument: mediatorDidDoc,
        didManager: didManager,
      );
      _logger.info('Mediator auth complete', name: _logKey);

      final wsUrl = _extractWebSocketUrl(mediatorDidDoc);
      if (wsUrl == null) {
        throw StateError('No WebSocket endpoint in mediator DID document');
      }
      final wsUri = Uri.parse(wsUrl);
      _logger.info('Connecting mediator at: $wsUri', name: _logKey);
      _channel = AuthenticatedWebSocketChannel(
        uri: wsUri,
        accessToken: mediatorAccessToken,
      );
      final adapter = VtaMediatorWireTransportAdapter(
        channel: _channel!,
        packer: PlaintextDidCommPacker(didManager: didManager),
        protocolConfig: const VtaMediatorProtocolConfig(
          enableHandshake: true,
          enablePickup: false,
          enableAck: false,
        ),
      );
      _mediatorSession = VtaMediatorSession(
        transport: adapter,
        expectedSenderDid: vtaDid,
      );
      await _mediatorSession!.connect();
      _logger.info('Mediator session connected', name: _logKey);

      final approvalOp = VtaStepUpApprovalOperation.withTokenProvider(
        client: vtaClient,
        holderDid: holderDid,
        vtaDid: vtaDid,
        signer: signer,
        tokenProvider: () => _authWorkflow!.getValidAccessToken(),
      );
      _approvalOp = approvalOp;

      _logger.info(
        'VTA TOKEN: ${authResult.tokens.accessToken}',
        name: _logKey,
      );

      // Coordinator disabled: approval is handled exclusively via the
      // chat-item path which sends cierge/stepUpApproved back to the
      // connector, triggering the agent retry.
      // _coordinator = VtaStepUpApprovalCoordinator(
      //   mediatorSession: _mediatorSession!,
      //   onApproveRequest: _handleApproveRequest,
      //   approvalOperation: approvalOp,
      // );
      // await _coordinator!.start();

      state = state.copyWith(status: SigningServiceStatus.connected);
      _logger.info(
        'Signing service connected (chat-item approval only)',
        name: _logKey,
      );
    } catch (e, s) {
      _logger.error(
        'Initialization failed',
        error: e,
        stackTrace: s,
        name: _logKey,
      );
      state = state.copyWith(
        status: SigningServiceStatus.failed,
        errorMessage: e.toString,
      );
    }
  }

  Future<void> handleRelayedApproveRequest(
    Map<String, dynamic> approveRequest, {
    required String mediatorDid,
  }) async {
    final payload =
        approveRequest['payload'] as Map<String, dynamic>? ?? approveRequest;

    _logger.info(
      'Relayed step-up approval: '
      'sessionId=${payload['sessionId']} '
      'challenge=${payload['challenge']} '
      'subject=${payload['subject']} '
      'holderDid=${_approvalOp?.holderDid} '
      'keys=${payload.keys.toList()}',
      name: _logKey,
    );

    if (_approvalOp == null) {
      _logger.warning(
        'Cannot approve: signing service not initialized',
        name: _logKey,
      );
      throw StateError('Signing service not initialized');
    }

    // The relayed approve-request's payload.subject is the agent's DID (the
    // caller whose VTA session needs elevation). VTA validates that
    // approve-response.payload.subject == pending.subject (agent's DID), so we
    // must NOT override it — pass it through as-is.
    _logger.info(
      'Submitting approve-response: '
      'issuer(phone)=${_approvalOp!.holderDid} '
      'subject(agent)=${payload['subject']} '
      'sessionId=${payload['sessionId']} '
      'challenge=${payload['challenge']}',
      name: _logKey,
    );

    try {
      await _approvalOp!.approve(approveRequest: payload);
      _logger.info('Relayed step-up approved and submitted', name: _logKey);
    } catch (e) {
      final msg = e.toString();
      if (msg.contains('challenge_unknown') ||
          msg.contains('challenge_expired')) {
        _logger.info(
          '''Relayed approval already consumed (likely approved via DIDComm coordinator): $msg''',
          name: _logKey,
        );
        return;
      }
      rethrow;
    }

    await _notifyAgentApproved(
      payload['sessionId'] as String?,
      challenge: payload['challenge'] as String?,
      mediatorDid: mediatorDid,
    );
  }

  Future<void> _notifyAgentApproved(
    String? sessionId, {
    required String mediatorDid,
    String? challenge,
  }) async {
    try {
      final sdk = await _ref.read(meetingPlaceSdkProvider.future);
      final env = _ref.read(environmentProvider);

      final mnemonicHash = (await _ref.read(mnemonicHashProvider.future))?.hash;
      if (mnemonicHash == null || mnemonicHash.isEmpty) {
        _logger.warning('Cannot notify agent: no mnemonic', name: _logKey);
        return;
      }
      final agentDid = env.ciergeConnectorDid(mnemonicHash);
      if (agentDid == null || agentDid.isEmpty) {
        _logger.warning(
          'Cannot notify agent: no ciergeConnectorDid in config',
          name: _logKey,
        );
        return;
      }

      final rootDid = sdk.rootDid;

      final body = {
        'text': jsonEncode({
          'type': 'cierge/stepUpApproved',
          'sessionId': sessionId,
          'challenge': ?challenge,
        }),
        'seq_no': 0,
        'timestamp': DateTime.now().toUtc().toIso8601String(),
      };

      final message = DidCommOutgoingMessage(
        senderDid: rootDid,
        recipientDid: agentDid,
        mediatorDid: mediatorDid,
        payload: PlainTextMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          type: Uri.parse(
            'https://affinidi.com/didcomm/protocols/meeting-place-chat/1.0/message',
          ),
          from: rootDid,
          to: [agentDid],
          body: body,
          createdTime: DateTime.now().toUtc(),
        ),
      );

      await sdk.sendMessage(message);
      _logger.info(
        'Notified agent via DIDComm: sessionId=$sessionId '
        'agentDid=$agentDid',
        name: _logKey,
      );
    } catch (e, s) {
      _logger.error(
        'Failed to notify agent of approval',
        error: e,
        stackTrace: s,
        name: _logKey,
      );
    }
  }

  Future<T> _withReauth<T>(Future<T> Function() action) async {
    try {
      final token = await _authWorkflow!.getValidAccessToken();
      _vtaClient!.setAuthToken(token);
      return await action();
    } on VtaAuthException {
      _logger.info('VTA session expired, reconnecting...', name: _logKey);
      await _authWorkflow!.reconnect();
      final newToken = await _authWorkflow!.getValidAccessToken();
      _vtaClient!.setAuthToken(newToken);
      return action();
    }
  }

  /// Fetches a page of trust-task (document/message signing) history from the
  /// VTA audit log. Captures both autonomous and step-up gated signings, and
  /// every outcome (success and denied), newest-first.
  ///
  /// Requires the app's VTA identity to hold an admin ACL role (the audit
  /// endpoint is admin-gated). Returns an empty page when VTA is not connected.
  Future<TrustTaskHistoryPage> fetchTrustTaskHistory({
    int page = 1,
    int pageSize = 20,
  }) async {
    if (_vtaClient == null || _authWorkflow == null) {
      return const TrustTaskHistoryPage.empty();
    }
    return _withReauth(() async {
      final result = await _vtaClient!.auditLog.listLogs(
        action: 'vault.sign-trust-task',
        page: page,
        pageSize: pageSize,
      );
      return TrustTaskHistoryPage.fromResponse(result);
    });
  }

  /// Returns raw VTA `vault.sign-trust-task` audit-log entries, used to resolve
  /// verification details for a specific signed document. Returns an empty list
  /// when the VTA client is not available.
  Future<List<Map<String, dynamic>>> getSigningAuditLogs({
    int page = 1,
    int pageSize = 100,
  }) async {
    if (_vtaClient == null || _authWorkflow == null) {
      return const [];
    }
    return _withReauth(() async {
      final result = await _vtaClient!.auditLog.listLogs(
        action: 'vault.sign-trust-task',
        page: page,
        pageSize: pageSize,
      );
      final entries = (result['entries'] as List?) ?? const [];
      return entries
          .whereType<Map>()
          .map((e) => e.cast<String, dynamic>())
          .toList(growable: false);
    });
  }

  void approveCurrentRequest() {
    final pending = state.pendingApproval;
    if (pending != null && !pending.completer.isCompleted) {
      pending.completer.complete(true);
    }
  }

  void rejectCurrentRequest() {
    final pending = state.pendingApproval;
    if (pending != null && !pending.completer.isCompleted) {
      pending.completer.complete(false);
    }
  }

  static String? _extractWebSocketUrl(DidDocument doc) {
    for (final service in doc.service) {
      final url = _findWsInEndpointValue(service.serviceEndpoint);
      if (url != null) return url;
    }
    return null;
  }

  static String? _findWsInEndpointValue(ServiceEndpointValue value) {
    switch (value) {
      case StringEndpoint(:final url):
        if (url.startsWith('ws://') || url.startsWith('wss://')) return url;
      case MapEndpoint(:final data):
        final uri = data['uri'];
        if (uri is String &&
            (uri.startsWith('ws://') || uri.startsWith('wss://'))) {
          return uri;
        }
      case SetEndpoint(:final endpoints):
        for (final ep in endpoints) {
          final url = _findWsInEndpointValue(ep);
          if (url != null) return url;
        }
    }
    return null;
  }

  Future<bool> getStepUpEnabled() async {
    if (_vtaClient == null || _authWorkflow == null) return false;
    return _withReauth(() async {
      final policy = await _vtaClient!.stepUpPolicy.getPolicy();
      return policy['enabled'] as bool? ?? false;
    });
  }

  Future<void> setStepUpEnabled(bool enabled) async {
    if (_vtaClient == null || _authWorkflow == null) {
      throw StateError('VTA not connected');
    }
    await _withReauth(() async {
      await _vtaClient!.stepUpPolicy.setPolicy(
        enabled: enabled,
        floors: enabled
            ? [
                {'operation': 'vault/sign-trust-task', 'mode': 'delegated'},
              ]
            : [],
      );
    });
  }

  @override
  void dispose() {
    final pending = state.pendingApproval;
    if (pending != null && !pending.completer.isCompleted) {
      pending.completer.complete(false);
    }
    _coordinator?.dispose();
    _mediatorSession?.dispose();
    _channel?.disconnect();
    _authWorkflow?.disconnect();
    super.dispose();
  }
}
