import 'dart:async';
import 'dart:typed_data';

import 'package:bip39_mnemonic/bip39_mnemonic.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:ssi/ssi.dart';
import 'package:vta_dart_client/vta_dart_client.dart';

import '../../../infrastructure/configuration/environment.dart';
import '../../../infrastructure/loggers/app_logger/app_logger.dart';
import '../../../infrastructure/providers/app_logger_provider.dart';
import '../../../infrastructure/secure_storage/secure_storage.dart';
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
      pendingApproval:
          pendingApproval != null ? pendingApproval() : this.pendingApproval,
      errorMessage:
          errorMessage != null ? errorMessage() : this.errorMessage,
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
  VtaDidCommChannel? _channel;
  VtaMediatorSession? _mediatorSession;
  VtaStepUpApprovalCoordinator? _coordinator;

  static const _vtaKeyId = "m/44'/60'/0'/0'/0'";

  Future<void> _initialize() async {
    final env = _ref.read(environmentProvider);
    final vtaBaseUrl = env.vtaBaseUrl;
    final vtaDid = env.vtaDid;
    final vtaMediatorDid = env.vtaMediatorDid;

    if (vtaBaseUrl.isEmpty ||
        vtaDid.isEmpty ||
        vtaMediatorDid.isEmpty) {
      _logger.info(
        'VTA not configured '
        '(VTA_BASE_URL / VTA_DID / VTA_MEDIATOR_DID missing), '
        'skipping',
        name: _logKey,
      );
      return;
    }

    state = state.copyWith(status: SigningServiceStatus.connecting);

    try {
      final secureStorage =
          await _ref.read(secureStorageProvider.future);
      final mnemonic = await secureStorage.getMnemonic();
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

      _logger.info(
        'VTA holder DID (Ed25519): $holderDid',
        name: _logKey,
      );

      final vtaClient = VtaClient(baseUrl: vtaBaseUrl);
      final signer = AppVtaAuthSigner(
        wallet: ed25519Wallet,
        rootKeyId: _vtaKeyId,
        holderDid: holderDid,
        verificationMethod: verificationMethod,
      );
      final protocol =
          TrustTaskVtaAuthProtocol(signer: signer);
      _authWorkflow = VtaAuthWorkflow(
        client: vtaClient,
        holderDid: holderDid,
        vtaDid: vtaDid,
        protocol: protocol,
      );

      _logger.info('Authenticating with VTA...', name: _logKey);
      final authResult = await _authWorkflow!.connect();
      _logger.info(
        'Authenticated, setting up mediator...',
        name: _logKey,
      );

      final mediatorDidDoc = DidPeer.resolve(vtaMediatorDid);
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
          enableHandshake: false,
          enablePickup: false,
          enableAck: false,
        ),
      );
      _mediatorSession = VtaMediatorSession(
        transport: adapter,
        expectedSenderDid: vtaDid,
      );
      await _mediatorSession!.connect();
      _logger.info(
        'Mediator session connected',
        name: _logKey,
      );

      final approvalOp =
          VtaStepUpApprovalOperation.forClient(
        client: vtaClient,
        holderDid: holderDid,
        vtaDid: vtaDid,
        signer: signer,
        accessToken: authResult.tokens.accessToken,
      );

      _coordinator = VtaStepUpApprovalCoordinator(
        mediatorSession: _mediatorSession!,
        onApproveRequest: _handleApproveRequest,
        approvalOperation: approvalOp,
      );
      await _coordinator!.start();

      state = state.copyWith(
        status: SigningServiceStatus.connected,
      );
      _logger.info(
        'Step-up coordinator started',
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

  Future<VtaStepUpApprovalDecision> _handleApproveRequest(
    Map<String, dynamic> approveRequest,
    VtaDidCommMessage message,
  ) async {
    _logger.info(
      'Step-up approval request received: '
      'sessionId=${approveRequest['sessionId']}',
      name: _logKey,
    );

    final completer = Completer<bool>();
    state = state.copyWith(
      pendingApproval: () =>
          PendingApproval(approveRequest, completer),
    );

    final approved = await completer.future;
    state = state.copyWith(pendingApproval: () => null);

    _logger.info(
      'Step-up decision: '
      '${approved ? 'approved' : 'rejected'}',
      name: _logKey,
    );
    return VtaStepUpApprovalDecision(approved: approved);
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
