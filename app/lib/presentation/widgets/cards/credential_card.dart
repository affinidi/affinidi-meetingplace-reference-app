import 'package:flutter/material.dart';

class CredentialCard extends StatelessWidget {
  const CredentialCard({
    super.key,
    required this.topLeftText,
    required this.bottomLeftText,
    this.onTap,
  });

  final String topLeftText;
  final String bottomLeftText;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFF0368C0), width: 1),
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            begin: Alignment(-0.5, -0.866),
            end: Alignment(0.5, 0.866),
            colors: [Color(0xFF040822), Color(0xFF0368C0)],
            stops: [0.5705, 0.9362],
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x40000000),
              offset: Offset(0, 25),
              blurRadius: 50,
              spreadRadius: -12,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                topLeftText,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w400,
                ),
              ),
              Text(
                bottomLeftText,
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
