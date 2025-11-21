import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:meeting_place_core/meeting_place_core.dart' show Identity;
import 'package:pie_menu/pie_menu.dart';
import '../../../infrastructure/extensions/build_context_extensions.dart';
import '../../../infrastructure/extensions/contact_card_extensions.dart';
import '../../../infrastructure/extensions/identities_extensions.dart';
import '../animated_menu.dart';
import '../profile_picture.dart';

class IdentityCard extends StatelessWidget {
  const IdentityCard({
    super.key,
    required this.identity,
    this.onDeleteIdentity,
    this.onFindOfferForIdentity,
    this.onEditIdentity,
    this.onPublishOfferForIdentity,
    this.displayMode = false,
    required this.cacheManager,
  });

  final Identity identity;
  final bool displayMode;
  final BaseCacheManager cacheManager;
  final void Function(Identity identity)? onDeleteIdentity;
  final void Function(Identity identity)? onFindOfferForIdentity;
  final void Function(Identity identity)? onEditIdentity;
  final void Function(Identity identity)? onPublishOfferForIdentity;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return Center(
      child: Container(
        margin: const EdgeInsets.all(8),
        constraints:
            BoxConstraints(minHeight: displayMode ? 200 : 400, maxWidth: 650),
        decoration: BoxDecoration(
          gradient: RadialGradient(
            radius: 0.5,
            center: Alignment.bottomRight,
            colors: [
              identity.getCardColor(colorScheme, intensity: 0.35),
              colorScheme.surface,
            ],
          ),
          borderRadius: BorderRadius.circular(25.0),
          border: Border.all(
            color: identity.getCardColor(colorScheme),
          ),
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            _IdentityHeader(identity: identity, displayMode: displayMode),
            _IdentityProfilePicture(
              identity: identity,
              size: displayMode ? 110 : 130,
              cacheManager: cacheManager,
            ),
            _IdentityContentSection(
              identity: identity,
              displayMode: displayMode,
            ),
            if (!displayMode)
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
    );
  }
}

class _IdentityHeader extends StatelessWidget {
  const _IdentityHeader({
    required this.identity,
    this.displayMode = false,
  });

  final Identity identity;
  final bool displayMode;

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;
    final colorScheme = context.colorScheme;
    final l10n = context.l10n;

    return Container(
      constraints: BoxConstraints(minHeight: displayMode ? 45 : 90),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(25.0),
          topRight: Radius.circular(25.0),
        ),
        gradient: identity.getLinearGradient(colorScheme),
      ),
      padding: const EdgeInsets.all(14.0),
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
                  identity.getDisplayName(l10n: l10n),
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onPrimary,
                  ),
                  maxLines: 2,
                  softWrap: true,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  identity.getSubtitle(l10n: l10n),
                  style: (displayMode
                          ? textTheme.labelMedium
                          : textTheme.bodyMedium)
                      ?.copyWith(color: colorScheme.onPrimary.withAlpha(180)),
                  softWrap: true,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
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
    required this.displayMode,
    required this.identity,
  });

  final Identity identity;
  final bool displayMode;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: displayMode ? 60 : 120,
      left: 0,
      right: 0,
      bottom: displayMode ? 0 : 80,
      child: _IdentityContent(
        identity: identity,
        displayMode: displayMode,
      ),
    );
  }
}

class _IdentityContent extends StatelessWidget {
  const _IdentityContent({
    required this.displayMode,
    required this.identity,
  });

  final Identity identity;
  final bool displayMode;

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;
    final l10n = context.l10n;

    final email = identity.card.emailAddress.isNotEmpty == true
        ? identity.card.emailAddress
        : l10n.notShared;
    final phone = identity.card.mobilePhone.isNotEmpty == true
        ? identity.card.mobilePhone
        : l10n.notShared;

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            identity.card.fullName.isNotEmpty == true
                ? identity.card.fullName
                : '',
            style: displayMode ? textTheme.bodyMedium : textTheme.titleMedium,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            softWrap: true,
          ),
          const SizedBox(height: 16),
          _ContactInfoRow(
            icon: Icons.email,
            text: email,
            displayMode: displayMode,
          ),
          const SizedBox(height: 8),
          _ContactInfoRow(
            icon: Icons.phone,
            text: phone,
            displayMode: displayMode,
          ),
        ],
      ),
    );
  }
}

class _ContactInfoRow extends StatelessWidget {
  const _ContactInfoRow({
    required this.icon,
    required this.text,
    required this.displayMode,
  });

  final IconData icon;
  final String text;
  final bool displayMode;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;

    return Row(
      spacing: 8,
      children: [
        Icon(icon, color: colorScheme.onSurfaceVariant, size: 16),
        Expanded(
          child: Text(
            text,
            style: displayMode ? textTheme.labelMedium : textTheme.titleMedium,
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
    final scale = Tween<double>(begin: 1.0, end: 1.9).animate(
      CurvedAnimation(parent: controller, curve: Curves.easeOut),
    );
    final fade = Tween<double>(begin: 0.4, end: 0.0).animate(
      CurvedAnimation(parent: controller, curve: Curves.easeOut),
    );

    return _RippleAnimations(scale: scale, fade: fade);
  }

  List<_ActionItem> _buildActions(BuildContext context) {
    final colorScheme = context.colorScheme;
    final isPrimary = identity.isPrimary;

    return [
      _ActionItem(
        icon: Icons.delete,
        color: isPrimary
            ? context.customColors.disabledGrey
            : colorScheme.onSurface,
        action: _ActionButtonConfig.delete,
        isEnabled: !isPrimary,
      ),
      _ActionItem(
        icon: Icons.receipt,
        color: colorScheme.onSurface,
        action: _ActionButtonConfig.connect,
        assetPath: 'assets/icons/receive.png',
      ),
      _ActionItem(
        icon: Icons.edit,
        color: colorScheme.onSurface,
        action: _ActionButtonConfig.edit,
      ),
      _ActionItem(
        icon: Icons.publish,
        color: colorScheme.onSurface,
        action: _ActionButtonConfig.publish,
        assetPath: 'assets/icons/publish.png',
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
          onTap: pieMenuController.openMenu,
        ),
      ),
    );
  }
}

class _RippleAnimations {
  const _RippleAnimations({
    required this.scale,
    required this.fade,
  });

  final Animation<double> scale;
  final Animation<double> fade;
}

class _RippleButton extends StatelessWidget {
  const _RippleButton({
    required this.animations,
    required this.onTap,
  });

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
    this.assetPath,
    this.isEnabled = true,
  });

  final IconData icon;
  final Color color;
  final int action;
  final String? assetPath;
  final bool isEnabled;
}

class _ActionMenuItem extends StatelessWidget {
  const _ActionMenuItem({required this.action});

  final _ActionItem action;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(64),
        border: Border.all(
          color: action.isEnabled
              ? colorScheme.onSurface
              : context.theme.disabledColor,
        ),
      ),
      child: action.assetPath != null
          ? Padding(
              padding: const EdgeInsets.all(14.0),
              child: Image.asset(action.assetPath!, color: action.color),
            )
          : Icon(action.icon, color: action.color, size: 28),
    );
  }
}
