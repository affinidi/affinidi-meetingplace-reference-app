import 'dart:convert';

import 'package:aws_common/aws_common.dart';
import 'package:aws_signature_v4/aws_signature_v4.dart';

import 'aws_amplify_bootstrap.dart';
import 'liveness_evidence_source.dart';

class AwsRekognitionLivenessClient {
  AwsRekognitionLivenessClient({
    required this.region,
    required this.identityPoolId,
    required this.threshold,
  });

  final String region;
  final String identityPoolId;
  final double threshold;

  static const _providerId = 'aws_rekognition';

  Future<String> createSession() async {
    await AwsAmplifyBootstrap.ensureConfigured(
      identityPoolId: identityPoolId,
      region: region,
    );
    final credentials = await AwsAmplifyBootstrap.fetchCredentials();
    final response = await _invoke(
      credentials: credentials,
      target: 'RekognitionService.CreateFaceLivenessSession',
      body: const <String, Object?>{},
    );
    final sessionId = response['SessionId'];
    if (sessionId is! String || sessionId.isEmpty) {
      throw const AwsLivenessConfigurationException(
        'CreateFaceLivenessSession did not return a SessionId.',
      );
    }
    return sessionId;
  }

  Future<LivenessEvidence> fetchEvidence({required String sessionId}) async {
    await AwsAmplifyBootstrap.ensureConfigured(
      identityPoolId: identityPoolId,
      region: region,
    );
    final credentials = await AwsAmplifyBootstrap.fetchCredentials();
    final response = await _invoke(
      credentials: credentials,
      target: 'RekognitionService.GetFaceLivenessSessionResults',
      body: {'SessionId': sessionId},
    );

    final status = response['Status']?.toString();
    if (status != 'SUCCEEDED') {
      throw AwsLivenessConfigurationException(
        'Face liveness session did not succeed '
        '(status: ${status ?? 'unknown'}).',
      );
    }

    final confidence = response['Confidence'];
    final score = switch (confidence) {
      final num value => value.toDouble(),
      _ => throw const AwsLivenessConfigurationException(
        'Face liveness response did not include Confidence.',
      ),
    };

    return LivenessEvidence(
      providerId: _providerId,
      providerTransactionId: sessionId,
      livenessScore: score,
      livenessThreshold: threshold,
      checkedAt: DateTime.now().toUtc(),
    );
  }

  Future<Map<String, Object?>> _invoke({
    required AWSCredentials credentials,
    required String target,
    required Map<String, Object?> body,
  }) async {
    final encodedBody = jsonEncode(body);
    final bodyBytes = utf8.encode(encodedBody);
    final host = 'rekognition.$region.amazonaws.com';

    final request = AWSHttpRequest.post(
      Uri.https(host, '/'),
      body: bodyBytes,
      headers: {
        AWSHeaders.host: host,
        AWSHeaders.contentType: 'application/x-amz-json-1.1',
        AWSHeaders.contentLength: bodyBytes.length.toString(),
        'X-Amz-Target': target,
      },
    );

    final signer = AWSSigV4Signer(
      credentialsProvider: AWSCredentialsProvider(credentials),
    );
    final signedRequest = await signer.sign(
      request,
      credentialScope: AWSCredentialScope(
        region: region,
        service: AWSService.rekognition,
      ),
    );

    final response = await signedRequest.send().response;
    final responseBody = await response.decodeBody();
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw AwsLivenessConfigurationException(
        'Rekognition API failed ($target): '
        'HTTP ${response.statusCode} $responseBody',
      );
    }

    final decoded = jsonDecode(responseBody);
    if (decoded is! Map) {
      throw AwsLivenessConfigurationException(
        'Unexpected Rekognition response for $target.',
      );
    }
    return Map<String, Object?>.from(decoded);
  }
}
