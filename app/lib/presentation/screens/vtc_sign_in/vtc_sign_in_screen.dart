import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:meeting_place_vtc/meeting_place_vtc.dart';

import '../../../infrastructure/extensions/build_context_extensions.dart';
import '../../dialogs/qr_code_picker/qr_code_picker.dart';
import 'vtc_sign_in_controller.dart';
import 'vtc_sign_in_state.dart';

/// Signs the member in to a community's member portal or operator console
/// in a browser: scan the code, type the number, approve with biometrics.
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

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.vtcSignInMenuTitle)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: switch (state.step) {
            VtcSignInStep.scanning || VtcSignInStep.working => const Center(
              child: CircularProgressIndicator(),
            ),
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
              message: context.l10n.vtcSignInApproved,
              onDone: close,
            ),
            VtcSignInStep.declined => _Outcome(
              message: context.l10n.vtcSignInDeclined,
              onDone: close,
            ),
            VtcSignInStep.failed => _Outcome(
              message: _failureMessage(context, state),
              onDone: close,
            ),
          },
        ),
      ),
    );
  }

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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          context.l10n.vtcSignInFoundMembership(
            state.communityName ?? '',
            state.personaDid ?? '',
          ),
          style: context.textTheme.bodyLarge,
        ),
        const Spacer(),
        FilledButton(
          onPressed: onConfirm,
          child: Text(context.l10n.vtcSignInUseMembership),
        ),
        TextButton(onPressed: onCancel, child: Text(context.l10n.cancel)),
      ],
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.vtcSignInTitle(state.communityName ?? ''),
          style: context.textTheme.titleLarge,
        ),
        const SizedBox(height: 4),
        Text(l10n.vtcSignInAudience(state.audience.name)),
        Text(l10n.vtcSignInWebsite(state.website ?? '')),
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

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final number = useTextEditingController();
    final secondsLeft = _useSecondsLeft(state.decisionDeadline, onExpired);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Heading(state: state),
        const SizedBox(height: 24),
        Text(l10n.vtcSignInEnterNumber),
        TextField(
          controller: number,
          autofocus: true,
          keyboardType: TextInputType.number,
          maxLength: 2,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(
            labelText: l10n.vtcSignInNumberLabel,
            errorText: state.failure == SignInFailure.badNumber
                ? l10n.vtcSignInFailure(SignInFailure.badNumber.name)
                : null,
          ),
          onSubmitted: onSubmit,
        ),
        Text(l10n.vtcSignInTimeLeft(secondsLeft)),
        const Spacer(),
        FilledButton(
          onPressed: () => onSubmit(number.text),
          child: Text(l10n.vtcSignInContinue),
        ),
        TextButton(onPressed: onCancel, child: Text(l10n.cancel)),
      ],
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
      children: [
        _Heading(state: state),
        const SizedBox(height: 24),
        Text(l10n.vtcSignInReviewHeading, style: context.textTheme.titleMedium),
        const SizedBox(height: 8),
        Text(l10n.vtcSignInAs(state.personaDid ?? '')),
        if (requester != null) ...[
          const SizedBox(height: 8),
          Text(l10n.vtcSignInBrowser(requester.browser, requester.os)),
          Text(l10n.vtcSignInLocation(requester.location)),
          Text(
            requester.sameNetwork
                ? l10n.vtcSignInSameNetwork
                : l10n.vtcSignInOtherNetwork,
          ),
        ],
        const SizedBox(height: 8),
        Text(l10n.vtcSignInReportedNote, style: context.textTheme.bodySmall),
        Text(l10n.vtcSignInTimeLeft(secondsLeft)),
        const Spacer(),
        FilledButton(onPressed: onApprove, child: Text(l10n.vtcSignInApprove)),
        TextButton(onPressed: onDecline, child: Text(l10n.vtcSignInDecline)),
      ],
    );
  }
}

class _Outcome extends StatelessWidget {
  const _Outcome({required this.message, required this.onDone});

  final String message;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(message, style: context.textTheme.bodyLarge),
        const Spacer(),
        FilledButton(
          onPressed: onDone,
          child: Text(context.l10n.vtcSignInDone),
        ),
      ],
    );
  }
}
