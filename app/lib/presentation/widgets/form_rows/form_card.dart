import 'package:flutter/widgets.dart';

import '../../../infrastructure/extensions/build_context_extensions.dart';
import '../common/app_card.dart';

class FormCard extends StatelessWidget {
  const FormCard({
    super.key,
    required String title,
    required Widget child,
    Widget? trailing,
  }) : _title = title,
       _child = child,
       _trailing = trailing;

  final Widget _child;
  final String _title;
  final Widget? _trailing;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_title, style: context.textTheme.titleMedium),
              if (_trailing != null) _trailing,
            ],
          ),
        ),
        AppCard(child: _child),
      ],
    );
  }
}
