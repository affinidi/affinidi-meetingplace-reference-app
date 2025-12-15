import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../infrastructure/extensions/build_context_extensions.dart';

class MatchMakerConcierge extends ConsumerWidget {
  const MatchMakerConcierge({super.key});

  static Future<bool?> show(BuildContext context) async {
    return showModalBottomSheet<bool>(
      backgroundColor: context.colorScheme.inverseSurface,
      useRootNavigator: true,
      isScrollControlled: true,
      showDragHandle: true,
      useSafeArea: true,
      context: context,
      builder: (context) => const MatchMakerConcierge(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'assets/images/matchmaker.png',
            height: 200,
            errorBuilder: (context, error, stackTrace) {
              return Icon(
                Icons.people,
                size: 200,
                color: context.colorScheme.onInverseSurface,
              );
            },
          ),
          const SizedBox(height: 24),
          Text(
            'Find people at the event who match your interests! Our Match Maker Concierge will help you connect with like-minded individuals - but at the same time, you control your privacy and remain in control of who connects to you.\n\nWe will use your primary identity to connect to others.',
            style: context.theme.textTheme.headlineSmall?.copyWith(
              color: context.colorScheme.onInverseSurface,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Start the Matchmaker'),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
