import 'package:flutter/material.dart';
import 'package:flutter_hsvcolor_picker/flutter_hsvcolor_picker.dart';

import '../../../../infrastructure/extensions/build_context_extensions.dart';
import '../../../widgets/buttons/elevated_loading_button.dart';

class IdentityCardCustomizerDialog extends StatefulWidget {
  const IdentityCardCustomizerDialog({
    super.key,
    required this.initialColor,
    required this.onColorChanged,
  });

  final Color initialColor;
  final ValueChanged<Color> onColorChanged;

  static Future<Color?> show(
    BuildContext context, {
    required Color initialColor,
  }) async {
    Color? selectedColor = initialColor;
    await showDialog<void>(
      context: context,
      builder: (builderContext) => IdentityCardCustomizerDialog(
        initialColor: initialColor,
        onColorChanged: (color) => selectedColor = color,
      ),
    );
    return selectedColor;
  }

  @override
  State<IdentityCardCustomizerDialog> createState() =>
      _IdentityCardCustomizerDialogState();
}

class _IdentityCardCustomizerDialogState
    extends State<IdentityCardCustomizerDialog> {
  late ValueNotifier<Color> _colorNotifier;

  @override
  void initState() {
    super.initState();
    _colorNotifier = ValueNotifier<Color>(widget.initialColor);
  }

  @override
  void dispose() {
    _colorNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final customColors = context.customColors;

    return AlertDialog(
      backgroundColor: customColors.grey900,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: customColors.grey700),
      ),
      title: Text(
        context.l10n.customiseIdentityCard,
        style: context.textTheme.bodyLarge,
      ),
      content: SingleChildScrollView(
        child: SizedBox(
          width: context.mediaQuery.size.width * 0.9,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ValueListenableBuilder<Color>(
                valueListenable: _colorNotifier,
                builder: (_, color, _) {
                  return ColorPicker(
                    color: color,
                    onChanged: (Color value) {
                      _colorNotifier.value = value;
                      widget.onColorChanged(value);
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        ElevatedLoadingButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Center(child: Text(context.l10n.generalDone)),
        ),
      ],
    );
  }
}
