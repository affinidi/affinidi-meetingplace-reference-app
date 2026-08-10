import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meeting_place_vta_client/meeting_place_vta_client.dart';

import '../../../infrastructure/configuration/environment.dart';
import '../../../infrastructure/providers/app_logger_provider.dart';
import '../../../infrastructure/providers/mnemonic_hash_provider.dart';

final microsoftOneDriveAuthServiceProvider =
    Provider<MicrosoftOneDriveAuthService>(MicrosoftOneDriveAuthService.new);

class MicrosoftOneDriveOAuthResult {
  const MicrosoftOneDriveOAuthResult({
    required this.accessToken,
    required this.refreshToken,
    required this.clientId,
    required this.tenantId,
    required this.redirectUrl,
    required this.scopes,
    this.tokenType,
    this.accessTokenExpirationDateTime,
  });

  final String accessToken;
  final String refreshToken;
  final String clientId;
  final String tenantId;
  final String redirectUrl;
  final List<String> scopes;
  final String? tokenType;
  final DateTime? accessTokenExpirationDateTime;
}

class MicrosoftOneDriveAuthCancelledException implements Exception {
  const MicrosoftOneDriveAuthCancelledException();
}

class MicrosoftOneDriveAuthService {
  MicrosoftOneDriveAuthService(this._ref, {FlutterAppAuth? appAuth})
    : _appAuth = appAuth ?? const FlutterAppAuth();

  static const _logKey = 'MICROSOFT365AUTH';

  final Ref _ref;
  final FlutterAppAuth _appAuth;

  Environment get _environment => _ref.read(environmentProvider);
  late final _logger = _ref.read(appLoggerProvider);

  Future<void> connectAndStore({
    required String setupId,
    required String holderDid,
  }) async {
    final oauthResult = await authorize();
    await storeConnection(
      setupId: setupId,
      holderDid: holderDid,
      oauthResult: oauthResult,
    );
  }

  Future<MicrosoftOneDriveOAuthResult> authorize() async {
    _logger.info(
      'Starting Microsoft 365 OAuth connection for Work AI.',
      name: _logKey,
    );

    final clientId = _environment.agentStreamOAuthClientId.trim();
    if (clientId.isEmpty) {
      _logger.error('Agent Stream OAuth client id is missing', name: _logKey);
      throw StateError('AGENT_STREAM_OAUTH_CLIENT_ID must be configured');
    }

    final tenantId = _environment.agentStreamOAuthTenantId.trim().isEmpty
        ? 'common'
        : _environment.agentStreamOAuthTenantId.trim();
    final authorizationBase =
        'https://login.microsoftonline.com/$tenantId/oauth2/v2.0';
    final scopes = _agentStreamScopes(_environment.agentStreamOAuthScopes);
    if (scopes.isEmpty) {
      _logger.error(
        'Microsoft OAuth scopes do not include Microsoft Graph Copilot scopes.',
        name: _logKey,
      );
      throw StateError(
        'AGENT_STREAM_OAUTH_SCOPES must include Microsoft Copilot scopes.',
      );
    }

    _logger.info(
      'Opening Agent Stream OAuth authorization session '
      '(tenant=$tenantId, clientId=${_redact(clientId)}, '
      'redirect=${_environment.agentStreamOAuthRedirectUrl},'
      'scopes=${scopes.join(' ')})',
      name: _logKey,
    );

    late final TokenResponse response;
    try {
      response = await _appAuth.authorizeAndExchangeCode(
        AuthorizationTokenRequest(
          clientId,
          _environment.agentStreamOAuthRedirectUrl,
          serviceConfiguration: AuthorizationServiceConfiguration(
            authorizationEndpoint: '$authorizationBase/authorize',
            tokenEndpoint: '$authorizationBase/token',
          ),
          scopes: scopes,
        ),
      );
    } on FlutterAppAuthUserCancelledException {
      _logger.info(
        'Microsoft OAuth authorization session was cancelled by the user.',
        name: _logKey,
      );
      throw const MicrosoftOneDriveAuthCancelledException();
    } catch (error, stackTrace) {
      _logger.error(
        'Microsoft OAuth authorization session failed.',
        error: error,
        stackTrace: stackTrace,
        name: _logKey,
      );
      rethrow;
    }

    final accessTokenExpiresAt =
        response.accessTokenExpirationDateTime?.toUtc().toIso8601String() ??
        'unknown';

    _logger.info(
      'Microsoft OAuth token exchange completed '
      '(hasAccessToken=${response.accessToken?.isNotEmpty == true}, '
      'hasRefreshToken=${response.refreshToken?.isNotEmpty == true}, '
      'expiresAt=$accessTokenExpiresAt)',
      name: _logKey,
    );

    final refreshToken = response.refreshToken?.trim();
    if (refreshToken == null || refreshToken.isEmpty) {
      _logger.error(
        'Microsoft OAuth completed without a refresh token.',
        name: _logKey,
      );
      throw StateError('Microsoft did not return a refresh token.');
    }

    final accessToken = response.accessToken?.trim();
    if (accessToken == null || accessToken.isEmpty) {
      _logger.error(
        'Microsoft OAuth completed without an access token.',
        name: _logKey,
      );
      throw StateError('Microsoft did not return an access token.');
    }

    return MicrosoftOneDriveOAuthResult(
      accessToken: accessToken,
      refreshToken: refreshToken,
      clientId: clientId,
      tenantId: tenantId,
      redirectUrl: _environment.agentStreamOAuthRedirectUrl,
      scopes: response.scopes ?? scopes,
      tokenType: response.tokenType,
      accessTokenExpirationDateTime: response.accessTokenExpirationDateTime,
    );
  }

  Future<void> storeConnection({
    required String setupId,
    required String holderDid,
    required MicrosoftOneDriveOAuthResult oauthResult,
  }) async {
    final normalizedSetupId = setupId.trim();
    final normalizedHolderDid = holderDid.trim();
    final mnemonicHash = (await _ref.read(mnemonicHashProvider.future))?.hash;
    if (mnemonicHash == null) {
      _logger.error(
        '''Cannot store Microsoft 365 OAuth refresh token: mnemonic hash is not configured.''',
        name: _logKey,
      );
      throw StateError('Mnemonic hash is not configured.');
    }
    final personalAiBaseUrl = _environment.personalAiBaseUrl(mnemonicHash);
    if (personalAiBaseUrl == null || personalAiBaseUrl.trim().isEmpty) {
      _logger.error(
        '''Cannot store Microsoft 365 OAuth refresh token: personal AI base URL is not configured for mnemonic hash $mnemonicHash.''',
        name: _logKey,
      );
      throw StateError(
        'Personal AI base URL is not configured for this wallet. '
        'Check that WALLET_CONFIG has a non-empty ciergeConsoleUrl for '
        'mnemonic hash $mnemonicHash.',
      );
    }

    final client = VtaClient(baseUrl: personalAiBaseUrl);
    final endpoint = _setupResourcePath(
      setupId,
      '/integrations/microsoft/onedrive',
    );
    _logger.info(
      'Storing Microsoft 365 OAuth refresh token via personal AI endpoint '
      '(baseUrl=$personalAiBaseUrl, endpoint=$endpoint, '
      'setupId=${_redact(normalizedSetupId)}, '
      'holderDid=${_redact(normalizedHolderDid)})',
      name: _logKey,
    );

    try {
      await client.postJson(
        endpoint,
        body: <String, dynamic>{
          'holder_did': normalizedHolderDid,
          'context_key': 'ctx-0',
          'refresh_token': oauthResult.refreshToken,
          'client_id': oauthResult.clientId,
          'tenant_id': oauthResult.tenantId,
          'redirect_url': oauthResult.redirectUrl,
          'scopes': oauthResult.scopes,
          if (oauthResult.tokenType != null)
            'token_type': oauthResult.tokenType,
          if (oauthResult.accessTokenExpirationDateTime != null)
            'access_token_expires_at': oauthResult
                .accessTokenExpirationDateTime!
                .toUtc()
                .toIso8601String(),
        },
      );
    } on VtaClientException catch (error, stackTrace) {
      final body = error.body?.trim() ?? '';
      if (error.statusCode == 404 && body.isEmpty) {
        final message =
            'Microsoft 365 OAuth storage endpoint was not found. '
            'Restart the Personal AI/Cierge backend so it includes '
            '$endpoint.';
        _logger.error(
          message,
          error: error,
          stackTrace: stackTrace,
          name: _logKey,
        );
        throw StateError(message);
      }

      final bodyForLog = body.isEmpty ? '(empty)' : body;
      _logger.error(
        'Failed to store Microsoft 365 OAuth refresh token '
        '(status=${error.statusCode}, body=$bodyForLog).',
        error: error,
        stackTrace: stackTrace,
        name: _logKey,
      );
      rethrow;
    } catch (error, stackTrace) {
      _logger.error(
        'Failed to store Microsoft 365 OAuth refresh token.',
        error: error,
        stackTrace: stackTrace,
        name: _logKey,
      );
      rethrow;
    }

    _logger.info(
      'Microsoft 365 OAuth refresh token stored successfully.',
      name: _logKey,
    );
  }

  String _setupResourcePath(String setupId, String suffix) {
    final encodedSetupId = Uri.encodeComponent(setupId.trim());
    final endpoint = _environment.personalAiSetupEndpoint;
    final setupBase = endpoint.endsWith('/setup')
        ? endpoint
        : '$endpoint/setup';
    return '$setupBase/$encodedSetupId$suffix';
  }

  String _redact(String value) {
    if (value.isEmpty) return '(empty)';
    if (value.length <= 12) return '${value.substring(0, 3)}...';
    return '${value.substring(0, 8)}...${value.substring(value.length - 4)}';
  }

  List<String> _agentStreamScopes(List<String> configuredScopes) {
    const graphScopeSuffixes = {
      'Sites.Read.All',
      'Mail.Read',
      'People.Read.All',
      'OnlineMeetingTranscript.Read.All',
      'Chat.Read',
      'ChannelMessage.Read.All',
      'ExternalItem.Read.All',
    };
    final filtered = <String>[];
    for (final scope in configuredScopes) {
      final trimmed = scope.trim();
      if (trimmed.isEmpty) continue;
      if (trimmed == 'offline_access' ||
          graphScopeSuffixes.any(
            (suffix) => trimmed == suffix || trimmed.endsWith('/$suffix'),
          )) {
        filtered.add(trimmed);
      }
    }
    return filtered.toSet().toList(growable: false);
  }
}
