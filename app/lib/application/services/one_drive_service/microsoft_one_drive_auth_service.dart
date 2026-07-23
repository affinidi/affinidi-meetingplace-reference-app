import 'dart:convert';
import 'dart:io';

import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meeting_place_vta_client/meeting_place_vta_client.dart';

import '../../../infrastructure/configuration/environment.dart';
import '../../../infrastructure/providers/app_logger_provider.dart';

final microsoftOneDriveAuthServiceProvider =
    Provider<MicrosoftOneDriveAuthService>(MicrosoftOneDriveAuthService.new);

class OneDriveContextImportResult {
  const OneDriveContextImportResult({
    required this.content,
    required this.importedFileCount,
    required this.skippedFileCount,
  });

  final String content;
  final int importedFileCount;
  final int skippedFileCount;

  bool get hasContent => content.trim().isNotEmpty;
}

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
    HttpClient? httpClient,
  }) : _appAuth = appAuth ?? const FlutterAppAuth(),
       _httpClient = httpClient ?? HttpClient();

  static const _logKey = 'ONEDRIVEAUTH';
  static const _graphBaseUrl = 'https://graph.microsoft.com/v1.0';
  static const _maxImportedFiles = 20;
  static const _maxDownloadedBytesPerFile = 256 * 1024;

  final Ref _ref;
  final FlutterAppAuth _appAuth;
  final HttpClient _httpClient;

  Environment get _environment => _ref.read(environmentProvider);
  late final _logger = _ref.read(appLoggerProvider);

  Future<OneDriveContextImportResult> connectStoreAndImport({
    required String setupId,
    required String holderDid,
  }) async {
    final oauthResult = await authorize();
    return storeAndImport(
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

  Future<OneDriveContextImportResult> storeAndImport({
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

    return _importOneDriveContext(accessToken: oauthResult.accessToken);
  }

  Future<OneDriveContextImportResult> _importOneDriveContext({
    required String accessToken,
  }) async {
    _logger.info(
      'Starting OneDrive context import from Microsoft Graph.',
      name: _logKey,
    );

    final imported = <_OneDriveImportedFile>[];
    var skipped = 0;

    Future<void> visitChildren(String? parentId, {required int depth}) async {
      if (depth > 4 || imported.length >= _maxImportedFiles) {
        return;
      }

      final uri = parentId == null
          ? Uri.parse('$_graphBaseUrl/me/drive/root/children').replace(
              queryParameters: const <String, String>{
                r'$select': 'id,name,file,folder,size',
                r'$top': '50',
              },
            )
          : Uri.parse(
              '$_graphBaseUrl/me/drive/items/$parentId/children',
            ).replace(
              queryParameters: const <String, String>{
                r'$select': 'id,name,file,folder,size',
                r'$top': '50',
              },
            );

      final json = await _getGraphJson(accessToken: accessToken, uri: uri);
      final items = json['value'];
      if (items is! List) {
        return;
      }

      for (final item in items.whereType<Map<String, dynamic>>()) {
        if (imported.length >= _maxImportedFiles) {
          return;
        }

        final id = (item['id'] as String?)?.trim();
        final name = (item['name'] as String?)?.trim() ?? 'untitled';
        if (id == null || id.isEmpty) {
          skipped++;
          continue;
        }

        if (item['folder'] is Map<String, dynamic>) {
          await visitChildren(id, depth: depth + 1);
          continue;
        }

        if (!_isSupportedTextFile(name)) {
          skipped++;
          continue;
        }

        final size = item['size'];
        if (size is num && size > _maxDownloadedBytesPerFile) {
          skipped++;
          continue;
        }

        try {
          final text = await _downloadTextFile(
            accessToken: accessToken,
            itemId: id,
          );
          if (text.trim().isEmpty) {
            skipped++;
            continue;
          }
          imported.add(_OneDriveImportedFile(name: name, text: text));
          _logger.info(
            'Imported OneDrive file for Work AI context (name=$name).',
            name: _logKey,
          );
        } catch (error, stackTrace) {
          skipped++;
          _logger.warning(
            'Skipping OneDrive file after download failure '
            '(name=$name, error=$error).',
            name: _logKey,
          );
          _logger.debug(stackTrace.toString(), name: _logKey);
        }
      }
    }

    await visitChildren(null, depth: 0);

    final content = _renderImportedContext(imported);
    _logger.info(
      'Completed OneDrive context import '
      '(imported=${imported.length}, skipped=$skipped).',
      name: _logKey,
    );

    return OneDriveContextImportResult(
      content: content,
      importedFileCount: imported.length,
      skippedFileCount: skipped,
    );
  }

  Future<Map<String, dynamic>> _getGraphJson({
    required String accessToken,
    required Uri uri,
  }) async {
    final request = await _httpClient.getUrl(uri);
    request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $accessToken');
    request.headers.set(HttpHeaders.acceptHeader, 'application/json');

    final response = await request.close();
    final body = await response.transform(utf8.decoder).join();
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw StateError(
        'Microsoft Graph request failed with status ${response.statusCode}: '
        '$body',
      );
    }

    final decoded = jsonDecode(body);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }
    throw StateError('Microsoft Graph returned an unexpected JSON shape.');
  }

  Future<String> _downloadTextFile({
    required String accessToken,
    required String itemId,
  }) async {
    final uri = Uri.parse('$_graphBaseUrl/me/drive/items/$itemId/content');
    final request = await _httpClient.getUrl(uri);
    request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $accessToken');

    final response = await request.close();
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final body = await response.transform(utf8.decoder).join();
      throw StateError(
        'Microsoft Graph content request failed with status '
        '${response.statusCode}: $body',
      );
    }

    final bytes = <int>[];
    await for (final chunk in response) {
      bytes.addAll(chunk);
      if (bytes.length > _maxDownloadedBytesPerFile) {
        throw StateError('OneDrive file exceeds import size limit.');
      }
    }
    return utf8.decode(bytes, allowMalformed: true);
  }

  bool _isSupportedTextFile(String name) {
    final lower = name.toLowerCase();
    return lower.endsWith('.txt') ||
        lower.endsWith('.md') ||
        lower.endsWith('.markdown') ||
        lower.endsWith('.csv') ||
        lower.endsWith('.json') ||
        lower.endsWith('.yaml') ||
        lower.endsWith('.yml') ||
        lower.endsWith('.log');
  }

  String _renderImportedContext(List<_OneDriveImportedFile> files) {
    if (files.isEmpty) {
      return '';
    }

    final buffer = StringBuffer()
      ..writeln('Imported OneDrive work context.')
      ..writeln('Imported files: ${files.length}')
      ..writeln();

    for (final file in files) {
      buffer
        ..writeln('--- OneDrive file: ${file.name} ---')
        ..writeln(file.text.trim())
        ..writeln();
    }

    return buffer.toString().trim();
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

class _OneDriveImportedFile {
  const _OneDriveImportedFile({required this.name, required this.text});

  final String name;
  final String text;
}
