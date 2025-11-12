import 'package:flutter/material.dart';

import '../../infrastructure/extensions/build_context_extensions.dart';

class MenuOptionTile extends StatelessWidget {
  const MenuOptionTile({
    this.enabled = true,
    this.title,
    this.subtitle,
    this.warning,
    required this.assetName,
    this.onTap,
  });

  final bool enabled;
  final String? title;
  final String? subtitle;
  final String? warning;
  final String assetName;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final subtitles = [subtitle, warning].nonNulls.join('\n');

    return ListTile(
      enabled: enabled,
      leading: Builder(
        builder: (context) => Image.asset(
          'assets/icons/$assetName',
          width: 24,
          height: 24,
          color: enabled
              ? context.listTileTheme.iconColor
              : context.theme.disabledColor,
        ),
      ),
      title: title != null ? Text(title!) : null,
      subtitle: subtitles.isNotEmpty ? Text(subtitles) : null,
      onTap: onTap,
    );
  }
}
