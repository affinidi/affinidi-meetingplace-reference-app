import 'package:flutter/material.dart';

class ElevatedLoadingButton extends StatelessWidget {
  const ElevatedLoadingButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.isLoading = false,
    this.color,
  });

  final VoidCallback? onPressed;
  final Widget child;
  final bool isLoading;
  final Color? color;

  @override
  Widget build(BuildContext context) {
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
