import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vta_dart_client/vta_dart_client.dart';

import '../../../infrastructure/configuration/environment.dart';
import '../../../infrastructure/providers/app_logger_provider.dart';

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

class MicrosoftOneDriveAuthService {
  MicrosoftOneDriveAuthService(
    this._ref, {
    FlutterAppAuth? appAuth,
  }) : _appAuth = appAuth ?? const FlutterAppAuth();

  static const _logKey = 'ONEDRIVEAUTH';

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
      'Starting Microsoft OneDrive OAuth connection.',
      name: _logKey,
    );

    final clientId = _environment.microsoftOAuthClientId.trim();
    if (clientId.isEmpty) {
      _logger.error(
        'Microsoft OAuth client id is missing; cannot open authorization URL.',
        name: _logKey,
      );
      throw StateError(
        'MICROSOFT_OAUTH_CLIENT_ID must be configured to connect OneDrive.',
      );
    }

    final tenantId = _environment.microsoftOAuthTenantId.trim().isEmpty
        ? 'common'
        : _environment.microsoftOAuthTenantId.trim();
    final authorizationBase =
        'https://login.microsoftonline.com/$tenantId/oauth2/v2.0';

    _logger.info(
      'Opening Microsoft OAuth authorization session '
      '(tenant=$tenantId, clientId=${_redact(clientId)}, '
      'redirect=${_environment.microsoftOAuthRedirectUrl})',
      name: _logKey,
    );

    late final TokenResponse response;
    try {
      response = await _appAuth.authorizeAndExchangeCode(
        AuthorizationTokenRequest(
          clientId,
          _environment.microsoftOAuthRedirectUrl,
          serviceConfiguration: AuthorizationServiceConfiguration(
            authorizationEndpoint: '$authorizationBase/authorize',
            tokenEndpoint: '$authorizationBase/token',
          ),
          scopes: const [
            'openid',
            'profile',
            'offline_access',
            'User.Read',
            'Files.Read',
          ],
        ),
      );
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
      redirectUrl: _environment.microsoftOAuthRedirectUrl,
      scopes:
          response.scopes ??
          const [
            'openid',
            'profile',
            'offline_access',
            'User.Read',
            'Files.Read',
          ],
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

    final client = VtaClient(baseUrl: _environment.personalAiBaseUrl);
    final endpoint = _setupResourcePath(
      setupId,
      '/integrations/microsoft/onedrive',
    );
    _logger.info(
      'Storing OneDrive OAuth refresh token via personal AI endpoint '
      '(baseUrl=${_environment.personalAiBaseUrl}, endpoint=$endpoint, '
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
            'OneDrive OAuth storage endpoint was not found. '
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
        'Failed to store OneDrive OAuth refresh token '
        '(status=${error.statusCode}, body=$bodyForLog).',
        error: error,
        stackTrace: stackTrace,
        name: _logKey,
      );
      rethrow;
    } catch (error, stackTrace) {
      _logger.error(
        'Failed to store OneDrive OAuth refresh token.',
        error: error,
        stackTrace: stackTrace,
        name: _logKey,
      );
      rethrow;
    }

    _logger.info(
      'OneDrive OAuth refresh token stored successfully.',
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
}
