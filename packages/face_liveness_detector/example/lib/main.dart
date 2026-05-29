import 'package:flutter/material.dart';
import 'package:face_liveness_detector/face_liveness_detector.dart';
import 'aws_services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Face Liveness Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const FaceLivenessScreen(),
    );
  }
}

class FaceLivenessScreen extends StatefulWidget {
  const FaceLivenessScreen({super.key});

  @override
  State<FaceLivenessScreen> createState() => _FaceLivenessScreenState();
}

class _FaceLivenessScreenState extends State<FaceLivenessScreen> {
  bool _isLoading = false;
  String _sessionId = '';
  String _region = '';
  String _status = 'Press the button to start face liveness check';
  bool _showResults = false;
  Map<String, dynamic> _results = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Face Liveness Example'),
      ),
      body: _showResults
          ? _buildResultsView()
          : _isLoading
              ? _buildLoadingView()
              : _sessionId.isEmpty
                  ? _buildStartView()
                  : _buildLivenessDetectorView(),
    );
  }

  Widget _buildStartView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(_status),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _startLivenessCheck,
            child: const Text('Start Liveness Check'),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 20),
          Text(_status),
        ],
      ),
    );
  }

  Widget _buildLivenessDetectorView() {
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: FaceLivenessDetector(
        sessionId: _sessionId,
        region: _region,
        onComplete: _onLivenessComplete,
        onError: _onLivenessError,
      ),
    );
  }

  Widget _buildResultsView() {
    final isVerified = _results['verified'] == true;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isVerified ? Icons.check_circle_outline : Icons.error_outline,
            color: isVerified ? Colors.green : Colors.red,
            size: 80,
          ),
          const SizedBox(height: 20),
          Text(
            isVerified ? 'Face liveness verified!' : 'Face liveness failed',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 40),
          if (_results.containsKey('confidence')) ...[
            Text(
                'Confidence: ${(_results['confidence'] * 100).toStringAsFixed(2)}%'),
            const SizedBox(height: 10),
          ],
          ElevatedButton(
            onPressed: () {
              setState(() {
                _sessionId = '';
                _showResults = false;
                _results = {};
                _status = 'Press the button to start face liveness check';
              });
            },
            child: const Text('Start Again'),
          ),
        ],
      ),
    );
  }

  Future<void> _startLivenessCheck() async {
    setState(() {
      _isLoading = true;
      _status = 'Getting session from backend...';
    });

    try {
      final session = await AwsServices.getSessionFromBackend();
      if (session.isEmpty ||
          session['sessionId'] == null ||
          session['sessionId']!.isEmpty) {
        throw Exception('Failed to get valid session');
      }

      setState(() {
        _sessionId = session['sessionId']!;
        _region = session['region'] ?? 'us-east-1';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _status = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _onLivenessComplete() async {
    setState(() {
      _isLoading = true;
      _status = 'Fetching results...';
    });

    try {
      final results =
          await AwsServices.fetchLivenessResults(sessionId: _sessionId);
      setState(() {
        _results = results;
        _showResults = true;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _status = 'Error: $e';
        _isLoading = false;
        _sessionId = '';
      });
    }
  }

  void _onLivenessError(String code) {
    setState(() {
      _status = 'Liveness check error: $code';
      _sessionId = '';
      _isLoading = false;
    });
  }
}
