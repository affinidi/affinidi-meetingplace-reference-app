import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:meeting_place_vtc/meeting_place_vtc.dart';

import '../../../application/services/identities_service/identities_service.dart';
import '../../../infrastructure/extensions/build_context_extensions.dart';
import '../../dialogs/qr_code_picker/qr_code_picker.dart';
import '../../themes/tokens/mc_colors.dart';
import '../../themes/tokens/mc_icons.dart';
import '../../themes/tokens/mc_radius.dart';
import '../../themes/tokens/mc_typography.dart';
import '../../widgets/onboarding_style/onboarding_style.dart';
import '../../widgets/vta_identity_card.dart';
import 'vtc_sign_in_controller.dart';
import 'vtc_sign_in_state.dart';

/// Signs the member in to a community's member portal or operator console
/// in a browser: scan the code, type the number, approve with biometrics.
/// In the look of joining a community.
class VtcSignInScreen extends ConsumerWidget {
  const VtcSignInScreen({super.key});

  /// Opens the sign-in over the current screen.
  static Future<void> show(BuildContext context) =>
      Navigator.of(context, rootNavigator: true).push<void>(
        MaterialPageRoute<void>(builder: (context) => const VtcSignInScreen()),
      );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(vtcSignInControllerProvider);
    final controller = ref.read(vtcSignInControllerProvider.notifier);

    if (state.step == VtcSignInStep.scanning) {
      return QrCodePicker(onDetectCode: controller.onScanned);
    }

    void close() => Navigator.of(context).pop();

    return OnboardingLayout(
      onClose: close,
      child: switch (state.step) {
        VtcSignInStep.scanning ||
        VtcSignInStep.working => const Center(child: OnboardingSpinner()),
        VtcSignInStep.confirmMembership => _ConfirmMembership(
          state: state,
          onConfirm: controller.confirmMembership,
          onCancel: close,
        ),
        VtcSignInStep.number => _EnterNumber(
          state: state,
          onSubmit: controller.submitNumber,
          onCancel: () async {
            await controller.decline();
          },
          onExpired: controller.expire,
        ),
        VtcSignInStep.review => _Review(
          state: state,
          onApprove: controller.approve,
          onDecline: controller.decline,
          onExpired: controller.expire,
        ),
        VtcSignInStep.approved => _Outcome(
          icon: McIcons.verified,
          message: Text(
            context.l10n.vtcSignInApproved,
            textAlign: TextAlign.center,
            style: _outcomeStyle(context),
          ),
          onDone: close,
        ),
        VtcSignInStep.declined => _Outcome(
          icon: McIcons.block,
          message: Text(
            context.l10n.vtcSignInDeclined,
            textAlign: TextAlign.center,
            style: _outcomeStyle(context),
          ),
          onDone: close,
        ),
        VtcSignInStep.failed => _Outcome(
          icon: McIcons.error,
          message: OnboardingMessage(
            _failureMessage(context, state),
            isError: true,
          ),
          onDone: close,
        ),
      },
    );
  }

  static TextStyle? _outcomeStyle(BuildContext context) => context
      .textTheme
      .titleMedium
      ?.copyWith(color: context.mcColors.textPrimary);

  static String _failureMessage(BuildContext context, VtcSignInState state) {
    final l10n = context.l10n;
    if (state.isVtaMissing) return l10n.vtcSignInVtaMissing;
    if (state.linkProblem case final problem?) {
      return l10n.vtcSignInLinkProblem(problem.name);
    }
    return l10n.vtcSignInFailure((state.failure ?? SignInFailure.refused).name);
  }
}

class _ConfirmMembership extends StatelessWidget {
  const _ConfirmMembership({
    required this.state,
    required this.onConfirm,
    required this.onCancel,
  });

  final VtcSignInState state;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 12,
      children: [
        OnboardingTitle(l10n.vtcSignInTitle(state.communityName ?? '')),
        OnboardingSubtitle(
          l10n.vtcSignInFoundMembership(state.communityName ?? ''),
        ),
        if (state.personaDid case final did?) _PersonaCard(did),
        const SizedBox(height: 12),
        OnboardingButton(
          label: l10n.vtcSignInUseMembership,
          onPressed: onConfirm,
        ),
        OnboardingTextButton(label: l10n.cancel, onPressed: onCancel),
      ],
    );
  }
}

/// The identity that signs in, as the card joining shows it, with the
/// details of its profile and where it lives on the VTA.
class _PersonaCard extends ConsumerWidget {
  const _PersonaCard(this.did);

  final String did;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final identity = ref.watch(
      identitiesServiceProvider.select(
        (state) => state.identities
            .where((identity) => identity.did == did)
            .firstOrNull,
      ),
    );
    return VtaIdentityCard(
      key: const Key('vtc_sign_in_persona'),
      did: did,
      identity: identity,
    );
  }
}

class _Heading extends StatelessWidget {
  const _Heading({required this.state});

  final VtcSignInState state;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 4,
      children: [
        OnboardingTitle(l10n.vtcSignInTitle(state.communityName ?? '')),
        const SizedBox(height: 4),
        OnboardingSubtitle(l10n.vtcSignInAudience(state.audience.name)),
        OnboardingSubtitle(l10n.vtcSignInWebsite(state.website ?? '')),
      ],
    );
  }
}

/// Seconds left before the decision deadline, counting down; calls
/// [onExpired] once it passes.
int _useSecondsLeft(int? deadline, VoidCallback onExpired) {
  int secondsLeft() =>
      (deadline ?? 0) - DateTime.now().millisecondsSinceEpoch ~/ 1000;
  final left = useState(secondsLeft());

  useEffect(() {
    final timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      left.value = secondsLeft();
      if (left.value <= 0) {
        timer.cancel();
        onExpired();
      }
    });
    return timer.cancel;
  }, [deadline]);

  return left.value < 0 ? 0 : left.value;
}

class _EnterNumber extends HookWidget {
  const _EnterNumber({
    required this.state,
    required this.onSubmit,
    required this.onCancel,
    required this.onExpired,
  });

  final VtcSignInState state;
  final ValueChanged<String> onSubmit;
  final VoidCallback onCancel;
  final VoidCallback onExpired;

  /// The browser shows a two-digit number.
  static const _numberLength = 2;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final number = useState('');
    final secondsLeft = _useSecondsLeft(state.decisionDeadline, onExpired);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 12,
      children: [
        _Heading(state: state),
        const SizedBox(height: 12),
        OnboardingSubtitle(l10n.vtcSignInEnterNumber),
        _DigitBoxes(
          length: _numberLength,
          label: l10n.vtcSignInNumberLabel,
          onChanged: (digits) => number.value = digits,
          onCompleted: onSubmit,
        ),
        if (state.failure == SignInFailure.badNumber)
          OnboardingMessage(
            l10n.vtcSignInFailure(SignInFailure.badNumber.name),
            isError: true,
          ),
        _TimeLeft(secondsLeft),
        const SizedBox(height: 12),
        OnboardingButton(
          label: l10n.vtcSignInContinue,
          onPressed: () => onSubmit(number.value),
        ),
        OnboardingTextButton(label: l10n.cancel, onPressed: onCancel),
      ],
    );
  }
}

/// One box per digit, as a one-time code is typed: typing moves on to the
/// next box, backspace in an empty box goes back, and pasted digits fill the
/// boxes from the one pasted into. Calls [onCompleted] once all are filled.
class _DigitBoxes extends HookWidget {
  const _DigitBoxes({
    required this.length,
    required this.label,
    required this.onChanged,
    required this.onCompleted,
  });

  final int length;

  /// What the boxes hold, for screen readers.
  final String label;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onCompleted;

  static const _boxSize = 56.0;

  @override
  Widget build(BuildContext context) {
    final fields = [
      for (var i = 0; i < length; i++) useTextEditingController(),
    ];
    final focusNodes = [for (var i = 0; i < length; i++) useFocusNode()];

    String digits() => fields.map((field) => field.text).join();

    void changed(int index, String text) {
      // Pasted digits spill over into the boxes after this one.
      for (var i = 0; i < text.length && index + i < length; i++) {
        fields[index + i].text = text[i];
      }
      if (text.isNotEmpty) {
        final next = index + text.length;
        if (next < length) {
          focusNodes[next].requestFocus();
        } else {
          focusNodes[index].unfocus();
        }
      }
      final number = digits();
      onChanged(number);
      if (number.length == length) onCompleted(number);
    }

    KeyEventResult backspace(int index, KeyEvent event) {
      if (index == 0 ||
          event is KeyUpEvent ||
          event.logicalKey != LogicalKeyboardKey.backspace ||
          fields[index].text.isNotEmpty) {
        return KeyEventResult.ignored;
      }
      fields[index - 1].clear();
      focusNodes[index - 1].requestFocus();
      onChanged(digits());
      return KeyEventResult.handled;
    }

    final mc = context.mcColors;
    OutlineInputBorder border(Color color) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(McRadius.md),
      borderSide: BorderSide(color: color),
    );

    return Semantics(
      label: label,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 12,
        children: [
          for (var i = 0; i < length; i++)
            SizedBox(
              width: _boxSize,
              child: Focus(
                onKeyEvent: (_, event) => backspace(i, event),
                child: TextField(
                  key: Key('vtc_sign_in_digit_$i'),
                  controller: fields[i],
                  focusNode: focusNodes[i],
                  autofocus: i == 0,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(length - i),
                  ],
                  onChanged: (text) => changed(i, text),
                  style: McTypography.code.copyWith(color: mc.textPrimary),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: context.colorScheme.surfaceContainerLow,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    border: border(mc.hairlineStrong),
                    enabledBorder: border(mc.hairlineStrong),
                    focusedBorder: border(McColors.blue),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Review extends HookWidget {
  const _Review({
    required this.state,
    required this.onApprove,
    required this.onDecline,
    required this.onExpired,
  });

  final VtcSignInState state;
  final VoidCallback onApprove;
  final VoidCallback onDecline;
  final VoidCallback onExpired;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final requester = state.requester;
    final secondsLeft = _useSecondsLeft(state.decisionDeadline, onExpired);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 12,
      children: [
        _Heading(state: state),
        const SizedBox(height: 12),
        if (state.personaDid case final did?) ...[
          OnboardingSubtitle(l10n.vtcSignInAs),
          _PersonaCard(did),
        ],
        GlassCard(
          title: l10n.vtcSignInReviewHeading,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 12,
            children: [
              // Only what the community could tell; nothing is guessed.
              if ((requester?.browser, requester?.os) case (
                final browser?,
                final os?,
              ))
                OnboardingLine(
                  icon: McIcons.desktop,
                  title: l10n.vtcSignInBrowser(browser, os),
                ),
              if (requester?.location case final location?)
                OnboardingLine(
                  icon: McIcons.location,
                  title: l10n.vtcSignInLocation(location),
                ),
              if (requester?.sameNetwork case final sameNetwork?)
                OnboardingLine(
                  icon: sameNetwork ? McIcons.wifi : McIcons.public,
                  title: sameNetwork
                      ? l10n.vtcSignInSameNetwork
                      : l10n.vtcSignInOtherNetwork,
                ),
              Text(l10n.vtcSignInReportedNote, style: onboardingNote(context)),
            ],
          ),
        ),
        _TimeLeft(secondsLeft),
        const SizedBox(height: 12),
        Row(
          spacing: 12,
          children: [
            Expanded(
              child: OnboardingButton(
                label: l10n.vtcSignInDecline,
                isOutlined: true,
                onPressed: onDecline,
              ),
            ),
            Expanded(
              child: OnboardingButton(
                label: l10n.vtcSignInApprove,
                onPressed: onApprove,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// How many seconds are left to decide, as small print.
class _TimeLeft extends StatelessWidget {
  const _TimeLeft(this.seconds);

  final int seconds;

  @override
  Widget build(BuildContext context) {
    return Text(
      context.l10n.vtcSignInTimeLeft(seconds),
      textAlign: TextAlign.center,
      style: onboardingNote(context),
    );
  }
}

/// How the sign-in ended: a white [icon], the [message], then Done.
class _Outcome extends StatelessWidget {
  const _Outcome({
    required this.icon,
    required this.message,
    required this.onDone,
  });

  final IconData icon;
  final Widget message;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 12,
      children: [
        Icon(icon, size: 72, color: context.mcColors.textPrimary),
        const SizedBox(height: 4),
        message,
        const SizedBox(height: 12),
        OnboardingButton(label: context.l10n.vtcSignInDone, onPressed: onDone),
      ],
    );
  }
}
