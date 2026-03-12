import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../domain/models/contact_card/identity_field.dart';
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

class IdentityFormScreen extends HookConsumerWidget {
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
    final anonymousLabel = context.l10n.anonymous;

    ref.keepAround(provider);

    useEffect(() {
      // Save identity on screen exit
      return () {
        Future(() async {
          await controller.saveIdentity(
            anonymousLabel: anonymousLabel,
            mode: mode,
          );
        });
      };
    }, [identityId]);

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
