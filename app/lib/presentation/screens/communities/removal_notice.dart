import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../application/services/vtc_service/vtc_service.dart';
import '../../../domain/models/vtc/vtc_removal.dart';
import '../../../infrastructure/extensions/build_context_extensions.dart';

/// The communities that removed the member, as this phone finds them.
final vtcRemovalsProvider = StreamProvider<VtcRemoval>(
  (ref) => ref.read(vtcServiceProvider).removed,
  name: 'vtcRemovalsProvider',
);

/// Tells the member in a snack bar each time a community removed them,
/// with the community's reason if it gave one. Call from a build.
void listenForRemovals(WidgetRef ref, BuildContext context) {
  ref.listen(vtcRemovalsProvider, (_, next) {
    final removal = next.value;
    if (removal == null || !context.mounted) return;
    final l10n = context.l10n;
    final name = removal.name ?? l10n.membershipCredentialUnnamed;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        key: const Key('vtc_removed'),
        content: Text(switch (removal.reason) {
          final reason? => l10n.vtcRemovedWithReason(name, reason),
          null => l10n.vtcRemoved(name),
        }),
      ),
    );
  });
}
