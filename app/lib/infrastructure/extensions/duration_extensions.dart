/// Formats a [Duration] as `MM:SS` or `H:MM:SS` for call duration display.
extension CallDurationFormatter on Duration {
  String get label {
    final totalSeconds = inSeconds;
    final h = totalSeconds ~/ 3600;
    final m = ((totalSeconds % 3600) ~/ 60).toString().padLeft(2, '0');
    final s = (totalSeconds % 60).toString().padLeft(2, '0');
    return h > 0 ? '$h:$m:$s' : '$m:$s';
  }
}
