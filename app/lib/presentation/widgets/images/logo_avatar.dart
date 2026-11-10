import 'package:flutter/material.dart';

/// A logo in a white ring, as logos are drawn for a light ground;
/// [fallback] when it cannot load.
class LogoAvatar extends StatelessWidget {
  const LogoAvatar({
    super.key,
    required this.url,
    required this.size,
    required this.fallback,
  });

  final Uri url;
  final double size;
  final Widget fallback;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
      ),
      clipBehavior: Clip.antiAlias,
      child: Image.network(
        url.toString(),
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => fallback,
      ),
    );
  }
}
