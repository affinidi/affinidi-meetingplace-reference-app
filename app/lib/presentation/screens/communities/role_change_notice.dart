import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../application/services/vtc_service/vtc_service.dart';
import '../../../domain/models/vtc/vtc_role_change.dart';
import '../../../infrastructure/extensions/build_context_extensions.dart';
import '../vtc_join/vtc_role_name.dart';

/// The member's new roles in communities, as this phone finds them.
final vtcRoleChangesProvider = StreamProvider<VtcRoleChange>(
  (ref) => ref.read(vtcServiceProvider).roleChanged,
  name: 'vtcRoleChangesProvider',
);

/// Tells the member in a snack bar each time their role in a community
/// changes, e.g. after an administrator promoted them. Call from a build.
void listenForRoleChanges(WidgetRef ref, BuildContext context) {
  ref.listen(vtcRoleChangesProvider, (_, next) async {
    final change = next.value;
    if (change == null) return;
    final community = await ref
        .read(vtcServiceProvider)
        .community(change.communityDid);
    if (!context.mounted) return;
    final l10n = context.l10n;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        key: const Key('vtc_role_changed'),
        content: Text(
          l10n.vtcRoleChanged(
            community?.name ?? l10n.membershipCredentialUnnamed,
            vtcRoleName(l10n, change.role),
          ),
        ),
      ),
    );
  });
}
