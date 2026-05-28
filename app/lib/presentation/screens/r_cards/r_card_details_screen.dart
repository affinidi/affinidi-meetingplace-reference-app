import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:meeting_place_credentials/meeting_place_credentials.dart';
import 'package:share_plus/share_plus.dart';

import '../../../application/services/contacts_service/contacts_service.dart';
import '../../../application/services/r_cards_service/r_cards_service.dart';
import '../../../infrastructure/extensions/build_context_extensions.dart';
import '../../../infrastructure/providers/cache_manager_provider.dart';
import '../../../navigation/routes/dashboard_routes.dart';
import '../../../navigation/tabs/tabs.dart';
import '../../painting/cached_base64_image.dart';
import '../../widgets/cards/r_card_header_card.dart';
import '../../widgets/images/default_profile_image.dart';
import 'r_card_notes_sheet.dart';
import 'r_cards_deck.dart' show returningCardProvider;
import 'r_cards_screen_controller.dart';

class RCardDetailsScreen extends ConsumerStatefulWidget {
  const RCardDetailsScreen({
    super.key,
    required this.subjectDid,
    this.vcBlob,
    this.isFromMe = false,
  });

  final String subjectDid;
  final String? vcBlob;
  final bool isFromMe;

  @override
  ConsumerState<RCardDetailsScreen> createState() => _RCardDetailsScreenState();
}

class _RCardDetailsScreenState extends ConsumerState<RCardDetailsScreen> {
  late PageController _pageController;
  late int _currentIndex;
  double _dragOffset = 0.0;
  bool _isDragging = false;
  double _screenHeight = 0.0;

  @override
  void initState() {
    super.initState();
    final cards = ref.read(rCardsServiceProvider);
    final subjectDidTrimmed = widget.subjectDid.trim();
    _currentIndex = cards.indexWhere(
      (c) => c.subjectDid.trim() == subjectDidTrimmed,
    );
    final initialPage = max(0, _currentIndex);
    _pageController = PageController(initialPage: initialPage);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _handleVerticalDragUpdate(DragUpdateDetails details) {
    if (details.primaryDelta != null) {
      setState(() {
        _isDragging = true;
        _dragOffset += details.primaryDelta! * 0.8;
        final maxDrag = _screenHeight * 0.8;
        _dragOffset = _dragOffset.clamp(0.0, maxDrag);
      });
    }
  }

  void _handleVerticalDragEnd(DragEndDetails details) {
    final dismissThreshold = _screenHeight * 0.2;

    if (_dragOffset >= dismissThreshold) {
      if (mounted) {
        final cards = ref.read(rCardsServiceProvider);
        final useVirtual =
            widget.vcBlob != null &&
            (cards.isEmpty ||
                cards.indexWhere(
                      (c) => c.subjectDid.trim() == widget.subjectDid.trim(),
                    ) <
                    0);
        final currentCard =
            !useVirtual && _currentIndex >= 0 && _currentIndex < cards.length
            ? cards[_currentIndex].subjectDid
            : null;

        Navigator.of(context).pop();

        if (currentCard != null) {
          Future(() {
            ref.read(returningCardProvider.notifier).set(currentCard);
          });
        }
      }
    } else {
      setState(() {
        _isDragging = false;
        _dragOffset = 0.0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final walletCards = ref.watch(rCardsServiceProvider);

    _screenHeight = MediaQuery.sizeOf(context).height;

    final subjectDidTrimmed = widget.subjectDid.trim();
    final inWalletIndex = walletCards.indexWhere(
      (c) => c.subjectDid.trim() == subjectDidTrimmed,
    );
    final useVirtualCard =
        widget.vcBlob != null && (walletCards.isEmpty || inWalletIndex < 0);

    final List<RCard> displayCards;
    if (useVirtualCard) {
      final virtual = RCard.fromVcBlob(widget.subjectDid, widget.vcBlob!);
      if (virtual == null) {
        return const _NoCardsScaffold();
      }
      displayCards = [virtual];
    } else {
      if (walletCards.isEmpty || inWalletIndex < 0) {
        return const _NoCardsScaffold();
      }
      displayCards = walletCards;
    }

    final currentCard =
        displayCards[_currentIndex.clamp(0, displayCards.length - 1)];
    final isOwnCard = useVirtualCard ? widget.isFromMe : false;

    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop && !useVirtualCard) {
          Future(() {
            if (_currentIndex >= 0 && _currentIndex < displayCards.length) {
              ref
                  .read(returningCardProvider.notifier)
                  .set(displayCards[_currentIndex].subjectDid);
            }
          });
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            l10n.tabsTitle(Tabs.rCards.name),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              height: 1.6,
              letterSpacing: 0.07,
            ),
          ),
          actions: isOwnCard
              ? null
              : [
                  IconButton(
                    onPressed: () => _deleteCard(context, ref, currentCard),
                    icon: const Icon(Icons.delete),
                  ),
                  IconButton(
                    onPressed: () => _exportCard(context, ref, currentCard),
                    icon: const Icon(Icons.download_outlined),
                  ),
                ],
        ),
        body: GestureDetector(
          onVerticalDragUpdate: _handleVerticalDragUpdate,
          onVerticalDragEnd: _handleVerticalDragEnd,
          child: AnimatedContainer(
            duration: _isDragging
                ? Duration.zero
                : const Duration(milliseconds: 300),
            curve: Curves.easeOut,
            transform: Matrix4.translationValues(0, _dragOffset, 0),
            child: PageView.builder(
              controller: _pageController,
              itemCount: displayCards.length,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              itemBuilder: (context, index) {
                final card = displayCards[index];
                return _RCardDetailsContent(
                  card: card,
                  subjectDid: card.subjectDid,
                  isOwnCard: isOwnCard,
                  dragOffset: _dragOffset,
                  screenHeight: _screenHeight,
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _deleteCard(
    BuildContext context,
    WidgetRef ref,
    RCard card,
  ) async {
    final l10n = context.l10n;
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.generalDelete),
        content: Text(l10n.rCardDeletePrompt),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.generalCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.generalDelete),
          ),
        ],
      ),
    );

    if (shouldDelete != true) return;

    await ref
        .read(rCardsServiceProvider.notifier)
        .deleteBySubjectDid(card.subjectDid);

    if (!context.mounted) return;
    Navigator.of(context).pop();
  }

  Future<void> _exportCard(
    BuildContext context,
    WidgetRef ref,
    RCard card,
  ) async {
    final l10n = context.l10n;
    final box = context.findRenderObject() as RenderBox?;
    final xFile = await ref
        .read(rCardsServiceProvider.notifier)
        .exportSingleAsVcf(card);

    if (xFile == null) return;

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
}

class _RCardDetailsContent extends ConsumerWidget {
  const _RCardDetailsContent({
    required this.card,
    required this.subjectDid,
    required this.isOwnCard,
    required this.dragOffset,
    required this.screenHeight,
  });

  final RCard card;
  final String subjectDid;
  final bool isOwnCard;
  final double dragOffset;
  final double screenHeight;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;

    final subject = ref
        .read(rCardsScreenControllerProvider.notifier)
        .subjectFor(card);
    final name = subject?.name.trim() ?? '';
    final displayName = name.isNotEmpty ? name : subjectDid;
    final profilePic = subject?.profilePic?.trim();
    final email = subject?.email?.trim();
    final phone = subject?.phone?.trim();
    final company = subject?.company?.trim();
    final position = subject?.position?.trim();
    final social = subject?.social?.trim();
    final website = subject?.website?.trim();

    final cacheManager = ref.read(cacheManagerProvider);

    final contactsService = ref.read(contactsServiceProvider);
    final contact = contactsService.getContactByChannelDid(card.issuerDid);

    Future<void> openUrl(String url) async {
      await Clipboard.setData(ClipboardData(text: url));
    }

    Future<void> editNotes() async {
      await RCardNotesSheet.show(
        context: context,
        initialNotes: card.notes,
        onSave: (notes) => ref
            .read(rCardsServiceProvider.notifier)
            .updateNotes(subjectDid, notes),
      );
    }

    void goToChat() {
      if (contact == null) return;

      final chatLocation = ChatRoute(contactId: contact.id).location;
      final router = GoRouter.of(context);
      final matches = router.routerDelegate.currentConfiguration.matches;
      final chatIndex = matches.lastIndexWhere(
        (m) => (m as dynamic).matchedLocation == chatLocation,
      );

      if (chatIndex != -1) {
        final chatIsDirectlyBelow = chatIndex == matches.length - 2;
        if (chatIsDirectlyBelow) {
          router.pop();
          return;
        }
        router.go(chatLocation);
        return;
      }

      ChatRoute(contactId: contact.id).push<void>(context);
    }

    final notesLabel = (card.notes == null || card.notes!.trim().isEmpty)
        ? l10n.rCardAddNotes
        : l10n.rCardUpdateNotes;

    String notSharedIfEmpty(String? value) {
      final v = value?.trim();
      return (v == null || v.isEmpty) ? l10n.notShared : v;
    }

    final fadeStartThreshold = screenHeight * 0.05;
    final fadeEndThreshold = screenHeight * 0.25;
    final opacity = dragOffset <= fadeStartThreshold
        ? 1.0
        : dragOffset >= fadeEndThreshold
        ? 0.0
        : 1.0 -
              ((dragOffset - fadeStartThreshold) /
                  (fadeEndThreshold - fadeStartThreshold));

    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Hero(
                tag: 'r_card_$subjectDid',
                child: RCardHeaderCard(
                  name: displayName,
                  avatarImage: (profilePic == null || profilePic.isEmpty)
                      ? defaultProfileImage
                      : CachedBase64Image(
                          profilePic,
                          cacheManager: cacheManager,
                        ),
                ),
              ),
              const SizedBox(height: 20),
              AnimatedOpacity(
                duration: const Duration(milliseconds: 100),
                opacity: opacity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _DetailsSection(
                      dividerColor: context.colorScheme.primary,
                      rows: [
                        _DetailRowData(
                          icon: Icons.email_outlined,
                          label: '${l10n.rCardFieldEmail}:',
                          value: notSharedIfEmpty(email),
                        ),
                        _DetailRowData(
                          icon: Icons.phone_outlined,
                          label: '${l10n.rCardFieldPhone}:',
                          value: notSharedIfEmpty(phone),
                        ),
                        _DetailRowData(
                          icon: Icons.apartment_outlined,
                          label: '${l10n.rCardFieldCompany}:',
                          value: notSharedIfEmpty(company),
                        ),
                        _DetailRowData(
                          icon: Icons.badge_outlined,
                          label: '${l10n.rCardFieldPosition}:',
                          value: notSharedIfEmpty(position),
                        ),
                        _DetailRowData(
                          icon: Icons.share_outlined,
                          label: '${l10n.rCardFieldSocial}:',
                          value: notSharedIfEmpty(social),
                          trailing: const Icon(Icons.open_in_new, size: 18),
                          onTap: (social == null || social.trim().isEmpty)
                              ? null
                              : () => openUrl(social),
                        ),
                        _DetailRowData(
                          icon: Icons.public,
                          label: '${l10n.rCardFieldWebsite}:',
                          value: notSharedIfEmpty(website),
                          trailing: const Icon(Icons.open_in_new, size: 18),
                          onTap: (website == null || website.trim().isEmpty)
                              ? null
                              : () => openUrl(website),
                        ),
                      ],
                    ),
                    if (!isOwnCard) ...[
                      const SizedBox(height: 16),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: InkWell(
                          onTap: editNotes,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Text(
                              notesLabel,
                              style: context.textTheme.bodyMedium?.copyWith(
                                color: context.colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                      if (card.notes != null &&
                          card.notes!.trim().isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          card.notes!.trim(),
                          style: context.textTheme.bodyMedium?.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ],
                      const SizedBox(height: 18),
                      Center(
                        child: TextButton.icon(
                          onPressed: contact == null ? null : goToChat,
                          icon: const Icon(Icons.chat_bubble_outline),
                          label: Text(
                            l10n.rCardChatWith(
                              name.isEmpty ? l10n.anonymous : displayName,
                            ),
                          ),
                          style: TextButton.styleFrom(
                            foregroundColor: context.colorScheme.primary,
                            textStyle: context.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailsSection extends StatelessWidget {
  const _DetailsSection({required this.rows, required this.dividerColor});

  final List<_DetailRowData> rows;
  final Color dividerColor;

  @override
  Widget build(BuildContext context) {
    final visible = rows
        .where((r) => r.value != null && r.value!.isNotEmpty)
        .toList();

    return Column(
      children: [
        for (var i = 0; i < visible.length; i++) ...[
          _DetailRow(row: visible[i], dividerColor: dividerColor),
          if (i != visible.length - 1)
            Divider(height: 1, thickness: 1, color: dividerColor),
        ],
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.row, required this.dividerColor});

  final _DetailRowData row;
  final Color dividerColor;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isNotShared = row.value == l10n.notShared;

    return InkWell(
      onTap: row.onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            Icon(row.icon, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text.rich(
                TextSpan(
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: Colors.white,
                  ),
                  children: [
                    TextSpan(
                      text: '${row.label} ',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    TextSpan(
                      text: row.value ?? '',
                      style: TextStyle(
                        color: isNotShared
                            ? context.colorScheme.onSurface.withAlpha(160)
                            : context.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (row.trailing != null) ...[
              const SizedBox(width: 8),
              IconTheme(
                data: IconThemeData(color: dividerColor),
                child: row.trailing!,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _DetailRowData {
  const _DetailRowData({
    required this.icon,
    required this.label,
    required this.value,
    this.trailing,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final String? value;
  final Widget? trailing;
  final VoidCallback? onTap;
}

class _NoCardsScaffold extends ConsumerWidget {
  const _NoCardsScaffold();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.tabsTitle(Tabs.rCards.name))),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            l10n.rCardsEmpty,
            textAlign: TextAlign.center,
            style: context.textTheme.bodyLarge,
          ),
        ),
      ),
    );
  }
}
