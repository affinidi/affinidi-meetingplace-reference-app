import 'package:flutter/foundation.dart';

import '../../../infrastructure/helpers/timed_action.dart';

class TypingTimer {
  TypingTimer({
    required this.memberName,
    required this._maxVisible,
    required this._duration,
    required this._getNames,
    required this._setNames,
    this._onExpired,
  });

  final String memberName;
  final int _maxVisible;
  final Duration _duration;
  final List<String> Function() _getNames;
  final void Function(List<String>) _setNames;
  final VoidCallback? _onExpired;

  TimedAction? _action;

  void start() {
    _action = TimedAction(
      onRun: (_) {
        final names = [..._getNames()];
        if (names.length < _maxVisible && !names.contains(memberName)) {
          names.add(memberName);
          _setNames(names);
        }
      },
      onComplete: () {
        _setNames(_getNames().where((n) => n != memberName).toList());
        _onExpired?.call();
      },
      duration: _duration,
    );
    _action!.start();
  }

  void cancel() => _action?.cancel();
}
