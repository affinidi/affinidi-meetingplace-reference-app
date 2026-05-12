import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pie_menu/pie_menu.dart';

import '../../../domain/models/contact_card/contact_card_field_definition.dart';
import '../../../infrastructure/extensions/build_context_extensions.dart';
import '../../../infrastructure/extensions/identities_extensions.dart';
import '../../../infrastructure/extensions/widget_ref_extensions.dart';
import '../../../infrastructure/providers/cache_manager_provider.dart';
import '../../../navigation/routes/dashboard_routes.dart';
import '../../../navigation/tabs/tabs.dart';
import '../../helpers/screensize_helper.dart';
import '../../widgets/action_button.dart';
import '../../widgets/buttons/elevated_loading_button.dart';
import '../../widgets/identity_picker/identity_picker.dart';
import '../../widgets/section_banner.dart';
import '../../widgets/tab_bar_tab.dart';
import 'form_screen/identity_form_fields.dart';
import 'form_screen/identity_form_mode.dart';
import 'form_screen/identity_form_screen_controller.dart';
import 'identities_screen_controller.dart';
import 'identities_screen_filter.dart';

part 'delete_identity_dialog.dart';
part 'filters_bar.dart';
part 'primary_identity_setup.dart';

final identitiesScreenFormKey = GlobalKey<FormState>();

class IdentitiesScreen extends ConsumerWidget {
  const IdentitiesScreen({super.key});

  static const double iconPieButtonsRadius = 72;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final colorScheme = context.colorScheme;
    ref.keepAround(identitiesScreenControllerProvider);

    return PieCanvas(
      theme: const PieTheme(
        customAngleDiff: 90,
        customAngle: 45,
        customAngleAnchor: PieAnchor.center,
        radius: iconPieButtonsRadius,
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SectionBanner(
                title: l10n.tabsTitle(Tabs.identities.name),
                subtitle: context.l10n.identitiesPanelSubtitle,
                icon: Icon(
                  Icons.fingerprint,
                  color: colorScheme.onSurfaceVariant,
                  size: 24,
                ),
              ),
              _IdentitiesPanel(),
            ],
          ),
        ),
      ),
    );
  }
}

class _IdentitiesPanel extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = identitiesScreenControllerProvider;
    final shouldSetupPrimaryIdentity = ref.watch(
      provider.select((state) => state.shouldSetupPrimaryIdentity),
    );

    Future<void> onAddIdentity() async {
      if (!context.mounted) return;

      const IdentityFormRoute().go(context);
    }

    if (shouldSetupPrimaryIdentity) {
      return _PrimaryIdentitySetup(formKey: identitiesScreenFormKey);
    }

    return Column(
      children: [
        _FiltersBar(),
        Padding(
          padding: const EdgeInsets.all(2),
          child: _ActionsBar(onAddIdentity: onAddIdentity),
        ),
        _IdentityPicker(),
        const SizedBox(height: 20),
      ],
    );
  }
}

class _IdentityPicker extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = identitiesScreenControllerProvider;
    final controller = ref.read(identitiesScreenControllerProvider.notifier);
    final cacheManager = ref.read(cacheManagerProvider);

    final identities = ref.watch(provider.select((state) => state.identities));
    final currentIdentity = ref.watch(
      provider.select((state) => state.currentIdentity),
    );
    final initialCardIndex = identities.indexWhere(
      (identity) => identity.id == currentIdentity?.id,
    );

    return IdentityPicker(
      key: ValueKey('identities_picker_${identities.length}'),
      identities: identities,
      initialCardIndex: initialCardIndex,
      onCreateIdentity: () => const IdentityFormRoute().go(context),
      onDeleteIdentity: (identity) async {
        if (identity.isPrimary || identity.isPlaceholder) return;

        final shouldDelete = await DeleteIdentityDialog.show(
          context: context,
          displayName: identity.card.displayName,
        );
        if (shouldDelete) {
          await controller.deleteIdentity(identity.id);
        }
      },
      onFindOfferForIdentity: (identity) async =>
          await FindOfferRoute(identityId: identity.id).push<void>(context),
      onEditIdentity: (identity) =>
          IdentityFormRoute(identityId: identity.id).go(context),
      onPublishOfferForIdentity: (identity) async =>
          await PublishOfferRoute(identityId: identity.id).push<void>(context),
      onSelectedIdentity: controller.setCurrentIdentity,
      swipeDirection: const AllowedSwipeDirection.only(
        left: true,
        right: true,
        down: true,
      ),
      cacheManager: cacheManager,
    );
  }
}

class _ActionsBar extends ConsumerWidget {
  _ActionsBar({required this.onAddIdentity});

  final VoidCallback onAddIdentity;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(identitiesScreenControllerProvider.notifier);
    final shouldShowFilter = ref.watch(
      identitiesScreenControllerProvider.select(
        (state) => state.shouldShowFilter,
      ),
    );
    final currentIdentity = ref.watch(
      identitiesScreenControllerProvider.select(
        (state) => state.currentIdentity,
      ),
    );

    final isDefault = currentIdentity?.isPrimary ?? false;
    final isPlaceholder = currentIdentity?.isPlaceholder ?? false;
    final canDelete = currentIdentity != null && !isDefault && !isPlaceholder;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            IconButton(
              icon: Icon(
                Icons.filter_list_alt,
                color: shouldShowFilter
                    ? context.colorScheme.primary
                    : context.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              onPressed: controller.toggleFilterVisibility,
            ),
          ],
        ),
        const Expanded(child: _SearchField()),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: canDelete
                  ? () async {
                      if (!context.mounted) return;

                      final shouldDelete = await DeleteIdentityDialog.show(
                        context: context,
                        displayName: currentIdentity.card.displayName,
                      );
                      if (shouldDelete) {
                        await controller.deleteIdentity(currentIdentity.id);
                      }
                    }
                  : null,
            ),
            IconButton(icon: const Icon(Icons.add), onPressed: onAddIdentity),
          ],
        ),
      ],
    );
  }
}

class _SearchField extends HookConsumerWidget {
  const _SearchField();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(identitiesScreenControllerProvider.notifier);
    final searchTextController = useTextEditingController();
    final text = useListenable(searchTextController).text;
    final colorScheme = context.colorScheme;
    final shouldShowFilter = ref.watch(
      identitiesScreenControllerProvider.select(
        (state) => state.shouldShowFilter,
      ),
    );

    useEffect(() {
      if (!shouldShowFilter) {
        searchTextController.clear();
      }
      return null;
    }, [shouldShowFilter]);

    if (!shouldShowFilter) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Container(
        height: 35,
        decoration: BoxDecoration(
          border: Border.all(color: colorScheme.outline, width: 0.8),
          borderRadius: BorderRadius.circular(20.0),
          color: colorScheme.surface,
        ),
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: TextField(
                  controller: searchTextController,
                  keyboardType: TextInputType.text,
                  autocorrect: false,
                  textCapitalization: TextCapitalization.none,
                  style: context.textTheme.bodyMedium,
                  decoration: InputDecoration(
                    hintText: context.l10n.filter,
                    hintStyle: TextStyle(color: colorScheme.outline),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  onChanged: controller.search,
                ),
              ),
            ),
            if (text.isNotEmpty)
              IconButton(
                icon: Icon(Icons.clear, color: colorScheme.onSurface, size: 20),
                onPressed: () {
                  searchTextController.clear();
                  controller.clearSearch();
                },
              ),
          ],
        ),
      ),
    );
  }
}
