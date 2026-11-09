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

  // Everything else, by meaning
  /// Phosphor `user-circle`.
  static const IconData account = IconData(0xe4c4, fontFamily: fontFamily);

  /// Phosphor `chat-circle-dots`.
  static const IconData addComment = IconData(0xe16c, fontFamily: fontFamily);

  /// Phosphor `address-book`.
  static const IconData addressBook = IconData(0xe6f8, fontFamily: fontFamily);

  /// Phosphor `user-gear`.
  static const IconData admin = IconData(0xe4cc, fontFamily: fontFamily);

  /// Phosphor `megaphone`.
  static const IconData announce = IconData(0xe324, fontFamily: fontFamily);

  /// Phosphor `file-zip`.
  static const IconData archive = IconData(0xe958, fontFamily: fontFamily);

  /// Phosphor `archive`.
  static const IconData archiveBox = IconData(0xe00c, fontFamily: fontFamily);

  /// Phosphor `arrow-right`.
  static const IconData arrowForward = IconData(0xe06c, fontFamily: fontFamily);

  /// Phosphor `paperclip`.
  static const IconData attachment = IconData(0xe39a, fontFamily: fontFamily);

  /// Phosphor `medal`.
  static const IconData award = IconData(0xe320, fontFamily: fontFamily);

  /// Phosphor `arrow-left`.
  static const IconData back = IconData(0xe058, fontFamily: fontFamily);

  /// Phosphor `prohibit`.
  static const IconData block = IconData(0xe3de, fontFamily: fontFamily);

  /// Phosphor `calendar`.
  static const IconData calendar = IconData(0xe108, fontFamily: fontFamily);

  /// Phosphor `calendar-check`.
  static const IconData calendarCheck = IconData(
    0xe712,
    fontFamily: fontFamily,
  );

  /// Phosphor `calendar-x`.
  static const IconData calendarX = IconData(0xe10c, fontFamily: fontFamily);

  /// Phosphor `phone-call`.
  static const IconData call = IconData(0xe3ba, fontFamily: fontFamily);

  /// Phosphor `camera`.
  static const IconData camera = IconData(0xe10e, fontFamily: fontFamily);

  /// Phosphor `x-circle`.
  static const IconData cancel = IconData(0xe4f8, fontFamily: fontFamily);

  /// Phosphor `shapes`.
  static const IconData category = IconData(0xec5e, fontFamily: fontFamily);

  /// Phosphor `confetti`.
  static const IconData celebrate = IconData(0xe81a, fontFamily: fontFamily);

  /// Phosphor `chat-circle`.
  static const IconData chat = IconData(0xe168, fontFamily: fontFamily);

  /// Phosphor `chats-circle`.
  static const IconData chats = IconData(0xe17e, fontFamily: fontFamily);

  /// Phosphor `check`.
  static const IconData check = IconData(0xe182, fontFamily: fontFamily);

  /// Phosphor `check-circle`.
  static const IconData checkCircle = IconData(0xe184, fontFamily: fontFamily);

  /// Phosphor `list-checks`.
  static const IconData checklist = IconData(0xeadc, fontFamily: fontFamily);

  /// Phosphor `caret-down`.
  static const IconData chevronDown = IconData(0xe136, fontFamily: fontFamily);

  /// Phosphor `caret-right`.
  static const IconData chevronRight = IconData(0xe13a, fontFamily: fontFamily);

  /// Phosphor `caret-up`.
  static const IconData chevronUp = IconData(0xe13c, fontFamily: fontFamily);

  /// Phosphor `circle`.
  static const IconData circle = IconData(0xe18a, fontFamily: fontFamily);

  /// Phosphor `clipboard-text`.
  static const IconData clipboard = IconData(0xe198, fontFamily: fontFamily);

  /// Phosphor `clock`.
  static const IconData clock = IconData(0xe19a, fontFamily: fontFamily);

  /// Phosphor `cloud-check`.
  static const IconData cloudDone = IconData(0xe1b0, fontFamily: fontFamily);

  /// Phosphor `brackets-curly`.
  static const IconData code = IconData(0xe860, fontFamily: fontFamily);

  /// Phosphor `arrows-in`.
  static const IconData collapse = IconData(0xe09a, fontFamily: fontFamily);

  /// Phosphor `users-three`.
  static const IconData community = IconData(0xe68e, fontFamily: fontFamily);

  /// Phosphor `plugs-connected`.
  static const IconData connect = IconData(0xeb5a, fontFamily: fontFamily);

  /// Phosphor `desktop`.
  static const IconData desktop = IconData(0xe560, fontFamily: fontFamily);

  /// Phosphor `device-mobile`.
  static const IconData device = IconData(0xe1e0, fontFamily: fontFamily);

  /// Phosphor `file-text`.
  static const IconData document = IconData(0xe23a, fontFamily: fontFamily);

  /// Phosphor `download-simple`.
  static const IconData download = IconData(0xe20c, fontFamily: fontFamily);

  /// Phosphor `dots-six-vertical`.
  static const IconData dragHandle = IconData(0xeae2, fontFamily: fontFamily);

  /// Phosphor `envelope-open`.
  static const IconData emailRead = IconData(0xe216, fontFamily: fontFamily);

  /// Phosphor `lock-key`.
  static const IconData encrypted = IconData(0xe2fe, fontFamily: fontFamily);

  /// Phosphor `warning-circle`.
  static const IconData error = IconData(0xe4e2, fontFamily: fontFamily);

  /// Phosphor `arrows-out`.
  static const IconData expand = IconData(0xe0a2, fontFamily: fontFamily);

  /// Phosphor `puzzle-piece`.
  static const IconData extension = IconData(0xe596, fontFamily: fontFamily);

  /// Phosphor `folder`.
  static const IconData folder = IconData(0xe24a, fontFamily: fontFamily);

  /// Phosphor `squares-four`.
  static const IconData grid = IconData(0xe464, fontFamily: fontFamily);

  /// Phosphor `users`.
  static const IconData group = IconData(0xe4d6, fontFamily: fontFamily);

  /// Phosphor `handshake`.
  static const IconData handshake = IconData(0xe582, fontFamily: fontFamily);

  /// Phosphor `phone-disconnect`.
  static const IconData hangUp = IconData(0xe3bc, fontFamily: fontFamily);

  /// Phosphor `eye-slash`.
  static const IconData hidden = IconData(0xe224, fontFamily: fontFamily);

  /// Phosphor `graph`.
  static const IconData hub = IconData(0xeb58, fontFamily: fontFamily);

  /// Phosphor `image`.
  static const IconData image = IconData(0xe2ca, fontFamily: fontFamily);

  /// Phosphor `image-broken`.
  static const IconData imageBroken = IconData(0xe7a8, fontFamily: fontFamily);

  /// Phosphor `images`.
  static const IconData images = IconData(0xe836, fontFamily: fontFamily);

  /// Phosphor `tray`.
  static const IconData inbox = IconData(0xe4aa, fontFamily: fontFamily);

  /// Phosphor `info`.
  static const IconData info = IconData(0xe2ce, fontFamily: fontFamily);

  /// Phosphor `bank`.
  static const IconData institution = IconData(0xe0b4, fontFamily: fontFamily);

  /// Phosphor `key`.
  static const IconData key = IconData(0xe2d6, fontFamily: fontFamily);

  /// Phosphor `link`.
  static const IconData link = IconData(0xe2e2, fontFamily: fontFamily);

  /// Phosphor `link-break`.
  static const IconData linkBreak = IconData(0xe2e4, fontFamily: fontFamily);

  /// Phosphor `list-bullets`.
  static const IconData list = IconData(0xe2f2, fontFamily: fontFamily);

  /// Phosphor `map-pin`.
  static const IconData location = IconData(0xe316, fontFamily: fontFamily);

  /// Phosphor `lock`.
  static const IconData lock = IconData(0xe2fa, fontFamily: fontFamily);

  /// Phosphor `sign-in`.
  static const IconData login = IconData(0xe428, fontFamily: fontFamily);

  /// Phosphor `sign-out`.
  static const IconData logout = IconData(0xe42a, fontFamily: fontFamily);

  /// Phosphor `tree-structure`.
  static const IconData mediator = IconData(0xe67c, fontFamily: fontFamily);

  /// Phosphor `identification-badge`.
  static const IconData membership = IconData(0xe6f6, fontFamily: fontFamily);

  /// Phosphor `git-merge`.
  static const IconData merge = IconData(0xe280, fontFamily: fontFamily);

  /// Phosphor `microphone`.
  static const IconData mic = IconData(0xe326, fontFamily: fontFamily);

  /// Phosphor `microphone-slash`.
  static const IconData micOff = IconData(0xe328, fontFamily: fontFamily);

  /// Phosphor `dots-three`.
  static const IconData more = IconData(0xe1fe, fontFamily: fontFamily);

  /// Phosphor `note`.
  static const IconData note = IconData(0xe348, fontFamily: fontFamily);

  /// Phosphor `bell`.
  static const IconData notifications = IconData(
    0xe0ce,
    fontFamily: fontFamily,
  );

  /// Phosphor `bell-slash`.
  static const IconData notificationsOff = IconData(
    0xe0d4,
    fontFamily: fontFamily,
  );

  /// Phosphor `arrow-square-out`.
  static const IconData openExternal = IconData(0xe5de, fontFamily: fontFamily);

  /// Phosphor `buildings`.
  static const IconData organisation = IconData(0xe102, fontFamily: fontFamily);

  /// Phosphor `users-four`.
  static const IconData participants = IconData(0xe68c, fontFamily: fontFamily);

  /// Phosphor `clipboard`.
  static const IconData paste = IconData(0xe196, fontFamily: fontFamily);

  /// Phosphor `pause`.
  static const IconData pause = IconData(0xe39e, fontFamily: fontFamily);

  /// Phosphor `file-pdf`.
  static const IconData pdf = IconData(0xe702, fontFamily: fontFamily);

  /// Phosphor `hourglass`.
  static const IconData pending = IconData(0xe2b2, fontFamily: fontFamily);

  /// Phosphor `user-plus`.
  static const IconData personAdd = IconData(0xe4d0, fontFamily: fontFamily);

  /// Phosphor `user-minus`.
  static const IconData personRemove = IconData(0xe4ce, fontFamily: fontFamily);

  /// Phosphor `user-focus`.
  static const IconData personSearch = IconData(0xe6fc, fontFamily: fontFamily);

  /// Phosphor `play`.
  static const IconData play = IconData(0xe3d0, fontFamily: fontFamily);

  /// Phosphor `play-circle`.
  static const IconData playCircle = IconData(0xe3d2, fontFamily: fontFamily);

  /// Phosphor `presentation`.
  static const IconData presentation = IconData(0xe654, fontFamily: fontFamily);

  /// Phosphor `globe`.
  static const IconData public = IconData(0xe288, fontFamily: fontFamily);

  /// Phosphor `qr-code`.
  static const IconData qrCode = IconData(0xe3e6, fontFamily: fontFamily);

  /// Phosphor `receipt`.
  static const IconData receipt = IconData(0xe3ec, fontFamily: fontFamily);

  /// Phosphor `arrow-clockwise`.
  static const IconData refresh = IconData(0xe036, fontFamily: fontFamily);

  /// Phosphor `minus-circle`.
  static const IconData remove = IconData(0xe32c, fontFamily: fontFamily);

  /// Phosphor `arrow-counter-clockwise`.
  static const IconData replay = IconData(0xe038, fontFamily: fontFamily);

  /// Phosphor `chat-circle-text`.
  static const IconData review = IconData(0xe16e, fontFamily: fontFamily);

  /// Phosphor `path`.
  static const IconData route = IconData(0xe39c, fontFamily: fontFamily);

  /// Phosphor `scan`.
  static const IconData scan = IconData(0xebb6, fontFamily: fontFamily);

  /// Phosphor `magnifying-glass-minus`.
  static const IconData searchOff = IconData(0xe30e, fontFamily: fontFamily);

  /// Phosphor `paper-plane-right`.
  static const IconData send = IconData(0xe396, fontFamily: fontFamily);

  /// Phosphor `hard-drives`.
  static const IconData server = IconData(0xe2a0, fontFamily: fontFamily);

  /// Phosphor `share-network`.
  static const IconData share = IconData(0xe408, fontFamily: fontFamily);

  /// Phosphor `shield`.
  static const IconData shield = IconData(0xe40a, fontFamily: fontFamily);

  /// Phosphor `signature`.
  static const IconData signature = IconData(0xebac, fontFamily: fontFamily);

  /// Phosphor `speaker-high`.
  static const IconData speaker = IconData(0xe44a, fontFamily: fontFamily);

  /// Phosphor `star`.
  static const IconData star = IconData(0xe46a, fontFamily: fontFamily);

  /// Phosphor `arrows-left-right`.
  static const IconData swap = IconData(0xe0a0, fontFamily: fontFamily);

  /// Phosphor `camera-rotate`.
  static const IconData switchCamera = IconData(0xe7a4, fontFamily: fontFamily);

  /// Phosphor `arrows-clockwise`.
  static const IconData sync = IconData(0xe094, fontFamily: fontFamily);

  /// Phosphor `table`.
  static const IconData table = IconData(0xe476, fontFamily: fontFamily);

  /// Phosphor `tag`.
  static const IconData tag = IconData(0xe478, fontFamily: fontFamily);

  /// Phosphor `terminal-window`.
  static const IconData terminal = IconData(0xeae8, fontFamily: fontFamily);

  /// Phosphor `timer`.
  static const IconData timer = IconData(0xe492, fontFamily: fontFamily);

  /// Phosphor `arrow-u-up-left`.
  static const IconData undo = IconData(0xe08a, fontFamily: fontFamily);

  /// Phosphor `user-check`.
  static const IconData userCheck = IconData(0xeafa, fontFamily: fontFamily);

  /// Phosphor `seal-check`.
  static const IconData verified = IconData(0xe606, fontFamily: fontFamily);

  /// Phosphor `video-camera`.
  static const IconData video = IconData(0xe4da, fontFamily: fontFamily);

  /// Phosphor `file-video`.
  static const IconData videoFile = IconData(0xea22, fontFamily: fontFamily);

  /// Phosphor `video-camera-slash`.
  static const IconData videoOff = IconData(0xe4dc, fontFamily: fontFamily);

  /// Phosphor `eye`.
  static const IconData visible = IconData(0xe220, fontFamily: fontFamily);

  /// Phosphor `globe-simple`.
  static const IconData website = IconData(0xe28e, fontFamily: fontFamily);

  /// Phosphor `wifi-high`.
  static const IconData wifi = IconData(0xe4ea, fontFamily: fontFamily);
}
