import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:aws_common/aws_common.dart' as aws_common;

class AwsAmplifyBootstrap {
  AwsAmplifyBootstrap._();

  static var _configured = false;

  static Future<void> ensureConfigured({
    required String identityPoolId,
    required String region,
  }) async {
    if (_configured) return;

    if (identityPoolId.isEmpty || region.isEmpty) {
      throw const AwsLivenessConfigurationException(
        'Missing AWS_REGION or AWS_IDENTITY_POOL_ID.',
      );
    }

    try {
      try {
        await Amplify.addPlugin(AmplifyAuthCognito());
      } on Exception {}
      await Amplify.configure(_buildConfig(identityPoolId, region));
      _configured = true;
    } on AmplifyAlreadyConfiguredException {
      _configured = true;
    }
  }

  static Future<aws_common.AWSCredentials> fetchCredentials() async {
    final session = await Amplify.Auth.fetchAuthSession() as CognitoAuthSession;
    final credentials = session.credentialsResult.value;
    return aws_common.AWSCredentials(
      credentials.accessKeyId,
      credentials.secretAccessKey,
      credentials.sessionToken,
    );
  }

  static String _buildConfig(String identityPoolId, String region) {
    return '''
{
  "auth": {
    "plugins": {
      "awsCognitoAuthPlugin": {
        "IdentityManager": {
          "Default": {}
        },
        "CredentialsProvider": {
          "CognitoIdentity": {
            "Default": {
              "PoolId": "$identityPoolId",
              "Region": "$region"
            }
          }
        },
        "CognitoIdentity": {
          "Default": {
            "PoolId": "$identityPoolId",
            "Region": "$region"
          }
        }
      }
    }
  }
}
''';
  }
}

class AwsLivenessConfigurationException implements Exception {
  const AwsLivenessConfigurationException(this.message);

  final String message;

  @override
  String toString() => message;
}
