import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../infrastructure/extensions/build_context_extensions.dart';
import '../../../infrastructure/extensions/color_extensions.dart';
import '../../helpers/screensize_helper.dart';
import 'mnemonic_screen_controller.dart';

class MnemonicScreen extends HookConsumerWidget {
  const MnemonicScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;

    final provider = mnemonicScreenControllerProvider;
    final state = ref.watch(provider);
    final controller = ref.read(provider.notifier);

    final mnemonicController = useTextEditingController();
    final isSmallScreenLandscape =
        ScreensizeHelper().isSmallScreen(context) &&
        ScreensizeHelper().isLandscape(context);

    final screenWidth = MediaQuery.of(context).size.width;
    final radius = screenWidth > 1024 ? 6.0 : 2.0;

    Future<void> onContinue() async {
      final saved = await controller.saveMnemonic(mnemonicController.text);
      if (saved && context.mounted) {
        context.go('/');
      }
    }

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.bottomCenter,
            radius: radius,
            colors: [
              colorScheme.primary.withLightness(0.3),
              colorScheme.primary.withAlpha(249),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height -
                    MediaQuery.of(context).padding.top -
                    MediaQuery.of(context).padding.bottom,
              ),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: isSmallScreenLandscape ? 24 : 48),
                    SizedBox(
                      height: isSmallScreenLandscape ? 64 : 96,
                      child: Image.asset(
                        'assets/images/meeting-place-splash-white-1024.png',
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Meeting Place',
                      textAlign: TextAlign.center,
                      style: textTheme.bodyLarge,
                    ),
                    SizedBox(height: isSmallScreenLandscape ? 24 : 40),
                    Text(
                      'Enter your mnemonic',
                      textAlign: TextAlign.center,
                      style: textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Enter your 12 or 24 word mnemonic phrase to access'
                      ' your wallet.',
                      textAlign: TextAlign.center,
                      style: textTheme.bodyMedium?.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextField(
                      controller: mnemonicController,
                      maxLines: 4,
                      minLines: 3,
                      keyboardType: TextInputType.multiline,
                      textInputAction: TextInputAction.newline,
                      autocorrect: false,
                      enableSuggestions: false,
                      style: textTheme.bodyMedium?.copyWith(
                        color: Colors.white,
                      ),
                      decoration: InputDecoration(
                        hintText: 'word1 word2 word3 ...',
                        hintStyle: textTheme.bodyMedium?.copyWith(
                          color: Colors.white38,
                        ),
                        filled: true,
                        fillColor: Colors.white.withAlpha(25),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Colors.white.withAlpha(76),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Colors.white.withAlpha(76),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.white),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: colorScheme.error,
                          ),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: colorScheme.error,
                          ),
                        ),
                        errorText: state.isError ? state.errorMessage : null,
                        errorStyle: textTheme.bodySmall?.copyWith(
                          color: colorScheme.error,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    if (state.isLoading)
                      const Center(
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator.adaptive(
                            backgroundColor: Colors.white,
                          ),
                        ),
                      )
                    else
                      ElevatedButton(
                        onPressed: onContinue,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: colorScheme.primary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Continue',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    const Spacer(),
                    Padding(
                      padding: EdgeInsets.only(
                        bottom: isSmallScreenLandscape ? 16 : 32,
                        top: 24,
                      ),
                      child: Center(
                        child: SizedBox(
                          height: 40,
                          child: Image.asset('assets/images/powered_by_mpx.png'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
