import 'package:flutter/material.dart';
import 'package:mpx_flutter_reference_app/presentation/themes/app_custom_colors.dart';

/// Fake [AppCustomColors] for testing.
class FakeAppCustomColors implements AppCustomColors {
  @override
  Color get callChatItemFromMeBackground => Colors.blue.shade50;

  @override
  Color get callChatItemBackground => Colors.grey.shade100;

  @override
  Color get callChatItemPendingIconContainer => Colors.orange.shade100;

  @override
  Color get callChatItemPendingContent => Colors.orange;

  // Stub all other required methods
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
