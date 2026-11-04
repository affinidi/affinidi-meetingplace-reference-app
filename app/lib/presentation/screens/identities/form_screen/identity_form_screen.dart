import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../domain/models/contact_card/contact_card_field_definition.dart';
import '../../../../domain/models/identity/identity.dart';
import '../../../../infrastructure/extensions/build_context_extensions.dart';
import '../../../../infrastructure/extensions/identities_extensions.dart';
import '../../../../infrastructure/extensions/widget_ref_extensions.dart';
import '../../../../infrastructure/providers/cache_manager_provider.dart';
import '../../../widgets/buttons/elevated_loading_button.dart';
import '../../../widgets/form_rows/form_card.dart';
import '../../../widgets/form_rows/form_row_text_field.dart';
import '../../../widgets/identity_picker/identity_card.dart';
import 'identity_card_customizer_dialog.dart';
import 'identity_form_fields.dart';
import 'identity_form_mode.dart';
import 'identity_form_screen_controller.dart';

part 'identity_form_alias_field.dart';
part 'identity_form_app_bar.dart';
part 'identity_form_bottom_container.dart';
part 'identity_form_section.dart';

class IdentityFormScreen extends ConsumerWidget {
  IdentityFormScreen({super.key, this.identityId});

  final String? identityId;

  IdentityFormMode get mode =>
      identityId != null ? IdentityFormMode.edit : IdentityFormMode.add;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const double maxWidth = 900;
    final width = MediaQuery.sizeOf(context).width;
    final inset = width > maxWidth ? (width - maxWidth) / 2 : 20.0;

    final provider = identityFormScreenControllerProvider(identityId);
    final controller = ref.read(provider.notifier);

    ref.keepAround(provider);

    return Scaffold(
      appBar: _IdentityFormAppBar(identityId, mode: mode),
      body: SafeArea(
        child: FocusTraversalGroup(
          policy: OrderedTraversalPolicy(),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  controller: controller.scrollController,
                  padding: EdgeInsets.fromLTRB(inset, 0, inset, 20),
                  child: Column(
                    spacing: 20,
                    children: [
                      _IdentitySection(identityId),
                      _IdentityFormSection(identityId),
                      _IdentityFormAliasField(identityId),
                      _PersonaSection(identityId),
                    ],
                  ),
                ),
              ),
              _IdentityFormBottomContainer(identityId, mode: mode),
            ],
          ),
        ),
      ),
    );
  }
}

/// The persona DID an identity held by the member's VTA is, for the member
/// to find it on their VTA.
class _PersonaSection extends ConsumerWidget {
  const _PersonaSection(this.identityId);

  final String? identityId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = identityFormScreenControllerProvider(identityId);
    final identity = ref.watch(provider.select((state) => state.identity));
    if (!identity.isVtaPersona) return const SizedBox.shrink();

    final l10n = context.l10n;
    return FormCard(
      title: l10n.identityPersonaTitle,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 8,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: SelectableText(
                    identity.did,
                    key: const Key('identity_persona_did'),
                    style: context.textTheme.bodySmall,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.copy, size: 18),
                  tooltip: l10n.identityPersonaCopyDid,
                  visualDensity: VisualDensity.compact,
                  onPressed: () async {
                    await Clipboard.setData(ClipboardData(text: identity.did));
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.copiedToClipboard)),
                    );
                  },
                ),
              ],
            ),
            Text(
              l10n.identityPersonaHint,
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IdentitySection extends ConsumerWidget {
  const _IdentitySection(this.identityId);

  final String? identityId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = identityFormScreenControllerProvider(identityId);
    final controller = ref.read(provider.notifier);
    final identity = ref.watch(provider.select((state) => state.identity));
    final cacheManager = ref.read(cacheManagerProvider);

    Future<void> showIdentityCardCustomizer() async {
      if (!context.mounted) return;

      final initialColor = identity.getCardColor(context.colorScheme);

      final selectedColor = await IdentityCardCustomizerDialog.show(
        context,
        initialColor: initialColor,
      );

      if (selectedColor != null) {
        controller.updateCardColor(selectedColor);
      }
    }

    return Column(
      spacing: 20,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: IdentityCard(
            identity: identity,
            identityCardSize: IdentityCardSize.small,
            cacheManager: cacheManager,
          ),
        ),
        if (!identity.isPrimary)
          TextButton(
            onPressed: showIdentityCardCustomizer,
            child: Text(context.l10n.customiseIdentityCard),
          ),
      ],
    );
  }
}
