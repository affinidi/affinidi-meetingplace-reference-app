import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../application/services/identities_service/identities_service.dart';
import '../../../domain/models/identity/identity.dart';
import '../../../infrastructure/extensions/build_context_extensions.dart';
import '../../../infrastructure/providers/cache_manager_provider.dart';
import '../../widgets/identity_picker/identity_picker.dart';

class MatchMakerConcierge extends HookConsumerWidget {
  const MatchMakerConcierge({super.key});

  static Future<Identity?> show(BuildContext context) async {
    return showModalBottomSheet<Identity>(
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
    final identities = ref.watch(
      identitiesServiceProvider.select((state) => state.identities),
    );
    final cacheManager = ref.read(cacheManagerProvider);
    final selectedIdentity = useState<Identity?>(
      identities.isNotEmpty ? identities.first : null,
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(12.0, 0, 12.0, 24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Find people at the event who\nmatch your interests',
            style: context.theme.textTheme.titleLarge?.copyWith(
              color: context.colorScheme.onInverseSurface,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Select which identity to use\nwhen others match with you:',
            style: context.theme.textTheme.bodyMedium?.copyWith(
              color: context.colorScheme.onInverseSurface,
            ),
            textAlign: TextAlign.center,
          ),
          if (identities.isNotEmpty)
            SizedBox(
              height: 250,
              child: IdentityPicker(
                key: const ValueKey('matchmaker_identity_picker'),
                identities: identities,
                onSelectedIdentity: (identity) {
                  selectedIdentity.value = identity;
                },
                displayMode: true,
                cacheManager: cacheManager,
              ),
            ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: selectedIdentity.value != null
                  ? () => Navigator.of(context).pop(selectedIdentity.value)
                  : null,
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
