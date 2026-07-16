import 'package:flutter/material.dart';

/// Example showing how to initialize meeting_place_livekit_flutter with
/// MeetingPlaceMatrixSDK for audio/video calling.
///
/// Configuration is loaded from .env file. See .env.example for required keys.
///
/// For a complete working example with wallet, repositories, and chat flows,
/// see the Affinidi Meeting Place Reference App:
/// https://github.com/affinidi/affinidi-meetingplace-reference-app/tree/main/app

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MeetingPlaceLiveKitExample());
}

class MeetingPlaceLiveKitExample extends StatelessWidget {
  const MeetingPlaceLiveKitExample({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Meeting Place - LiveKit Flutter Example',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const SetupScreen(),
    );
  }
}

class SetupScreen extends StatelessWidget {
  const SetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Meeting Place - LiveKit Flutter')),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _SetupHeader(),
                SizedBox(height: 32),
                _InitializationStepsSection(),
                SizedBox(height: 32),
                _KeyComponentsSection(),
                SizedBox(height: 32),
                _ReferenceAppLinkSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SetupHeader extends StatelessWidget {
  const _SetupHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'LiveKit Flutter Plugin',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 16),
        Text(
          'Real-time audio and video call rendering for '
          'Meeting Place SDK via LiveKit with Matrix RTC signalling.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
}

class _InitializationStepsSection extends StatelessWidget {
  const _InitializationStepsSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Initialization Steps',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 16),
        const _StepTile(
          number: '1',
          title: 'Initialize Vodozemac',
          description: 'await fvod.init() in main() before SDK creation',
        ),
        const SizedBox(height: 12),
        const _StepTile(
          number: '2',
          title: 'Create MatrixConfig',
          description: 'Include livekitServiceUrl and livekitSfuUrl endpoints',
        ),
        const SizedBox(height: 12),
        const _StepTile(
          number: '3',
          title: 'Create MeetingPlaceMatrixSDK',
          description:
              'Pass FlutterMatrixRTCDelegate() and '
              'FlutterLiveKitRoom() factory',
        ),
        const SizedBox(height: 12),
        const _StepTile(
          number: '4',
          title: 'Initialize Chat Session',
          description:
              'MeetingPlaceMatrixChatSDK.initialiseFromChannel() '
              'to start calls',
        ),
      ],
    );
  }
}

class _StepTile extends StatelessWidget {
  const _StepTile({
    required this.number,
    required this.title,
    required this.description,
  });

  final String number;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            number,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 4),
              Text(description, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      ],
    );
  }
}

class _KeyComponentsSection extends StatelessWidget {
  const _KeyComponentsSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Key Components', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 16),
        const _ComponentTile(
          name: 'FlutterMatrixRTCDelegate',
          description: 'WebRTC delegate for Matrix RTC signalling',
        ),
        const SizedBox(height: 8),
        const _ComponentTile(
          name: 'FlutterLiveKitRoom',
          description: 'LiveKit room implementation',
        ),
        const SizedBox(height: 8),
        const _ComponentTile(
          name: 'AudioVideoCallView',
          description: 'Flutter widget for rendering video tracks',
        ),
      ],
    );
  }
}

class _ComponentTile extends StatelessWidget {
  const _ComponentTile({required this.name, required this.description});

  final String name;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          const Text('•', style: TextStyle(fontSize: 20)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.w500)),
                Text(description, style: const TextStyle(fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ReferenceAppLinkSection extends StatelessWidget {
  const _ReferenceAppLinkSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            'For a complete working example with wallet, repositories, '
            'and chat flows, see the Affinidi Meeting Place Reference App.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 12),
          SelectableText(
            'https://github.com/affinidi/affinidi-meetingplace-reference-app'
            '/tree/main/app/lib/infrastructure/providers/meeting_place_sdk_provider.dart',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              color: Colors.blue[700],
              decoration: TextDecoration.underline,
            ),
          ),
        ],
      ),
    );
  }
}
