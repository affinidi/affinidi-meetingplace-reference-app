import 'package:flutter/material.dart';

sealed class AttachmentPluginIcon {
  const AttachmentPluginIcon();
}

class MaterialIcon extends AttachmentPluginIcon {
  const MaterialIcon(this.iconData, {this.color});
  final IconData iconData;
  final Color? color;
}

class AssetIcon extends AttachmentPluginIcon {
  const AssetIcon(this.assetPath);
  final String assetPath;
}

class EmojiIcon extends AttachmentPluginIcon {
  const EmojiIcon(this.emoji);
  final String emoji;
}
