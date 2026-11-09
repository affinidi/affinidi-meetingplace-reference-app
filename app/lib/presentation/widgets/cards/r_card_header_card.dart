import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../infrastructure/extensions/build_context_extensions.dart';
import '../../themes/tokens/mc_icons.dart';
import '../../themes/tokens/mc_radius.dart';

class RCardHeaderCard extends StatelessWidget {
  const RCardHeaderCard({super.key, required this.name, this.avatarImage});

  static const double height = 240;

  final String name;
  final ImageProvider? avatarImage;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final mc = context.mcColors;

    return ClipRRect(
      borderRadius: BorderRadius.circular(McRadius.lg),
      child: Container(
        constraints: const BoxConstraints.tightFor(height: height),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerLow,
          border: Border.all(color: mc.hairline),
          borderRadius: BorderRadius.circular(McRadius.lg),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Positioned(
              right: -60,
              top: -50,
              bottom: -50,
              child: ExcludeSemantics(
                child: SvgPicture.asset(
                  'assets/images/R.svg',
                  width: 300,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          softWrap: true,
                          style: context.textTheme.titleLarge?.copyWith(
                            color: mc.textPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      CircleAvatar(
                        radius: 26,
                        backgroundColor: colorScheme.surfaceContainerHigh,
                        foregroundImage: avatarImage,
                        child: avatarImage == null
                            ? Icon(McIcons.person, color: mc.textSecondary)
                            : null,
                      ),
                    ],
                  ),
                  Text(
                    context.l10n.rCardTitle,
                    style: context.textTheme.titleLarge?.copyWith(
                      color: mc.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
