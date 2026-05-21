import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:meeting_place_relationship/meeting_place_relationship.dart';
import 'package:share_plus/share_plus.dart';

import '../../../application/services/r_cards_service/r_cards_service.dart';
import '../../../infrastructure/extensions/build_context_extensions.dart';
import '../../../navigation/tabs/tabs.dart';
import '../../widgets/section_banner.dart';
import '../../widgets/tab_bar_tab.dart';
import 'r_cards_deck.dart';
import 'r_cards_screen_controller.dart';
import 'r_cards_screen_filter.dart';

/// Displays all received R-Cards as a stacked card deck with filter, search,
/// and export capabilities.
class RCardsScreen extends HookConsumerWidget {
  const RCardsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final colorScheme = context.colorScheme;
    final customColors = context.customColors;
    final provider = rCardsScreenControllerProvider;
    final controller = ref.read(provider.notifier);

    final filter = ref.watch(provider.select((state) => state.filter));
    final isSearchActive = ref.watch(
      provider.select((state) => state.isSearchActive),
    );
    final cards = ref.watch(provider.select((state) => state.cards));
    final hasAnyCards = ref.watch(rCardsServiceProvider).isNotEmpty;

    final searchController = useTextEditingController();

    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.setAnonymousLabel(l10n.anonymous);
      });
      return null;
    }, [l10n.anonymous]);

    useEffect(() {
      if (!isSearchActive) {
        searchController.clear();
      }
      return null;
    }, [isSearchActive]);

    Future<void> exportAll() async {
      final box = context.findRenderObject() as RenderBox?;
      final allCards = ref.read(rCardsServiceProvider);
      if (allCards.isEmpty) return;

      final xFile = await ref
          .read(rCardsServiceProvider.notifier)
          .exportAllAsVcf();

      final params = ShareParams(
        files: [xFile],
        downloadFallbackEnabled: true,
        mailToFallbackEnabled: true,
        fileNameOverrides: [xFile.name],
        title: l10n.tabsTitle(Tabs.rCards.name),
        sharePositionOrigin: box == null
            ? null
            : box.localToGlobal(Offset.zero) & box.size,
      );

      await SharePlus.instance.share(params);
    }

    final deckKey = 'r_cards_deck_${cards.length}_${filter.name}';

    return ColoredBox(
      color: colorScheme.surface,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SectionBanner(
              title: l10n.tabsTitle(Tabs.rCards.name),
              subtitle: l10n.rCardsPanelSubtitle,
              icon: Icon(
                Icons.credit_card_outlined,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            Row(
              children: [
                if (isSearchActive)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: TextField(
                        controller: searchController,
                        onChanged: controller.search,
                        style: TextStyle(color: colorScheme.onSurface),
                        decoration: InputDecoration(
                          hintText: l10n.generalSearch,
                          hintStyle: TextStyle(
                            color: customColors.searchHintText,
                          ),
                          filled: true,
                          fillColor: customColors.searchFieldFill,
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                  )
                else ...[
                  _FiltersBar(),
                  const Spacer(),
                ],
                IconButton(
                  onPressed: controller.toggleSearch,
                  icon: Icon(Icons.search, color: colorScheme.onSurface),
                ),
                IconButton(
                  onPressed: hasAnyCards ? exportAll : null,
                  icon: Icon(
                    Icons.download_outlined,
                    color: hasAnyCards
                        ? colorScheme.onSurface
                        : colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
            Expanded(
              child: cards.isNotEmpty
                  ? ScrollConfiguration(
                      behavior: ScrollConfiguration.of(context).copyWith(
                        overscroll: true,
                        physics: const AlwaysScrollableScrollPhysics(
                          parent: ClampingScrollPhysics(),
                        ),
                        scrollbars: false,
                      ),
                      child: StretchingOverscrollIndicator(
                        axisDirection: AxisDirection.down,
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(
                            parent: ClampingScrollPhysics(),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
                            child: RCardsDeck(
                              deckKey: deckKey,
                              cards: cards,
                              extractSubject: RCardSubject.fromVcBlob,
                            ),
                          ),
                        ),
                      ),
                    )
                  : const _EmptyStateWidget(),
            ),
          ],
        ),
      ),
    );
  }
}

class _FiltersBar extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(rCardsScreenControllerProvider.notifier);
    final tabController = useTabController(
      initialLength: RCardsScreenFilter.values.length,
      initialIndex: 0,
    );
    final l10n = context.l10n;

    return TabBar(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      isScrollable: true,
      enableFeedback: true,
      labelPadding: const EdgeInsets.symmetric(horizontal: 10),
      tabAlignment: TabAlignment.start,
      controller: tabController,
      onTap: (index) {
        if (!context.mounted) return;
        controller.applyFilter(RCardsScreenFilter.values[index]);
      },
      tabs: RCardsScreenFilter.values
          .map(
            (filter) => TabBarTab(label: l10n.rCardsFilterLabel(filter.name)),
          )
          .toList(),
    );
  }
}

class _EmptyStateWidget extends ConsumerWidget {
  const _EmptyStateWidget();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final hasFilterApplied = ref.watch(
      rCardsScreenControllerProvider.select((state) => state.hasFilterApplied),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.5,
        child: Center(
          child: Text(
            hasFilterApplied ? l10n.noRCardsFoundWithFilter : l10n.rCardsEmpty,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
