/// Extension methods on [String] for handling emoji content.
extension StringEmoji on String {
  /// Returns the number of emojis in the string.
  ///
  /// Each emoji is counted as one, including compound emojis.
  int get countEmojis {
    // This counts each emoji as one, including compound emojis
    final emojiPattern = RegExp(
      r'(?:[\u{1F300}-\u{1F9FF}]|[\u{2600}-\u{26FF}]|[\u{2700}-\u{27BF}]|'
      r'[\u{1F100}-\u{1F1FF}]|[\u{1F200}-\u{1F2FF}]|[\u{1F900}-\u{1F9FF}]|'
      r'[\u{1F000}-\u{1F02F}]|[\u{1F0A0}-\u{1F0FF}]|[\u{1F300}-\u{1F5FF}]|'
      r'[\u{1F600}-\u{1F64F}]|[\u{1F680}-\u{1F6FF}]|[\u{1F700}-\u{1F77F}]|'
      r'[\u{1F780}-\u{1F7FF}]|[\u{1F800}-\u{1F8FF}]|[\u{1F900}-\u{1F9FF}]|'
      r'[\u{1FA00}-\u{1FA6F}]|[\u{1FA70}-\u{1FAFF}])',
      unicode: true,
    );

    return emojiPattern.allMatches(this).length;
  }

  /// Returns `true` if the string contains only emojis
  ///  (and optional whitespace).
  ///
  /// Supports common emojis, including ZWJ sequences and variation selectors.
  bool get isOnlyEmojis {
    // This pattern matches common emoji including ZWJ sequences and variation
    // selectors
    final emojiPattern = RegExp(
      r'^(?:[\u{1F300}-\u{1F9FF}]|[\u{2600}-\u{26FF}]|[\u{2700}-\u{27BF}]|'
      r'[\u{1F100}-\u{1F1FF}]|[\u{1F200}-\u{1F2FF}]|[\u{1F900}-\u{1F9FF}]|'
      r'[\u{1F000}-\u{1F02F}]|[\u{1F0A0}-\u{1F0FF}]|[\u{1F300}-\u{1F5FF}]|'
      r'[\u{1F600}-\u{1F64F}]|[\u{1F680}-\u{1F6FF}]|[\u{1F700}-\u{1F77F}]|'
      r'[\u{1F780}-\u{1F7FF}]|[\u{1F800}-\u{1F8FF}]|[\u{1F900}-\u{1F9FF}]|'
      r'[\u{1FA00}-\u{1FA6F}]|[\u{1FA70}-\u{1FAFF}]|[\u{FE00}-\u{FE0F}]|'
      r'[\u{E0020}-\u{E007F}]|[\u{2194}-\u{2199}]|[\u{21A9}-\u{21AA}]|'
      r'[\u{231A}-\u{231B}]|[\u{23E9}-\u{23EC}]|[\u{23F0}]|[\u{23F3}]|'
      r'[\u{25AA}-\u{25AB}]|[\u{25B6}]|[\u{25C0}]|[\u{25FB}-\u{25FE}]|'
      r'[\u{2600}-\u{2604}]|[\u{260E}]|[\u{2611}]|[\u{2614}-\u{2615}]|'
      r'[\u{2618}]|[\u{261D}]|[\u{2620}]|[\u{2622}-\u{2623}]|[\u{2626}]|'
      r'[\u{262A}]|[\u{262E}-\u{262F}]|[\u{2638}-\u{263A}]|[\u{2640}]|'
      r'[\u{2642}]|[\u{2648}-\u{2653}]|[\u{265F}-\u{2660}]|[\u{2663}]|'
      r'[\u{2665}-\u{2666}]|[\u{2668}]|[\u{267B}]|[\u{267E}-\u{267F}]|'
      r'[\u{2692}-\u{2697}]|[\u{2699}]|[\u{269B}-\u{269C}]|[\u{26A0}-\u{26A1}]|'
      r'[\u{26A7}]|[\u{26AA}-\u{26AB}]|[\u{26B0}-\u{26B1}]|[\u{26BD}-\u{26BE}]|'
      r'[\u{26C4}-\u{26C5}]|[\u{26C8}]|[\u{26CE}-\u{26CF}]|[\u{26D1}]|'
      r'[\u{26D3}-\u{26D4}]|[\u{26E9}-\u{26EA}]|[\u{26F0}-\u{26F5}]|'
      r'[\u{26F7}-\u{26FA}]|[\u{26FD}]|[\u{2702}]|[\u{2705}]|[\u{2708}-\u{270D}]|'
      r'[\u{270F}]|\s)*$',
      unicode: true,
    );

    return emojiPattern.hasMatch(this);
  }
}
