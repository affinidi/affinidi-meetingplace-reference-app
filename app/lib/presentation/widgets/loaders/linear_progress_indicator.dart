import 'package:flutter/material.dart' hide LinearProgressIndicator;
import 'package:flutter/material.dart'
    as indicator
    show LinearProgressIndicator;

import '../../../infrastructure/extensions/build_context_extensions.dart';

class LinearProgressIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return indicator.LinearProgressIndicator(
      color: context.colorScheme.primary,
      backgroundColor: context.colorScheme.primary.withAlpha(100),
    );
  }
}
