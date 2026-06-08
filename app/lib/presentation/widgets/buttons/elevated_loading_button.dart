import 'package:flutter/material.dart';

class ElevatedLoadingButton extends StatelessWidget {
  const ElevatedLoadingButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.isLoading = false,
    this.color,
    this.isOutlined = false,
  });

  final VoidCallback? onPressed;
  final Widget child;
  final bool isLoading;
  final Color? color;
  final bool isOutlined;

  @override
  Widget build(BuildContext context) {
    if (isOutlined) {
      final borderColor = color ?? Theme.of(context).colorScheme.primary;
      return OutlinedButton(
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: borderColor),
          foregroundColor: borderColor,
        ),
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator.adaptive(),
              )
            : child,
      );
    }
    return ElevatedButton(
      style: ElevatedButton.styleFrom(backgroundColor: color),
      onPressed: isLoading ? null : onPressed,
      child: isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator.adaptive(),
            )
          : child,
    );
  }
}
