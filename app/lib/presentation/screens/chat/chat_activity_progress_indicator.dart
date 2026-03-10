import 'package:flutter/material.dart' hide LinearProgressIndicator;
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../widgets/loaders/linear_progress_indicator.dart';
import 'chat_screen_controller.dart';

class ChatActivityProgressIndicator extends ConsumerWidget {
  ChatActivityProgressIndicator({super.key, required String contactId})
    : _contactId = contactId;

  final String _contactId;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = chatScreenControllerProvider(_contactId);
    final shouldShowProgress = ref.watch(provider.shouldShowProgress);

    return SizedBox(
      height: 3,
      child: shouldShowProgress
          ? LinearProgressIndicator()
          : const SizedBox.shrink(),
    );
  }
}
