import 'package:face_liveness_detector/face_liveness_detector.dart';
import 'package:flutter/material.dart';

import '../../../application/services/credential_service/aws_amplify_bootstrap.dart';
import '../../../application/services/credential_service/aws_rekognition_liveness_client.dart';

enum _AwsLivenessStep { preparing, challenge, fetchingResults, error }

class AwsFaceLivenessFlowScreen extends StatefulWidget {
  const AwsFaceLivenessFlowScreen({
    required this.region,
    required this.identityPoolId,
    required this.threshold,
    super.key,
  });

  final String region;
  final String identityPoolId;
  final double threshold;

  @override
  State<AwsFaceLivenessFlowScreen> createState() =>
      _AwsFaceLivenessFlowScreenState();
}

class _AwsFaceLivenessFlowScreenState extends State<AwsFaceLivenessFlowScreen> {
  _AwsLivenessStep _step = _AwsLivenessStep.preparing;
  String? _sessionId;
  String? _errorMessage;

  late final AwsRekognitionLivenessClient _livenessClient =
      AwsRekognitionLivenessClient(
        region: widget.region,
        identityPoolId: widget.identityPoolId,
        threshold: widget.threshold,
      );

  @override
  void initState() {
    super.initState();
    _prepareSession();
  }

  Future<void> _prepareSession() async {
    setState(() {
      _step = _AwsLivenessStep.preparing;
      _errorMessage = null;
    });

    try {
      final sessionId = await _livenessClient.createSession();
      if (!mounted) return;
      setState(() {
        _sessionId = sessionId;
        _step = _AwsLivenessStep.challenge;
      });
    } on AwsLivenessConfigurationException catch (error) {
      _showError(error.message);
    } catch (error) {
      _showError('Failed to start AWS liveness session: $error');
    }
  }

  Future<void> _onLivenessComplete() async {
    final sessionId = _sessionId;
    if (sessionId == null) {
      _showError('Missing AWS liveness session id.');
      return;
    }

    setState(() => _step = _AwsLivenessStep.fetchingResults);

    try {
      final evidence = await _livenessClient.fetchEvidence(
        sessionId: sessionId,
      );
      if (!mounted) return;
      Navigator.of(context).pop(evidence);
    } on AwsLivenessConfigurationException catch (error) {
      _showError(error.message);
    } catch (error) {
      _showError('Failed to fetch AWS liveness results: $error');
    }
  }

  void _onLivenessError(String code) {
    _showError('AWS liveness check failed ($code).');
  }

  void _showError(String message) {
    if (!mounted) return;
    setState(() {
      _step = _AwsLivenessStep.error;
      _errorMessage = message;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AWS Face Liveness')),
      body: switch (_step) {
        _AwsLivenessStep.preparing => const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Starting AWS liveness session...'),
            ],
          ),
        ),
        _AwsLivenessStep.challenge => FaceLivenessDetector(
          sessionId: _sessionId!,
          region: widget.region,
          onComplete: _onLivenessComplete,
          onError: _onLivenessError,
        ),
        _AwsLivenessStep.fetchingResults => const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Fetching liveness results...'),
            ],
          ),
        ),
        _AwsLivenessStep.error => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _errorMessage ?? 'AWS liveness failed.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: _prepareSession,
                  child: const Text('Retry'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
              ],
            ),
          ),
        ),
      },
    );
  }
}
