import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:meeting_place_matrix/meeting_place_matrix.dart';

import '../../../domain/models/call_log/call_log_entry.dart';
import '../../../infrastructure/extensions/build_context_extensions.dart';
import '../../../l10n/app_localizations.dart';
import '../../../navigation/routes/route_paths.dart';
import '../../themes/tokens/mc_icons.dart';
import '../../themes/tokens/mc_spacing.dart';
import '../../widgets/common/app_card.dart';
import '../../widgets/section_header.dart';
import '../chat/audio_video_call/rules/call_chat_item_rules.dart';
import 'call_log_screen_controller.dart';

part 'call_log_item.dart';

class CallLogScreen extends ConsumerWidget {
  const CallLogScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final provider = callLogScreenControllerProvider;

    final isLoading = ref.watch(provider.select((state) => state.isLoading));
    final entries = ref.watch(provider.select((state) => state.entries));
    final errorMessage = ref.watch(
      provider.select((state) => state.errorMessage),
    );

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SectionHeader(
            icon: McIcons.callLog,
            title: l10n.callLogScreenTitle,
            subtitle: l10n.callLogScreenSubtitle,
            onClose: () {
              final router = GoRouter.of(context);
              if (router.canPop()) {
                router.pop();
              } else {
                router.go(RoutePaths.contacts);
              }
            },
          ),
          if (isLoading)
            const Padding(
              padding: EdgeInsets.all(24.0),
              child: Center(child: CircularProgressIndicator.adaptive()),
            )
          else if (errorMessage != null)
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(l10n.callLogError),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () => ref.read(provider.notifier).refresh(),
                      child: Text(l10n.generalRetry),
                    ),
                  ],
                ),
              ),
            )
          else if (entries.isEmpty)
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Center(child: Text(l10n.callLogEmpty)),
            )
          else
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(
                  horizontal: McSpacing.s4,
                  vertical: McSpacing.s3,
                ),
                itemCount: entries.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: McSpacing.s3),
                itemBuilder: (context, index) =>
                    _CallLogItem(entry: entries[index]),
              ),
            ),
        ],
      ),
    );
  }
}
