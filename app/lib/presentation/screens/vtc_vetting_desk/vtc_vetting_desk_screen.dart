import 'dart:async';

import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:meeting_place_vtc/meeting_place_vtc.dart';

import '../../../domain/models/vtc/vtc_vetter_desk.dart';
import '../../../infrastructure/extensions/build_context_extensions.dart';
import '../../effects/confetti/confetti_overlay.dart';
import '../../widgets/onboarding_style/onboarding_style.dart';
import '../../widgets/qr/qr_code_view.dart';
import '../vtc_join/vtc_claim_type_label.dart';
import '../vtc_join/vtc_membership_card_view.dart';
import '../vtc_join/vtc_progress_line.dart';
import '../vtc_join/vtc_trail_step.dart';
import '../vtc_vetter_profile/vtc_vetter_profile_screen.dart';
import 'vtc_vetting_desk_controller.dart';
import 'vtc_vetting_desk_state.dart';

/// The member's vetting desk for a community where they are a vetter: what
/// the community asks vetters to check, showing a ticket, which starts
/// [VtcVettingFlowScreen], the member's vetter card, and the statements
/// they issued.
class VtcVettingDeskScreen extends HookConsumerWidget {
  const VtcVettingDeskScreen({
    super.key,
    required this.communityDid,
    required this.communityName,
  });

  final String communityDid;
  final String communityName;

  static Future<void> show(
    BuildContext context, {
    required String communityDid,
    required String communityName,
  }) => Navigator.of(context, rootNavigator: true).push<void>(
    MaterialPageRoute<void>(
      builder: (context) => VtcVettingDeskScreen(
        communityDid: communityDid,
        communityName: communityName,
      ),
    ),
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(vtcVettingDeskControllerProvider(communityDid));
    final l10n = context.l10n;
    void close() => Navigator.of(context).pop();
    Future<void> showFlow() => VtcVettingFlowScreen.show(
      context,
      communityDid: communityDid,
      communityName: communityName,
    );

    return OnboardingLayout(
      onClose: close,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 12,
        children: [
          OnboardingTitle(l10n.vtcVetterTitle(communityName)),
          ...switch (state.step) {
            VtcVettingDeskStep.loading => [
              const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ],
            VtcVettingDeskStep.notVetter => [
              OnboardingMessage(
                l10n.vtcVetterNotVetter(communityName),
                key: const Key('vtc_vetter_not_vetter'),
                isError: true,
              ),
            ],
            VtcVettingDeskStep.open => [
              OnboardingSubtitle(l10n.vtcVetterIntro),
              if (state.checkingCard || state.readingRequirements)
                _Progress(state: state, communityName: communityName),
              if (!state.readingRequirements)
                _Requirements(
                  requirements: state.requirements,
                  communityName: communityName,
                ),
              if (state.flowStep(clock.now()) != null)
                OnboardingButton(
                  key: const Key('vtc_vetter_resume'),
                  label: l10n.vtcVetterResume,
                  onPressed: showFlow,
                )
              else
                OnboardingButton(
                  key: const Key('vtc_vetter_show_ticket'),
                  label: l10n.vtcVetterShowTicket,
                  onPressed: showFlow,
                ),
              if (state.vetterCard case final card?)
                VtcCardView(
                  cardKey: const Key('vtc_vetter_role_card'),
                  documentKey: const Key('vtc_vetter_role_card_document'),
                  communityName: communityName,
                  title: l10n.vtcVetterCardTitle,
                  credential: card.credential,
                  credentialType: 'AuthorityCredential',
                  documentIcon: Icons.how_to_reg_outlined,
                  holderLabel: l10n.vtcVetterCardHolder,
                  holderDid: card.vetterDid,
                  issuer: card.issuer,
                  validFrom: card.validFrom,
                  validUntil: card.validUntil,
                ),
              OnboardingButton(
                key: const Key('vtc_vetter_profile_open'),
                label: l10n.vtcVetterProfileOpen,
                isOutlined: true,
                onPressed: () => VtcVetterProfileScreen.show(
                  context,
                  communityDid: communityDid,
                  communityName: communityName,
                ),
              ),
              _IssuedList(issued: state.issued),
            ],
          },
          if (state.failure case final failure?)
            OnboardingMessage(
              l10n.vtcVetterFailure(failure.name),
              isError: true,
            ),
          OnboardingTextButton(label: l10n.generalDone, onPressed: close),
        ],
      ),
    );
  }
}

/// Vetting one applicant, a step a page under a progress bar: the ticket
/// for them to scan or type in, the match code, their details to check in
/// person and vouching for them or declining, then how it ended. Closing
/// it leaves the ticket or session open, to come back to from the desk.
/// Opened with neither, it creates the ticket, saying how far it got.
class VtcVettingFlowScreen extends HookConsumerWidget {
  const VtcVettingFlowScreen({
    super.key,
    required this.communityDid,
    required this.communityName,
  });

  final String communityDid;
  final String communityName;

  static Future<void> show(
    BuildContext context, {
    required String communityDid,
    required String communityName,
  }) => Navigator.of(context).push<void>(
    MaterialPageRoute<void>(
      builder: (context) => VtcVettingFlowScreen(
        communityDid: communityDid,
        communityName: communityName,
      ),
    ),
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = vtcVettingDeskControllerProvider(communityDid);
    final state = ref.watch(provider);
    final controller = ref.read(provider.notifier);
    final l10n = context.l10n;
    // Until starting has had its say, the ticket counts as in the making.
    final starting = useState(true);
    useEffect(() {
      // After the first frame: the desk's state cannot change while the
      // page builds.
      unawaited(
        Future(controller.startVetting).whenComplete(() {
          if (context.mounted) starting.value = false;
        }),
      );
      return null;
    }, const []);
    // A ticket no longer live, with no applicant, is shown again from the
    // first step.
    final step = state.flowStep(clock.now()) ?? VtcVettingFlowStep.ticket;
    void close() {
      if (step == VtcVettingFlowStep.done) controller.backToDesk();
      Navigator.of(context).pop();
    }

    return ConfettiOverlay(
      celebrate:
          step == VtcVettingFlowStep.done &&
          state.ended?.status == VtcVetterSessionStatus.issued,
      child: OnboardingLayout(
        onClose: close,
        showBranding: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 12,
          children: [
            OnboardingStepProgress(
              key: const Key('vtc_vetting_flow_progress'),
              step: step.index + 1,
              total: VtcVettingFlowStep.values.length,
              title: l10n.vtcVettingFlowStep(step.name),
            ),
            OnboardingTitle(l10n.vtcVetterTitle(communityName)),
            switch ((step, state.current, state.ended)) {
              (VtcVettingFlowStep.done, _, final ended?) => _Outcome(
                session: ended,
                onDone: close,
              ),
              (VtcVettingFlowStep.match, null, _) => Column(
                key: const Key('vtc_vetter_request_progress'),
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 12,
                children: [
                  OnboardingSubtitle(l10n.vtcVetterApplicantFound),
                  _Steps(
                    steps: VtcRequestStep.values,
                    step: state.requestStep,
                    title: (step) => switch (step) {
                      VtcRequestStep.checkingCard => l10n.vtcVetterStepCard,
                      VtcRequestStep.openingSession =>
                        l10n.vtcVetterStepSession,
                    },
                  ),
                ],
              ),
              (_, final session?, _) => _SessionView(
                // A new applicant starts with nothing chosen or ticked.
                key: ValueKey(session.request.requestId),
                session: session,
                documentClasses: _documentClasses(state.requirements),
                claims: state.cards[session.request.requestId],
                busy: state.busy,
                controller: controller,
              ),
              _ => _TicketView(
                state: state,
                controller: controller,
                creating: starting.value || state.ticketStep != null,
              ),
            },
            if (state.failure case final failure?)
              OnboardingMessage(
                l10n.vtcVetterFailure(failure.name),
                isError: true,
              ),
          ],
        ),
      ),
    );
  }
}

/// How an applicant's session ended, and the way back to the desk.
class _Outcome extends StatelessWidget {
  const _Outcome({required this.session, required this.onDone});

  final VtcVetterSession session;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final vouched = session.status == VtcVetterSessionStatus.issued;
    return Column(
      key: const Key('vtc_vetter_outcome'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 12,
      children: [
        Icon(
          vouched ? Icons.verified : Icons.do_not_disturb_on_outlined,
          size: 72,
          color: Colors.white,
        ),
        Text(
          l10n.vtcVetterOutcome(session.status.name),
          textAlign: TextAlign.center,
          style: context.textTheme.titleMedium?.copyWith(color: Colors.white),
        ),
        OnboardingButton(
          key: const Key('vtc_vetter_outcome_done'),
          label: l10n.vtcVetterBackToDesk,
          onPressed: onDone,
        ),
      ],
    );
  }
}

/// The documents a vetter may say they checked: those the community
/// accepts, of those a vetter can name, or all a vetter can name.
List<String> _documentClasses(VettingRequirements? requirements) {
  final accepted = requirements?.acceptedDocumentClasses;
  final known = VettingVetter.documentClasses;
  if (accepted == null) return known;
  final both = known.where(accepted.contains).toList();
  return both.isEmpty ? known : both;
}

/// What the desk still checks and reads while already open, each step
/// under way or done.
class _Progress extends StatelessWidget {
  const _Progress({required this.state, required this.communityName});

  final VtcVettingDeskState state;
  final String communityName;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    VtcTrailStage stage(bool running) =>
        running ? VtcTrailStage.current : VtcTrailStage.done;
    return VtcBackgroundPanel(
      key: const Key('vtc_vetter_progress'),
      children: [
        VtcProgressLine(
          key: const Key('vtc_vetter_progress_card'),
          title: l10n.vtcVetterStepCard,
          stage: stage(state.checkingCard),
        ),
        VtcProgressLine(
          key: const Key('vtc_vetter_progress_requirements'),
          title: l10n.vtcVetterStepRequirements(communityName),
          stage: stage(state.readingRequirements),
        ),
      ],
    );
  }
}

/// What the community asks the vetter to check, as its join manifest says.
class _Requirements extends StatelessWidget {
  const _Requirements({
    required this.requirements,
    required this.communityName,
  });

  final VettingRequirements? requirements;
  final String communityName;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final asked = requirements?.requiredClaims ?? const <String>[];
    final details = asked.isEmpty ? const ['name.legal'] : asked;
    final documents = requirements?.acceptedDocumentClasses;
    return GlassCard(
      key: const Key('vtc_vetter_requirements'),
      title: l10n.vtcVetterRequirementsHeading(communityName),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 4,
        children: [
          for (final type in details)
            OnboardingLine(
              icon: Icons.badge_outlined,
              title: vtcClaimTypeLabel(l10n, type),
            ),
          if (documents != null && documents.isNotEmpty)
            OnboardingLine(
              icon: Icons.description_outlined,
              title: l10n.vtcVetterRequirementsDocuments(
                [
                  for (final document in documents)
                    l10n.vtcVetterDocument(document),
                ].join(', '),
              ),
            ),
          Text(
            l10n.vtcVetterRequirementsInPerson,
            style: onboardingNote(context),
          ),
        ],
      ),
    );
  }
}

/// The ticket on show while it is live, else a way to show one.
class _TicketView extends StatelessWidget {
  const _TicketView({
    required this.state,
    required this.controller,
    required this.creating,
  });

  static const _qrSize = 200.0;

  final VtcVettingDeskState state;
  final VtcVettingDeskController controller;

  /// Whether the ticket is being created, so none is on show yet.
  final bool creating;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final ticket = state.liveTicket(clock.now());

    if (ticket != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 12,
        children: [
          GlassCard(
            title: l10n.vtcVetterTicketHeading,
            child: Column(
              spacing: 12,
              children: [
                ColoredBox(
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    // A fixed size: the layout measures its content's
                    // height, which the QR code cannot report.
                    child: SizedBox.square(
                      dimension: _qrSize,
                      child: QrCodeView(
                        key: const Key('vtc_vetter_ticket_qr'),
                        data: '${ticket.scanned}',
                        size: _qrSize,
                      ),
                    ),
                  ),
                ),
                Text(
                  l10n.vtcVetterTicketCodeHint,
                  style: onboardingNote(context),
                ),
                SelectableText(
                  ticket.code,
                  key: const Key('vtc_vetter_ticket_code'),
                  style: context.textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontFamily: 'monospace',
                    letterSpacing: 4,
                  ),
                ),
                Text(
                  l10n.vtcVetterTicketValid(
                    MaterialLocalizations.of(context).formatTimeOfDay(
                      TimeOfDay.fromDateTime(ticket.expiresAt.toLocal()),
                    ),
                  ),
                  style: onboardingNote(context),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          VtcWaitingForParty(l10n.vtcVetterWaiting),
          OnboardingButton(
            key: const Key('vtc_vetter_new_ticket'),
            label: l10n.vtcVetterNewTicket,
            isOutlined: true,
            isLoading: state.busy,
            onPressed: controller.createTicket,
          ),
        ],
      );
    }

    if (creating) {
      return _Steps(
        key: const Key('vtc_vetter_ticket_progress'),
        steps: VtcTicketStep.values,
        step: state.ticketStep,
        title: (step) => switch (step) {
          VtcTicketStep.checkingCard => l10n.vtcVetterStepCard,
          VtcTicketStep.creating => l10n.vtcVetterStepTicket,
        },
      );
    }

    // The ticket ran out or was used up, with no applicant to vet.
    return OnboardingButton(
      key: const Key('vtc_vetter_new_ticket'),
      label: l10n.vtcVetterNewTicket,
      isLoading: state.busy,
      onPressed: controller.createTicket,
    );
  }
}

/// Steps the flow takes in the background, in order: each done, under
/// way, or still to come.
class _Steps<T extends Enum> extends StatelessWidget {
  const _Steps({
    super.key,
    required this.steps,
    required this.step,
    required this.title,
  });

  final List<T> steps;

  /// The step under way; none yet means the first is about to start.
  final T? step;
  final String Function(T step) title;

  @override
  Widget build(BuildContext context) {
    final current = step ?? steps.first;
    return VtcBackgroundPanel(
      children: [
        for (final step in steps)
          VtcProgressLine(
            key: Key('vtc_vetter_step_${step.name}'),
            title: title(step),
            stage: switch (step.index.compareTo(current.index)) {
              < 0 => VtcTrailStage.done,
              0 => VtcTrailStage.current,
              _ => VtcTrailStage.next,
            },
          ),
      ],
    );
  }
}

/// One applicant's session: the match code until the vetter confirms it,
/// then the applicant's details to check in person, the document checked,
/// and vouching for them or declining.
class _SessionView extends HookWidget {
  const _SessionView({
    super.key,
    required this.session,
    required this.documentClasses,
    required this.claims,
    required this.busy,
    required this.controller,
  });

  final VtcVetterSession session;

  /// The documents the vetter may say they checked.
  final List<String> documentClasses;
  final List<VettingCardClaim>? claims;
  final bool busy;
  final VtcVettingDeskController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final requestId = session.request.requestId;
    final document = useState<String?>(null);
    final checked = useState(false);

    if (!session.matchConfirmed) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 12,
        children: [
          OnboardingSubtitle(l10n.vtcJoinMatchTitle),
          Text(l10n.vtcVetterMatchIntro, style: onboardingNote(context)),
          GlassCard(
            title: l10n.vtcJoinMatchCodeHeading,
            child: Text(
              session.session?.matchCode ?? '',
              key: const Key('vtc_vetter_match_code'),
              textAlign: TextAlign.center,
              style: context.textTheme.displaySmall?.copyWith(
                color: Colors.white,
                fontFamily: 'monospace',
                letterSpacing: 4,
              ),
            ),
          ),
          OnboardingButton(
            key: const Key('vtc_vetter_match_yes'),
            label: l10n.vtcJoinMatchYes,
            isLoading: busy,
            onPressed: () => controller.confirmMatch(requestId),
          ),
          OnboardingTextButton(
            key: const Key('vtc_vetter_match_no'),
            label: l10n.vtcJoinMatchNo,
            onPressed: () => controller.mismatch(requestId),
          ),
        ],
      );
    }

    final details = claims;
    final decline = OnboardingTextButton(
      key: const Key('vtc_vetter_decline'),
      label: l10n.vtcVetterDecline,
      onPressed: () => controller.decline(requestId, code: 'couldNotVerify'),
    );
    if (details == null) {
      // The applicant may never send their details, e.g. when their
      // identity lacks one: the vetter can always end the session.
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 12,
        children: [
          VtcWaitingForParty(
            l10n.vtcVetterCardWaiting,
            key: const Key('vtc_vetter_card_waiting'),
          ),
          decline,
        ],
      );
    }

    final chosen = document.value;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 12,
      children: [
        GlassCard(
          key: const Key('vtc_vetter_card'),
          title: l10n.vtcVetterCardHeading,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 8,
            children: [
              Text(l10n.vtcVetterCardIntro, style: onboardingNote(context)),
              for (final claim in details)
                OnboardingLine(
                  icon: Icons.badge_outlined,
                  title: vtcClaimTypeLabel(l10n, claim.type),
                  subtitle: '${claim.value}',
                ),
            ],
          ),
        ),
        Text(
          l10n.vtcVetterDocumentHeading,
          style: context.textTheme.titleSmall?.copyWith(color: Colors.white),
        ),
        // A column, not a wrap: the layout measures its content's height as
        // if a wrap fitted on one line.
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final documentClass in documentClasses)
              ChoiceChip(
                key: Key('vtc_vetter_document_$documentClass'),
                label: Text(l10n.vtcVetterDocument(documentClass)),
                selected: chosen == documentClass,
                onSelected: (_) => document.value = documentClass,
              ),
          ],
        ),
        InkWell(
          key: const Key('vtc_vetter_checked'),
          onTap: () => checked.value = !checked.value,
          child: Row(
            children: [
              Checkbox(
                value: checked.value,
                onChanged: (value) => checked.value = value ?? false,
              ),
              Expanded(
                child: Text(
                  l10n.vtcVetterCheckedInPerson,
                  style: onboardingNote(context),
                ),
              ),
            ],
          ),
        ),
        OnboardingButton(
          key: const Key('vtc_vetter_issue'),
          label: l10n.vtcVetterIssue,
          isLoading: busy,
          onPressed: chosen != null && checked.value
              ? () => controller.issue(requestId, [chosen])
              : null,
        ),
        decline,
      ],
    );
  }
}

/// The statements the member issued for the community, as their VTA keeps
/// them.
class _IssuedList extends StatelessWidget {
  const _IssuedList({required this.issued});

  final List<IssuedVettingStatement> issued;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final dates = MaterialLocalizations.of(context);
    return GlassCard(
      key: const Key('vtc_vetter_issued'),
      title: l10n.vtcVetterIssuedHeading,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 4,
        children: [
          if (issued.isEmpty)
            Text(l10n.vtcVetterIssuedNone, style: onboardingNote(context)),
          for (final statement in issued)
            OnboardingLine(
              icon: Icons.verified_outlined,
              title: l10n.vtcVetterIssuedLine(
                dates.formatMediumDate(statement.issuedAt.toLocal()),
                dates.formatMediumDate(statement.validUntil.toLocal()),
              ),
            ),
        ],
      ),
    );
  }
}
