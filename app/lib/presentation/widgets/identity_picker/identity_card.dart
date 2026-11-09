import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:pie_menu/pie_menu.dart';

import '../../../domain/models/contact_card/contact_card_field_definition.dart';
import '../../../domain/models/identity/identity.dart';
import '../../../infrastructure/extensions/build_context_extensions.dart';
import '../../../infrastructure/extensions/contact_card_extensions.dart';
import '../../../infrastructure/extensions/identities_extensions.dart';
import '../../themes/tokens/mc_icons.dart';
import '../../themes/tokens/mc_radius.dart';
import '../../themes/tokens/mc_typography.dart';
import '../animated_menu.dart';
import '../common/app_card.dart';
import '../profile_picture.dart';
import '../vta_details.dart';

enum IdentityCardSize { small, normal }

extension _IdentityCardSizeExtension on IdentityCardSize {
  bool get isSmall => this == IdentityCardSize.small;
}

class IdentityCard extends StatelessWidget {
  const IdentityCard({
    super.key,
    required this.identity,
    this.onDeleteIdentity,
    this.onFindOfferForIdentity,
    this.onEditIdentity,
    this.onPublishOfferForIdentity,
    this.identityCardSize = IdentityCardSize.normal,
    required this.cacheManager,
  });

  final Identity identity;
  final IdentityCardSize identityCardSize;
  final BaseCacheManager cacheManager;
  final void Function(Identity identity)? onDeleteIdentity;
  final void Function(Identity identity)? onFindOfferForIdentity;
  final void Function(Identity identity)? onEditIdentity;
  final void Function(Identity identity)? onPublishOfferForIdentity;

  @override
  Widget build(BuildContext context) {
    // A Mission Control product card: a large panel that carries the
    // identity's own colour as its corner wash, behind the picture.
    return Center(
      child: Container(
        margin: const EdgeInsets.all(8),
        constraints: BoxConstraints(
          minHeight: identityCardSize.isSmall ? 200 : 400,
          maxWidth: 650,
        ),
        child: AppCard(
          accent: identity.getCardColor(context.colorScheme),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(McRadius.xl),
            side: BorderSide(color: context.mcColors.hairline),
          ),
          child: Stack(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _IdentityHeader(
                    identity: identity,
                    identityCardSize: identityCardSize,
                  ),
                  _IdentityContentSection(
                    identity: identity,
                    identityCardSize: identityCardSize,
                  ),
                ],
              ),
              _IdentityProfilePicture(
                identity: identity,
                size: identityCardSize.isSmall ? 110 : 130,
                cacheManager: cacheManager,
              ),
              if (!identityCardSize.isSmall)
                _IdentityActionButton(
                  identity: identity,
                  onDeleteIdentity: onDeleteIdentity,
                  onFindOfferForIdentity: onFindOfferForIdentity,
                  onEditIdentity: onEditIdentity,
                  onPublishOfferForIdentity: onPublishOfferForIdentity,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IdentityHeader extends StatelessWidget {
  const _IdentityHeader({
    required this.identity,
    required this.identityCardSize,
  });

  final Identity identity;
  final IdentityCardSize identityCardSize;

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;
    final mc = context.mcColors;
    final l10n = context.l10n;

    final rightInset = identityCardSize.isSmall ? 130.0 : 150.0;

    // A section head: the kind of identity as an eyebrow, then its name.
    return Container(
      constraints: BoxConstraints(
        minHeight: identityCardSize.isSmall ? 45 : 90,
      ),
      padding: EdgeInsets.fromLTRB(20, 16, rightInset, 14),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              spacing: 4,
              children: [
                Text(
                  identity.getSubtitle(l10n: l10n).toUpperCase(),
                  style: McTypography.eyebrow.copyWith(color: mc.textSecondary),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  softWrap: true,
                ),
                // The VTA's shield beside the name, for an identity there.
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        identity.getDisplayName(l10n: l10n),
                        style:
                            (identityCardSize.isSmall
                                    ? textTheme.titleMedium
                                    : textTheme.titleLarge)
                                ?.copyWith(color: mc.textPrimary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (identity.isVtaPersona)
                      VtaDetailsButton(
                        contextId: identity.vtaContextId!,
                        profileId: identity.vtaProfileId!,
                        color: mc.textSecondary,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _IdentityProfilePicture extends StatelessWidget {
  _IdentityProfilePicture({
    required this.identity,
    required this.size,
    required this.cacheManager,
  }) : super(key: ValueKey('profile_image_${identity.id}'));

  final Identity identity;
  final double size;
  final BaseCacheManager cacheManager;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 10,
      right: 10,
      child: ProfilePicture(
        image: identity.profileImage(cacheManager: cacheManager),
        size: size,
      ),
    );
  }
}

class _IdentityContentSection extends StatelessWidget {
  const _IdentityContentSection({
    required this.identity,
    required this.identityCardSize,
  });

  final Identity identity;
  final IdentityCardSize identityCardSize;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: identityCardSize.isSmall
          ? const EdgeInsets.only(top: 4, left: 20, right: 20)
          : const EdgeInsets.only(top: 48, left: 24, right: 24),
      child: _IdentityContent(
        identity: identity,
        identityCardSize: identityCardSize,
      ),
    );
  }
}

class _IdentityContent extends StatelessWidget {
  const _IdentityContent({
    required this.identityCardSize,
    required this.identity,
  });

  final Identity identity;
  final IdentityCardSize identityCardSize;

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;
    final l10n = context.l10n;

    final fields = ContactCardFieldDefinitions.values
        .where((field) => field.hasTag(ContactCardFieldTags.identityCard))
        .toList(growable: false);

    final name = identity.card.fullName.isNotEmpty
        ? identity.card.fullName
        : '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (name.isNotEmpty)
          Row(
            children: [
              Expanded(
                child: Text(
                  name,
                  style: identityCardSize.isSmall
                      ? textTheme.bodyMedium
                      : textTheme.titleMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  softWrap: true,
                ),
              ),
              if (identityCardSize.isSmall) const Spacer(),
            ],
          ),
        SizedBox(height: identityCardSize.isSmall ? 12 : 16),
        for (final field in fields) ...[
          _ContactInfoRow(
            icon: field.icon,
            value: field.valueFrom(identity.card).trim(),
            notShared: l10n.notShared,
            identityCardSize: identityCardSize,
          ),
          SizedBox(height: identityCardSize.isSmall ? 6 : 8),
        ],
      ],
    );
  }
}

class _ContactInfoRow extends StatelessWidget {
  const _ContactInfoRow({
    required this.icon,
    required this.value,
    required this.notShared,
    required this.identityCardSize,
  });

  final IconData icon;

  /// The field's value; empty when the identity does not share it.
  final String value;
  final String notShared;
  final IdentityCardSize identityCardSize;

  @override
  Widget build(BuildContext context) {
    final mc = context.mcColors;
    final textTheme = context.textTheme;
    final isShared = value.isNotEmpty;

    return Row(
      spacing: 8,
      children: [
        Icon(icon, color: mc.textSecondary, size: 16),
        Expanded(
          child: Text(
            isShared ? value : notShared,
            style:
                (identityCardSize.isSmall
                        ? textTheme.bodySmall
                        : textTheme.bodyLarge)
                    ?.copyWith(
                      color: isShared ? mc.textPrimary : mc.textTertiary,
                    ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _IdentityActionButton extends StatelessWidget {
  const _IdentityActionButton({
    required this.identity,
    required this.onDeleteIdentity,
    required this.onFindOfferForIdentity,
    required this.onEditIdentity,
    required this.onPublishOfferForIdentity,
  });

  final Identity identity;
  final void Function(Identity identity)? onDeleteIdentity;
  final void Function(Identity identity)? onFindOfferForIdentity;
  final void Function(Identity identity)? onEditIdentity;
  final void Function(Identity identity)? onPublishOfferForIdentity;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 50,
      left: 0,
      right: 0,
      child: Center(
        child: _ActionButton(
          identity: identity,
          onDeleteIdentity: onDeleteIdentity,
          onFindOfferForIdentity: onFindOfferForIdentity,
          onEditIdentity: onEditIdentity,
          onPublishOfferForIdentity: onPublishOfferForIdentity,
        ),
      ),
    );
  }
}

class _ActionButtonConfig {
  const _ActionButtonConfig();

  static const int edit = 0;
  static const int connect = 1;
  static const int delete = 2;
  static const int publish = 3;
}

class _ActionButton extends HookWidget {
  const _ActionButton({
    required this.identity,
    required this.onDeleteIdentity,
    required this.onFindOfferForIdentity,
    required this.onEditIdentity,
    required this.onPublishOfferForIdentity,
  });

  final Identity identity;
  final void Function(Identity identity)? onDeleteIdentity;
  final void Function(Identity identity)? onFindOfferForIdentity;
  final void Function(Identity identity)? onEditIdentity;
  final void Function(Identity identity)? onPublishOfferForIdentity;

  _RippleAnimations _makeRippleAnimation(AnimationController controller) {
    final scale = Tween<double>(
      begin: 1.0,
      end: 1.9,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeOut));
    final fade = Tween<double>(
      begin: 0.4,
      end: 0.0,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeOut));

    return _RippleAnimations(scale: scale, fade: fade);
  }

  List<_ActionItem> _buildActions(BuildContext context) {
    final mc = context.mcColors;
    final isPrimary = identity.isPrimary;

    return [
      _ActionItem(
        icon: McIcons.delete,
        // A destructive menu item speaks in danger text.
        color: isPrimary ? mc.textTertiary : mc.dangerText,
        action: _ActionButtonConfig.delete,
        isEnabled: !isPrimary,
      ),
      _ActionItem(
        icon: McIcons.findOffer,
        color: mc.textPrimary,
        action: _ActionButtonConfig.connect,
      ),
      _ActionItem(
        icon: McIcons.edit,
        color: mc.textPrimary,
        action: _ActionButtonConfig.edit,
      ),
      _ActionItem(
        icon: McIcons.publishOffer,
        color: mc.textPrimary,
        action: _ActionButtonConfig.publish,
      ),
    ];
  }

  List<PieAction> _buildPieActions({
    required List<_ActionItem> actions,
    required PieMenuController controller,
  }) {
    return actions
        .map(
          (action) => PieAction(
            tooltip: const SizedBox.shrink(),
            onSelect: () async {
              controller.closeMenu();

              switch (action.action) {
                case _ActionButtonConfig.delete:
                  onDeleteIdentity?.call(identity);
                  break;
                case _ActionButtonConfig.connect:
                  onFindOfferForIdentity?.call(identity);
                  break;
                case _ActionButtonConfig.edit:
                  onEditIdentity?.call(identity);
                  break;
                case _ActionButtonConfig.publish:
                  onPublishOfferForIdentity?.call(identity);
                  break;
              }
            },
            child: _ActionMenuItem(action: action),
          ),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final pieMenuController = PieMenuController();

    final vsync = useSingleTickerProvider();
    final controller = useAnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: vsync,
    );

    useEffect(() {
      Timer? timer;

      timer = Timer.periodic(const Duration(seconds: 2), (_) {
        if (controller.isCompleted || controller.isDismissed) {
          controller.forward(from: 0.0);
        }
      });

      controller.forward();

      return timer.cancel;
    }, []);

    final animations = _makeRippleAnimation(controller);
    final actions = _buildActions(context);
    final pieActions = _buildPieActions(
      actions: actions,
      controller: pieMenuController,
    );

    return Padding(
      padding: const EdgeInsets.only(top: 24.0),
      child: AnimatedMenu(
        controller: pieMenuController,
        actions: pieActions,
        child: _RippleButton(
          animations: animations,
          onTap: () => WidgetsBinding.instance.addPostFrameCallback((_) {
            pieMenuController.openMenu();
          }),
        ),
      ),
    );
  }
}

class _RippleAnimations {
  const _RippleAnimations({required this.scale, required this.fade});

  final Animation<double> scale;
  final Animation<double> fade;
}

class _RippleButton extends StatelessWidget {
  const _RippleButton({required this.animations, required this.onTap});

  final _RippleAnimations animations;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        FadeTransition(
          opacity: animations.fade,
          child: ScaleTransition(
            scale: animations.scale,
            child: _StarIcon(color: context.colorScheme.onSurface),
          ),
        ),
        GestureDetector(
          onTap: onTap,
          child: _StarIcon(color: context.colorScheme.onSurface),
        ),
      ],
    );
  }
}

class _StarIcon extends StatelessWidget {
  const _StarIcon({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/meeting-place-splash-white-1024.png',
      width: 70,
      height: 70,
      color: color,
    );
  }
}

class _ActionItem {
  const _ActionItem({
    required this.icon,
    required this.color,
    required this.action,
    this.isEnabled = true,
  });

  final IconData icon;
  final Color color;
  final int action;
  final bool isEnabled;
}

class _ActionMenuItem extends StatelessWidget {
  const _ActionMenuItem({required this.action});

  final _ActionItem action;

  @override
  Widget build(BuildContext context) {
    final mc = context.mcColors;

    // A raised control on a hairline, as Mission Control's ghost controls.
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: mc.raised,
        shape: BoxShape.circle,
        border: Border.all(
          color: action.isEnabled ? mc.hairlineStrong : mc.hairline,
        ),
      ),
      child: Icon(action.icon, color: action.color, size: 28),
    );
  }
}
