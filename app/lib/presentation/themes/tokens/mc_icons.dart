import 'package:flutter/widgets.dart';

/// The app's icons by meaning, drawn from Phosphor, Mission Control's only
/// icon set, in its line (regular) weight so they sit with the hairlines.
///
/// See `@affinidi/design-tokens` v3.1.0 `50-assets/icons.md`. The font is
/// bundled from Phosphor 2.1 (`assets/fonts/phosphor`, MIT); each doc
/// names the icon on phosphoricons.com. Pick an icon here by what it means,
/// and add a meaning here rather than reaching for another set or a filled
/// weight.
abstract final class McIcons {
  static const fontFamily = 'Phosphor';

  // Sections
  /// Phosphor `chat-circle`.
  static const IconData contacts = IconData(0xe168, fontFamily: fontFamily);

  /// Phosphor `users-three`.
  static const IconData communities = IconData(0xe68e, fontFamily: fontFamily);

  /// Phosphor `arrows-left-right`.
  static const IconData connections = IconData(0xe0a0, fontFamily: fontFamily);

  /// Phosphor `fingerprint`.
  static const IconData identities = IconData(0xe23e, fontFamily: fontFamily);

  /// Phosphor `credit-card`.
  static const IconData rCards = IconData(0xe1d2, fontFamily: fontFamily);

  /// Phosphor `shield-check`.
  static const IconData credentials = IconData(0xe40c, fontFamily: fontFamily);

  /// Phosphor `gear`.
  static const IconData settings = IconData(0xe270, fontFamily: fontFamily);

  /// Phosphor `clock-counter-clockwise`.
  static const IconData callLog = IconData(0xe1a0, fontFamily: fontFamily);

  /// Phosphor `flask`.
  static const IconData mockCredentials = IconData(
    0xe79e,
    fontFamily: fontFamily,
  );

  // Actions
  /// Phosphor `plus`.
  static const IconData add = IconData(0xe3d4, fontFamily: fontFamily);

  /// Phosphor `arrow-left`.
  static const IconData back = IconData(0xe058, fontFamily: fontFamily);

  /// Phosphor `x`.
  static const IconData close = IconData(0xe4f6, fontFamily: fontFamily);

  /// Phosphor `copy`.
  static const IconData copy = IconData(0xe1ca, fontFamily: fontFamily);

  /// Phosphor `trash`.
  static const IconData delete = IconData(0xe4a6, fontFamily: fontFamily);

  /// Phosphor `pencil-simple`.
  static const IconData edit = IconData(0xe3b4, fontFamily: fontFamily);

  /// Phosphor `funnel-simple`.
  static const IconData filter = IconData(0xe268, fontFamily: fontFamily);

  /// Phosphor `magnifying-glass`.
  static const IconData findOffer = IconData(0xe30c, fontFamily: fontFamily);

  /// Phosphor `list`.
  static const IconData menu = IconData(0xe2f0, fontFamily: fontFamily);

  /// Phosphor `magnifying-glass`.
  static const IconData search = IconData(0xe30c, fontFamily: fontFamily);

  /// Phosphor `share-network`.
  static const IconData publishOffer = IconData(0xe408, fontFamily: fontFamily);

  // Contact card fields
  /// Phosphor `user`.
  static const IconData person = IconData(0xe4c2, fontFamily: fontFamily);

  /// Phosphor `identification-card`.
  static const IconData badge = IconData(0xe2c8, fontFamily: fontFamily);

  /// Phosphor `envelope-simple`.
  static const IconData email = IconData(0xe218, fontFamily: fontFamily);

  /// Phosphor `phone`.
  static const IconData phone = IconData(0xe3b8, fontFamily: fontFamily);
}
