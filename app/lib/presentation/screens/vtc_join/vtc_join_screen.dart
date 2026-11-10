import 'dart:ui';

import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:meeting_place_vtc/meeting_place_vtc.dart';

import '../../../domain/models/vtc/vtc_community.dart';
import '../../../domain/models/vtc/vtc_left_membership.dart';
import '../../../domain/models/vtc/vtc_vetting.dart';
import '../../../infrastructure/extensions/build_context_extensions.dart';
import '../../../infrastructure/services/camera_service/camera_service.dart';
import '../../../l10n/app_localizations.dart';
import '../../dialogs/qr_code_picker/qr_code_picker.dart';
import '../../effects/confetti/confetti_overlay.dart';
import '../../themes/tokens/mc_colors.dart';
import '../../themes/tokens/mc_icons.dart';
import '../../themes/tokens/mc_radius.dart';
import '../../themes/tokens/mc_spacing.dart';
import '../../themes/tokens/mc_typography.dart';
import '../../widgets/common/app_card.dart';
import '../../widgets/onboarding_style/onboarding_style.dart';
import '../../widgets/swipeable_cards.dart';
import '../../widgets/vta_identity_card.dart';
import 'vtc_claim_type_label.dart';
import 'vtc_community_page.dart';
import 'vtc_community_profile.dart';
import 'vtc_join_controller.dart';
import 'vtc_join_json_dialog.dart';
import 'vtc_join_state.dart';
import 'vtc_join_trail.dart';
import 'vtc_progress_line.dart';
import 'vtc_trail_step.dart';
import 'vtc_vetter_details.dart';

/// Joins a community: scan its code or enter its DID, read what it asks,
/// apply as an identity from the member's VTA. In the look of linking the
/// VTA, the review laid out like a consent screen.
class VtcJoinScreen extends HookConsumerWidget {
  const VtcJoinScreen({super.key, this.code})
    : leaveCommunityDid = null,
      leaveCommunityName = null;

  const VtcJoinScreen._leaving({
    required String communityDid,
    required String communityName,
  }) : code = null,
       leaveCommunityDid = communityDid,
       leaveCommunityName = communityName;

  /// The code of the community to open at once, as if it were scanned: its
  /// DID or join phrase; null to ask for a code.
  final String? code;

  /// The community to leave at once, and its name; null unless leaving.
  final String? leaveCommunityDid;
  final String? leaveCommunityName;

  /// Opens joining over the current screen, at the community of [code] if
  /// given.
  static Future<void> show(BuildContext context, {String? code}) =>
      Navigator.of(context, rootNavigator: true).push<void>(
        MaterialPageRoute<void>(
          builder: (context) => VtcJoinScreen(code: code),
        ),
      );

  /// Leaves the community of [communityDid] over the current screen,
  /// showing its steps and the outcome. Ask the member to confirm first,
  /// with [confirmLeaveCommunity].
  static Future<void> showLeaving(
    BuildContext context, {
    required String communityDid,
    required String communityName,
  }) => Navigator.of(context, rootNavigator: true).push<void>(
    MaterialPageRoute<void>(
      builder: (context) => VtcJoinScreen._leaving(
        communityDid: communityDid,
        communityName: communityName,
      ),
    ),
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(vtcJoinControllerProvider);
    final controller = ref.read(vtcJoinControllerProvider.notifier);
    useEffect(() {
      if (code case final code?) {
        // Not while building: reading the community changes the state.
        Future.microtask(() => controller.onScanned(code));
      }
      if (leaveCommunityDid case final did?) {
        // Not while building: leaving changes the state.
        Future.microtask(
          () => controller.leaveCommunity(
            did,
            communityName: leaveCommunityName ?? '',
          ),
        );
      }
      return null;
    }, const []);
    final l10n = context.l10n;
    final name = state.communityName ?? '';
    void close() => Navigator.of(context).pop();

    if (state.applicantStep case final step?) {
      final request = state.vetting?.requestTo(state.flowVetterDid ?? '');
      return ConfettiOverlay(
        celebrate:
            step == VtcApplicantStep.done &&
            request?.status == VtcVettingStatus.vouched,
        child: OnboardingLayout(
          onClose: close,
          showBranding: false,
          child: _VettingFlow(state: state, step: step, controller: controller),
        ),
      );
    }

    return OnboardingLayout(
      onClose: close,
      // Meeting a vetter is the first step of the vetting flow.
      showBranding: state.step != VtcJoinStep.vetting,
      child: switch (state.step) {
        VtcJoinStep.scanning => _EnterCode(onSubmit: controller.onScanned),
        VtcJoinStep.working => switch ((
          state.openStep,
          state.leaveStep,
          state.applyStep,
        )) {
          (final step?, _, _) => Center(child: _Opening(step: step)),
          (_, final step?, _) => Center(
            child: _Leaving(step: step, communityName: name),
          ),
          (_, _, final step?) => Center(
            child: _Applying(
              step: step,
              communityName: name,
              withCredential: state.sharedCredential != null,
            ),
          ),
          _ => const Center(child: OnboardingSpinner()),
        },
        VtcJoinStep.review => _Review(
          state: state,
          onJoin: controller.join,
          onListInDirectory: controller.setListInDirectory,
          onChooseWay: controller.chooseWay,
          onCancel: close,
        ),
        VtcJoinStep.chooseIdentity => _ChooseIdentity(
          state: state,
          onChoose: controller.useIdentity,
          onCancel: close,
        ),
        VtcJoinStep.approveDetails => _ApproveDetails(
          state: state,
          onShare: controller.approveDetails,
          onCancel: close,
        ),
        VtcJoinStep.approveCredential => _ApproveCredential(
          state: state,
          onShare: controller.approveCredential,
          onCancel: close,
        ),
        VtcJoinStep.vetting => _Vetting(
          state: state,
          onScan: controller.scanVettingTicket,
          onEnterCode: controller.enterVettingCode,
          onSend: controller.sendVettedApplication,
          onStop: () async {
            if (await _confirm(
              context,
              title: l10n.vtcJoinVettingStopTitle(name),
              message: l10n.vtcJoinVettingStopMessage,
              action: l10n.vtcJoinVettingStopAction,
            )) {
              await controller.stopVetting();
            }
          },
          onDone: close,
        ),
        // Shown step by step above, as being vetted by one vetter.
        VtcJoinStep.chooseVetter ||
        VtcJoinStep.enterVettingCode ||
        VtcJoinStep.confirmMatch ||
        VtcJoinStep.approveVettingCard => const SizedBox.shrink(),
        VtcJoinStep.joined => VtcCommunityPage(
          state: state,
          onDone: close,
          leave: OnboardingButton(
            label: l10n.vtcJoinLeaveAction,
            isOutlined: true,
            onPressed: () async {
              if (await confirmLeaveCommunity(context, name)) {
                await controller.leave();
              }
            },
          ),
        ),
        VtcJoinStep.left => _Outcome(
          icon: McIcons.logout,
          message: l10n.vtcJoinLeft(name),
          onDone: close,
        ),
        VtcJoinStep.pending => _Pending(
          state: state,
          onCheckAgain: controller.checkAgain,
          onWithdraw: () async {
            if (await _confirm(
              context,
              title: l10n.vtcJoinWithdrawTitle(name),
              message: l10n.vtcJoinWithdrawMessage,
              action: l10n.vtcJoinWithdrawAction,
            )) {
              await controller.withdraw();
            }
          },
          onDone: close,
        ),
        VtcJoinStep.withdrawn => _Outcome(
          icon: McIcons.undo,
          message: l10n.vtcJoinWithdrawn(name),
          trail: VtcWithdrawStep(
            communityName: name,
            exchange: state.withdrawExchange,
          ),
          onDone: close,
          secondary: OnboardingButton(
            label: l10n.vtcJoinApplyAgain,
            isOutlined: true,
            onPressed: controller.applyAgain,
          ),
        ),
        VtcJoinStep.denied => _Outcome(
          icon: McIcons.block,
          message: switch (state.denialReason) {
            final reason? => l10n.vtcJoinDeniedWithReason(name, reason),
            null => l10n.vtcJoinDenied(name),
          },
          onDone: close,
        ),
        VtcJoinStep.needsMore => _Outcome(
          icon: McIcons.info,
          message: l10n.vtcJoinNeedsMore,
          onDone: close,
        ),
        VtcJoinStep.failed => _Failed(
          message: switch (state.missingDetails) {
            final missing
                when state.failure == VtcJoinFailure.detailsMissing &&
                    missing.isNotEmpty =>
              l10n.vtcJoinVettingDetailsMissing(
                switch (state.applyingIdentityName) {
                  final name? => l10n.vtcJoinApplyingIdentityNamed(name),
                  null => l10n.vtcJoinApplyingIdentityCreated,
                },
                missing.map((type) => vtcClaimTypeLabel(l10n, type)).join(', '),
              ),
            _ => l10n.vtcJoinFailure(
              (state.failure ?? VtcJoinFailure.refused).name,
            ),
          },
          onRetry: controller.restart,
          onCancel: close,
        ),
      },
    );
  }
}

/// Asks the member to confirm leaving the community named [name].
Future<bool> confirmLeaveCommunity(BuildContext context, String name) {
  final l10n = context.l10n;
  return _confirm(
    context,
    title: l10n.vtcJoinLeaveTitle(name),
    message: l10n.vtcJoinLeaveMessage,
    action: l10n.vtcJoinLeaveAction,
  );
}

/// Asks the member to confirm a step that cannot be undone, such as
/// leaving a community, under [title] and [message], with [action] as the
/// button that goes ahead.
Future<bool> _confirm(
  BuildContext context, {
  required String title,
  required String message,
  required String action,
}) async {
  final l10n = context.l10n;
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(l10n.generalCancel),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: context.destructiveElevatedButtonStyle,
          child: Text(action),
        ),
      ],
    ),
  );
  return confirmed ?? false;
}

/// Shows the community's join manifest as it sent it.
Future<void> _showManifest(
  BuildContext context,
  Map<String, dynamic> manifest,
) => showVtcJoinJson(
  context,
  title: context.l10n.vtcJoinManifestHeading,
  json: manifest,
  textKey: const Key('vtc_join_manifest_json'),
);

/// Takes a community's code: its DID typed or pasted, or its QR code
/// scanned. Both are read the same way.
class _EnterCode extends HookConsumerWidget {
  const _EnterCode({required this.onSubmit});

  final ValueChanged<String> onSubmit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final field = useTextEditingController();
    useListenable(field);
    final code = field.text.trim();
    final hasCamera = ref.watch(
      cameraServiceProvider.select((state) => state.isAvailable ?? false),
    );

    void submit(String text) {
      FocusManager.instance.primaryFocus?.unfocus();
      if (text.trim().isNotEmpty) onSubmit(text.trim());
    }

    Future<void> scan() async {
      final data = await QrCodePicker.show(context: context);
      if (data != null) submit(data);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        OnboardingTitle(l10n.vtcJoinIntroTitle),
        const SizedBox(height: 8),
        OnboardingSubtitle(l10n.vtcJoinIntro),
        const SizedBox(height: 24),
        OnboardingTextField(
          key: const Key('vtc_join_did'),
          controller: field,
          label: l10n.vtcJoinDidHint,
          hint: 'did:webvh:… · my-club',
          onSubmitted: submit,
          suffixIcon: IconButton(
            tooltip: l10n.vtcJoinPasteAction,
            icon: const Icon(McIcons.paste),
            onPressed: () async {
              final data = await Clipboard.getData(Clipboard.kTextPlain);
              if (data?.text case final text?) field.text = text.trim();
            },
          ),
        ),
        const SizedBox(height: 24),
        OnboardingButton(
          label: l10n.vtcJoinContinueAction,
          onPressed: code.isEmpty ? null : () => submit(code),
        ),
        const SizedBox(height: 12),
        OnboardingButton(
          label: l10n.vtcJoinScanAction,
          isOutlined: true,
          onPressed: hasCamera ? scan : null,
        ),
      ],
    );
  }
}

/// What joining means, laid out like a consent screen: who asks, what the
/// community gets and shows, how to get in, and whether to trust it.
class _Review extends StatelessWidget {
  const _Review({
    required this.state,
    required this.onJoin,
    required this.onListInDirectory,
    required this.onChooseWay,
    required this.onCancel,
  });

  final VtcJoinState state;
  final VoidCallback onJoin;
  final ValueChanged<bool> onListInDirectory;
  final ValueChanged<String> onChooseWay;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final did = state.communityDid ?? '';
    // The name falls back to the DID, which the profile card shows.
    final name = state.communityName;
    final hasName = name != null && name.isNotEmpty && name != did;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 12,
      children: [
        if (state.logoUrl case final logoUrl?) VtcCommunityLogo(logoUrl),
        OnboardingTitle(
          hasName ? name : l10n.vtcJoinUnnamedCommunity,
          trailing: state.manifest.isEmpty
              ? null
              : IconButton(
                  key: const Key('vtc_join_manifest'),
                  icon: Icon(McIcons.code, color: context.mcColors.textPrimary),
                  tooltip: l10n.vtcJoinShowManifest,
                  onPressed: () => _showManifest(context, state.manifest),
                ),
        ),
        OnboardingSubtitle(l10n.vtcJoinWantsYou),
        Center(child: _Pill(l10n.vtcJoinWithVtaIdentity)),
        VtcCommunityProfile(
          communityDid: state.communityDid ?? '',
          description: state.description,
          website: state.website,
          contactEmail: state.contactEmail,
        ),
        if (state.denialReason case final reason?)
          OnboardingMessage(l10n.vtcJoinLastDenied(reason), isError: true),
        if (!state.canApply)
          OnboardingMessage(
            l10n.vtcJoinNoSupportedWay(
              hasName ? name : l10n.vtcJoinThisCommunity,
            ),
            isError: false,
          )
        else
          _Consent(
            state: state,
            communityName: hasName ? name : l10n.vtcJoinThisCommunity,
            onListInDirectory: onListInDirectory,
          ),
        _WaysIn(state: state, onChoose: onChooseWay),
        const SizedBox(height: 12),
        Row(
          spacing: 12,
          children: [
            Expanded(
              child: OnboardingButton(
                label: l10n.generalCancel,
                isOutlined: true,
                onPressed: onCancel,
              ),
            ),
            Expanded(
              child: OnboardingButton(
                label: l10n.vtcJoinAction,
                onPressed:
                    state.ways.any(
                      (way) => way.id == state.chosenWayId && way.canApply,
                    )
                    ? onJoin
                    : null,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// A rounded, outlined label, such as which identity joins.
class _Pill extends StatelessWidget {
  const _Pill(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final mc = context.mcColors;
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: mc.hairlineStrong),
        borderRadius: BorderRadius.circular(McRadius.full),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 6,
          children: [
            Icon(McIcons.account, size: 18, color: mc.textSecondary),
            Flexible(
              child: Text(
                text,
                style: context.textTheme.bodySmall?.copyWith(
                  color: mc.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// What the community gets and shows once the member joins, one line each,
/// with the member directory's switch below.
class _Consent extends StatelessWidget {
  const _Consent({
    required this.state,
    required this.communityName,
    required this.onListInDirectory,
  });

  final VtcJoinState state;
  final String communityName;
  final ValueChanged<bool> onListInDirectory;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final disclosure = state.directoryDisclosure;
    final items = [
      for (final detail in state.requestedDetails)
        _ConsentItem(
          icon: McIcons.badge,
          title: l10n.vtcJoinReceivesDetail(
            vtcClaimTypeLabel(l10n, detail.type),
          ),
          subtitle: detail.required
              ? l10n.vtcJoinDetailRequiredNote
              : l10n.vtcJoinDetailOptionalNote,
          details: [
            if (detail.purpose case final purpose?) _Note(purpose),
            _Note(l10n.vtcJoinDetailsNote),
          ],
        ),
      if (disclosure != null) ..._audienceItems(context, disclosure),
      if (disclosure?.adminNotes ?? false)
        _ConsentItem(
          icon: McIcons.note,
          title: l10n.vtcJoinKeepsNotes,
          details: [_Note(l10n.vtcJoinAdminNotesDetail)],
        ),
    ];

    return GlassCard(
      title: l10n.vtcJoinConsentHeading(communityName),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final item in items) ...[item, const _Divider()],
          if (state.listsNewMembers case final listed?)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                listed
                    ? l10n.vtcJoinDirectoryListed
                    : l10n.vtcJoinDirectoryHidden,
                style: onboardingNote(context),
              ),
            ),
          if (state.listsNewMembers != false)
            // A Row, not a SwitchListTile: the onboarding layout measures
            // intrinsic heights, which a ListTile misreports.
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 2,
                    children: [
                      Text(
                        l10n.vtcJoinListMe,
                        style: TextStyle(color: context.mcColors.textPrimary),
                      ),
                      Text(
                        l10n.vtcJoinListMeNote,
                        style: onboardingNote(context),
                      ),
                      if (disclosure?.externalCards ?? false)
                        Text(
                          l10n.vtcJoinExternalCards,
                          style: onboardingNote(context),
                        ),
                    ],
                  ),
                ),
                Switch.adaptive(
                  key: const Key('vtc_join_list_me'),
                  value: state.listInDirectory,
                  onChanged: onListInDirectory,
                ),
              ],
            ),
        ],
      ),
    );
  }

  /// One line per audience, widest first: which directory values reach it
  /// by default, the membership DID among them.
  static List<Widget> _audienceItems(
    BuildContext context,
    DirectoryDisclosure disclosure,
  ) {
    final l10n = context.l10n;
    String audience(DirectoryAudience audience) =>
        l10n.vtcJoinAudience(audience.name);

    return [
      for (final group in DirectoryAudience.values.reversed)
        if ([
              for (final field in disclosure.fields)
                if (field.defaultVisibility == group) field,
            ]
            case final fields
            when fields.isNotEmpty || disclosure.membershipIdentifiers == group)
          _ConsentItem(
            icon: switch (group) {
              DirectoryAudience.admins => McIcons.admin,
              DirectoryAudience.public => McIcons.public,
              _ => McIcons.visible,
            },
            // Anyone, not only members, sees these: worth a second look.
            iconColor: group == DirectoryAudience.public
                ? context.mcColors.warning
                : null,
            title: l10n.vtcJoinShowsTo(
              _listOf(l10n, [
                for (final field in fields) field.label,
                if (disclosure.membershipIdentifiers == group)
                  l10n.vtcJoinMembershipDidField,
              ]),
              audience(group),
            ),
            details: [
              for (final field in fields)
                _FieldDetail(field: field, audience: audience),
            ],
          ),
    ];
  }
}

/// [items] as a sentence would list them: "a, b and c".
String _listOf(AppLocalizations l10n, List<String> items) => switch (items) {
  [...final rest, final last] when rest.isNotEmpty => l10n.vtcJoinListAnd(
    rest.join(', '),
    last,
  ),
  _ => items.join(),
};

/// A line of small print under a consent line.
class _Note extends StatelessWidget {
  const _Note(this.text);

  final String text;

  @override
  Widget build(BuildContext context) =>
      Text(text, style: onboardingNote(context));
}

/// One directory field under a consent line: its label, who sees it once
/// the member joins and, when wider, who the member may show it to later.
class _FieldDetail extends StatelessWidget {
  const _FieldDetail({required this.field, required this.audience});

  final DirectoryField field;

  /// What an audience is called.
  final String Function(DirectoryAudience) audience;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final labelStyle = context.textTheme.bodyMedium?.copyWith(
      color: context.mcColors.textPrimary,
      fontWeight: FontWeight.w500,
    );
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8,
        children: [
          // Screen readers already read each field as its own line.
          ExcludeSemantics(child: Text('•', style: labelStyle)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 2,
              children: [
                Row(
                  spacing: 8,
                  children: [
                    Expanded(child: Text(field.label, style: labelStyle)),
                    if (field.source == DirectoryFieldSource.admin)
                      _Tag(l10n.vtcJoinFieldSetByAdmins),
                  ],
                ),
                if (field.description case final description?)
                  _Note(description),
                _Note(
                  l10n.vtcJoinFieldSeenBy(audience(field.defaultVisibility)),
                ),
                if (field.ceiling != field.defaultVisibility)
                  _Note(l10n.vtcJoinFieldWidenTo(audience(field.ceiling))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// A small outlined label, as [_Pill] but without an icon.
class _Tag extends StatelessWidget {
  const _Tag(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      border: Border.all(color: context.mcColors.hairlineStrong),
      borderRadius: BorderRadius.circular(McRadius.full),
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: Text(
        text,
        style: context.textTheme.labelSmall?.copyWith(
          color: context.mcColors.textSecondary,
        ),
      ),
    ),
  );
}

/// A thin rule between the lines of a list.
class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: context.mcColors.hairline,
    child: const SizedBox(height: 1),
  );
}

/// One thing joining allows: an icon, a title and an always shown
/// [subtitle], and [details] shown on tap, as a consent screen explains a
/// permission.
class _ConsentItem extends HookWidget {
  const _ConsentItem({
    required this.icon,
    required this.title,
    this.iconColor,
    this.subtitle,
    this.details = const [],
  });

  final IconData icon;

  /// Tints the icon, the secondary text colour when null.
  final Color? iconColor;
  final String title;
  final String? subtitle;
  final List<Widget> details;

  @override
  Widget build(BuildContext context) {
    final expanded = useState(false);
    final canExpand = details.isNotEmpty;
    final mc = context.mcColors;

    // Tells screen readers the line opens, as the chevron tells the eye.
    return Semantics(
      button: canExpand,
      expanded: canExpand ? expanded.value : null,
      child: InkWell(
        onTap: canExpand ? () => expanded.value = !expanded.value : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 12,
            children: [
              Icon(icon, size: 20, color: iconColor ?? mc.textSecondary),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 4,
                  children: [
                    Text(
                      title,
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: mc.textPrimary,
                      ),
                    ),
                    if (subtitle case final subtitle?)
                      Text(subtitle, style: onboardingNote(context)),
                    if (expanded.value) ...details,
                  ],
                ),
              ),
              if (canExpand)
                Icon(
                  expanded.value ? McIcons.chevronUp : McIcons.chevronDown,
                  color: mc.textSecondary,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// How to get in: each way in the community offers, as a deck to swipe
/// through, and what admission under it takes. The member applies under the
/// card on top, when this app supports it.
class _WaysIn extends StatelessWidget {
  const _WaysIn({required this.state, required this.onChoose});

  final VtcJoinState state;
  final ValueChanged<String> onChoose;

  /// Room for a way's eyebrow, title and a few lines of the community's
  /// words; longer ones scroll inside the card.
  static const _deckHeight = 220.0;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final ways = state.ways;
    final top = ways.indexWhere((way) => way.id == state.chosenWayId);
    final position = top < 0 ? 0 : top;
    return GlassCard(
      title: l10n.vtcJoinWaysHeading,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 12,
        children: [
          if (ways.isNotEmpty)
            SwipeableCards<VtcJoinWay>(
              key: const Key('vtc_join_ways'),
              items: ways,
              maxWidth: double.infinity,
              maxHeight: _deckHeight,
              initialIndex: position,
              onCardChange: (index) => onChoose(ways[index].id),
              cardBuilder: (context, way) => _WayCard(way),
            ),
          if (ways.length > 1)
            Text(
              l10n.vtcJoinIdentityPosition(position + 1, ways.length),
              key: const Key('vtc_join_way_position'),
              textAlign: TextAlign.center,
              style: onboardingNote(context),
            ),
        ],
      ),
    );
  }
}

/// A way in, as a card in the deck of ways in, styled as a small identity
/// card: the kind of admission as an eyebrow over what it takes, or why
/// this app cannot apply under it yet, the way's
/// symbol in a ring at the top end, and what it asks for below. A way this
/// app supports carries the blue corner wash.
class _WayCard extends StatelessWidget {
  const _WayCard(this.way);

  final VtcJoinWay way;

  static const _symbolSize = 48.0;
  static const _blurSigma = 20.0;

  @override
  Widget build(BuildContext context) {
    final mc = context.mcColors;
    final textTheme = context.textTheme;
    final l10n = context.l10n;
    final supported = way.unsupported == null;
    final details = <(IconData, String)>[
      if (way.credentialType case final type?)
        (McIcons.credentials, l10n.vtcJoinWayWithCredential(type)),
      if (way.description case final description?) (McIcons.info, description),
    ];

    return Padding(
      padding: const EdgeInsets.all(McSpacing.s2),
      // Blurred behind, as the identity deck is, so the card stacked behind
      // cannot be read through the panel.
      child: ClipRRect(
        borderRadius: BorderRadius.circular(McRadius.xl),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: _blurSigma, sigmaY: _blurSigma),
          child: AppCard(
            accent: supported ? McColors.blue : null,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(McRadius.xl),
              side: BorderSide(color: mc.hairline),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                McSpacing.s5,
                McSpacing.s4,
                McSpacing.s5,
                McSpacing.s4,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: McSpacing.s3,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: McSpacing.s3,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: McSpacing.s1,
                          children: [
                            Text(
                              l10n.vtcJoinWayKind(_kindOf(way)).toUpperCase(),
                              style: McTypography.eyebrow.copyWith(
                                color: mc.textSecondary,
                              ),
                            ),
                            // A sentence, not a name: shown whole.
                            Text(
                              _titleOf(l10n, way),
                              style: textTheme.titleMedium?.copyWith(
                                color: supported
                                    ? mc.textPrimary
                                    : mc.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: _symbolSize,
                        height: _symbolSize,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: context.colorScheme.surfaceContainerHigh,
                          border: Border.all(color: mc.hairline),
                        ),
                        child: Icon(
                          _iconOf(way),
                          size: _symbolSize / 2,
                          color: supported ? mc.textPrimary : mc.textTertiary,
                        ),
                      ),
                    ],
                  ),
                  for (final (icon, value) in details)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: McSpacing.s2,
                      children: [
                        Icon(icon, size: 16, color: mc.textSecondary),
                        Expanded(
                          child: Text(
                            value,
                            style: textTheme.bodySmall?.copyWith(
                              color: mc.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The kind of admission [way] offers, for its card's eyebrow.
String _kindOf(VtcJoinWay way) => way.automatic ? 'automatic' : 'reviewed';

IconData _iconOf(VtcJoinWay way) => way.unsupported != null
    ? McIcons.block
    : way.automatic
    ? McIcons.userCheck
    : McIcons.review;

String _titleOf(AppLocalizations l10n, VtcJoinWay way) => switch (way) {
  VtcJoinWay(unsupported: VtcJoinUnsupported.credentialMissing) =>
    l10n.vtcJoinCredentialMissing,
  VtcJoinWay(:final unsupported?) => l10n.vtcJoinWayUnsupported(
    unsupported.name,
  ),
  VtcJoinWay(automatic: true) => l10n.vtcJoinWayAutomatic,
  _ => l10n.vtcJoinWayReviewed,
};

/// Which identity on the member's VTA joins, in a deck to swipe through as
/// MPX picks an identity: a new one first, which no other community can link
/// to, then those the VTA already holds.
class _ChooseIdentity extends HookWidget {
  const _ChooseIdentity({
    required this.state,
    required this.onChoose,
    required this.onCancel,
  });

  final VtcJoinState state;
  final ValueChanged<String?> onChoose;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    // Null stands for a new identity.
    final options = <String?>[null, ...state.identityChoices];
    final holders = state.credentialHolders;
    bool missingCredential(String? did) =>
        holders != null && !holders.contains(did);
    // Under a way in asking for a credential, start on one who holds it.
    final first = options.indexWhere((did) => !missingCredential(did));
    final current = useState(first < 0 ? 0 : first);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 12,
      children: [
        OnboardingTitle(l10n.vtcJoinChooseIdentity),
        SwipeableCards<String?>(
          key: const Key('vtc_join_identities'),
          items: options,
          maxWidth: double.infinity,
          // Room for the picture over the card's edge, the profile's details
          // and the full DID.
          maxHeight: 380,
          initialIndex: current.value,
          onCardChange: (index) => current.value = index,
          cardBuilder: (context, did) => VtaIdentityCard(
            key: did == null ? const Key('vtc_join_new_identity') : null,
            did: did,
            identity: state.identities[did],
            missingCredential: missingCredential(did),
          ),
        ),
        if (options.length > 1)
          Text(
            l10n.vtcJoinIdentityPosition(current.value + 1, options.length),
            key: const Key('vtc_join_identity_position'),
            textAlign: TextAlign.center,
            style: onboardingNote(context),
          ),
        const SizedBox(height: 12),
        OnboardingButton(
          label: l10n.vtcJoinUseIdentity,
          onPressed: missingCredential(options[current.value])
              ? null
              : () => onChoose(options[current.value]),
        ),
        OnboardingTextButton(label: l10n.generalCancel, onPressed: onCancel),
      ],
    );
  }
}

/// The profile details the community asks for, as the VTA would disclose
/// them; nothing is shared until the member approves.
class _ApproveDetails extends StatelessWidget {
  const _ApproveDetails({
    required this.state,
    required this.onShare,
    required this.onCancel,
  });

  final VtcJoinState state;
  final VoidCallback onShare;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 12,
      children: [
        OnboardingTitle(l10n.vtcJoinShareDetails(state.communityName ?? '')),
        const SizedBox(height: 12),
        GlassCard(
          title: l10n.vtcJoinDetailsHeading,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 12,
            children: [
              for (final detail in state.details)
                OnboardingLine(
                  icon: McIcons.badge,
                  title: detail.value,
                  subtitle: vtcClaimTypeLabel(l10n, detail.type),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        OnboardingButton(label: l10n.vtcJoinShareAction, onPressed: onShare),
        OnboardingTextButton(label: l10n.generalCancel, onPressed: onCancel),
      ],
    );
  }
}

/// The credential the chosen way in asks for, as the VTA holds it: who
/// issued it and every claim presenting it shows. Nothing is presented
/// until the member approves.
class _ApproveCredential extends StatelessWidget {
  const _ApproveCredential({
    required this.state,
    required this.onShare,
    required this.onCancel,
  });

  final VtcJoinState state;
  final VoidCallback onShare;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final credential = state.sharedCredential;
    if (credential == null) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 12,
      children: [
        OnboardingTitle(l10n.vtcJoinShareCredential(state.communityName ?? '')),
        const SizedBox(height: 12),
        GlassCard(
          title: credential.types.last,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 4,
            children: [
              if (credential.issuerDid case final issuer?) ...[
                Text(
                  l10n.vtcJoinCredentialIssuer,
                  style: onboardingNote(context),
                ),
                MonospaceDid(
                  issuer,
                  textKey: const Key('vtc_join_credential_issuer'),
                ),
              ],
            ],
          ),
        ),
        GlassCard(
          title: l10n.vtcJoinCredentialClaimsHeading,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 12,
            children: [
              for (final claim in credential.claims)
                OnboardingLine(
                  icon: McIcons.badge,
                  title: claim.value,
                  subtitle: claim.type,
                ),
              Text(l10n.vtcJoinCredentialNote, style: onboardingNote(context)),
            ],
          ),
        ),
        const SizedBox(height: 12),
        OnboardingButton(label: l10n.vtcJoinShareAction, onPressed: onShare),
        OnboardingTextButton(label: l10n.generalCancel, onPressed: onCancel),
      ],
    );
  }
}

/// What the community lists about [vetterDid], when its listing was read.
ListedVetter? _listedVetter(VtcJoinState state, String? vetterDid) =>
    state.vetters.where((vetter) => vetter.did == vetterDid).firstOrNull;

/// How [vetterDid] goes by: the name the community lists them under, else
/// as unnamed; never their DID.
String _vetterName(
  AppLocalizations l10n,
  VtcJoinState state,
  String? vetterDid,
) =>
    state.vetting?.requestTo(vetterDid ?? '')?.vetterName ??
    _listedVetter(state, vetterDid)?.displayName ??
    l10n.vtcVetterUnnamed;

/// Being vetted by one vetter, a step a page under a progress bar: asking
/// them, comparing the match code, sharing the details they check, and
/// how it ended. What the phone does in the background, and what it waits
/// for, shows as lines under the step.
class _VettingFlow extends StatelessWidget {
  const _VettingFlow({
    required this.state,
    required this.step,
    required this.controller,
  });

  final VtcJoinState state;
  final VtcApplicantStep step;
  final VtcJoinController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final vetterDid = state.flowVetterDid ?? state.vetterDid;
    final vetter = _vetterName(l10n, state, vetterDid);
    final work = state.vettingWork;
    final waiting = state.step == VtcJoinStep.vetting;
    final back = OnboardingTextButton(
      key: const Key('vtc_join_vetting_back'),
      label: l10n.vtcApplicantBackToOverview,
      onPressed: controller.backToVetting,
    );

    /// The lines of [steps], each done, under way or still to come, up to
    /// the work under way. Once the phone waits on the vetter, the last
    /// step, which is the wait, stands out below the steps done.
    Widget lines(List<(VtcVettingWork?, String)> steps) {
      final current = waiting
          ? steps.length - 1
          : steps.indexWhere((step) => step.$1 == work);
      return Column(
        key: const Key('vtc_join_vetting_work'),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          VtcBackgroundPanel(
            children: [
              for (final (index, (_, title)) in steps.indexed)
                if (!waiting || index != current)
                  VtcProgressLine(
                    title: title,
                    stage: switch (index.compareTo(current)) {
                      < 0 => VtcTrailStage.done,
                      0 => VtcTrailStage.current,
                      _ => VtcTrailStage.next,
                    },
                  ),
            ],
          ),
          // What the vetter is to do is the page's content, not background.
          if (waiting) VtcWaitingForParty(steps[current].$2),
        ],
      );
    }

    final body = switch ((step, state.step)) {
      (_, VtcJoinStep.chooseVetter) => _ChooseVetter(
        state: state,
        onChoose: controller.chooseVetter,
        onBack: controller.backToVetting,
      ),
      (_, VtcJoinStep.enterVettingCode) => _VettingCode(
        state: state,
        onSubmit: controller.submitVettingCode,
        onBack: controller.backToVetting,
      ),
      (_, VtcJoinStep.confirmMatch) => _ConfirmMatch(
        state: state,
        onMatch: controller.confirmMatch,
        onMismatch: controller.declineSession,
      ),
      (_, VtcJoinStep.approveVettingCard) => _ApproveVettingCard(
        state: state,
        onShare: controller.approveVettingCard,
        onDecline: controller.declineSession,
      ),
      (VtcApplicantStep.ticket, _) when work == VtcVettingWork.listingVetters =>
        lines([
          (
            VtcVettingWork.listingVetters,
            l10n.vtcApplicantListingVetters(state.communityName ?? ''),
          ),
        ]),
      (VtcApplicantStep.ticket, _) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 12,
        children: [
          lines([
            (VtcVettingWork.unlockingIdentity, l10n.vtcApplicantUnlocking),
            (
              VtcVettingWork.sendingRequest,
              l10n.vtcApplicantSendingRequest(vetter),
            ),
            (null, l10n.vtcApplicantWaitingSession(vetter)),
          ]),
          if (waiting) back,
        ],
      ),
      (VtcApplicantStep.match, _) => lines([
        (VtcVettingWork.preparingDetails, l10n.vtcApplicantPreparing),
      ]),
      (VtcApplicantStep.details, _) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 12,
        children: [
          lines([
            (VtcVettingWork.recordingDisclosure, l10n.vtcApplicantRecording),
            (
              VtcVettingWork.sendingDetails,
              l10n.vtcApplicantSendingDetails(vetter),
            ),
            (null, l10n.vtcApplicantWaitingCheck(vetter)),
          ]),
          if (waiting) back,
        ],
      ),
      // Shown by the overview, on a page of its own.
      (VtcApplicantStep.meet, _) => const SizedBox.shrink(),
      (VtcApplicantStep.done, _) => _VettingOutcome(
        request: state.vetting?.requestTo(vetterDid ?? ''),
        vetter: vetter,
        onBack: controller.backToVetting,
      ),
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 12,
      children: [
        OnboardingStepProgress(
          key: const Key('vtc_join_vetting_progress'),
          step: step.index + 1,
          total: VtcApplicantStep.values.length,
          title: l10n.vtcApplicantStep(step.name),
        ),
        body,
      ],
    );
  }
}

/// How being vetted by one vetter ended, and the way back to the overview.
class _VettingOutcome extends StatelessWidget {
  const _VettingOutcome({
    required this.request,
    required this.vetter,
    required this.onBack,
  });

  final VtcVettingRequest? request;
  final String vetter;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final unanswered = request?.isUnansweredAt(clock.now()) ?? false;
    final status = unanswered ? null : request?.status;
    return Column(
      key: const Key('vtc_join_vetting_outcome'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 12,
      children: [
        Icon(
          status == VtcVettingStatus.vouched
              ? McIcons.verified
              : McIcons.remove,
          size: 72,
          color: status == VtcVettingStatus.vouched
              ? context.mcColors.success
              : context.mcColors.textSecondary,
        ),
        Text(
          l10n.vtcApplicantOutcome(
            unanswered ? 'unanswered' : status?.name ?? '',
            vetter,
          ),
          textAlign: TextAlign.center,
          style: context.textTheme.titleMedium?.copyWith(
            color: context.mcColors.textPrimary,
          ),
        ),
        if (request?.declineMessage case final message?)
          OnboardingSubtitle(message),
        if (request?.failure case final failure?)
          OnboardingSubtitle(l10n.vtcJoinVettingFailure(failure.name)),
        OnboardingButton(
          key: const Key('vtc_join_vetting_outcome_back'),
          label: l10n.vtcApplicantBackToOverview,
          onPressed: onBack,
        ),
      ],
    );
  }
}

/// Being vetted for a community: what it asks of vetting in plain words,
/// how many vetters vouched so far, where each vetter asked stands, and
/// ways to meet another.
class _Vetting extends HookConsumerWidget {
  const _Vetting({
    required this.state,
    required this.onScan,
    required this.onEnterCode,
    required this.onSend,
    required this.onStop,
    required this.onDone,
  });

  final VtcJoinState state;
  final ValueChanged<String> onScan;
  final VoidCallback onEnterCode;
  final VoidCallback onSend;

  /// Stops vetting, to choose another way in or start over.
  final VoidCallback onStop;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final name = state.communityName ?? '';
    final requirements = state.vettingRequirements;
    final progress = state.vettingProgress;
    final hasCamera = ref.watch(
      cameraServiceProvider.select((state) => state.isAvailable ?? false),
    );

    Future<void> scan() async {
      final data = await QrCodePicker.show(context: context);
      if (data != null) onScan(data.trim());
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 12,
      children: [
        if (state.logoUrl case final logoUrl?) VtcCommunityLogo(logoUrl),
        OnboardingStepProgress(
          key: const Key('vtc_join_vetting_progress'),
          step: VtcApplicantStep.meet.index + 1,
          total: VtcApplicantStep.values.length,
          title: l10n.vtcApplicantStep(VtcApplicantStep.meet.name),
        ),
        OnboardingSubtitle(l10n.vtcJoinVettingIntro(name)),
        if (requirements != null)
          GlassCard(
            title: l10n.vtcJoinVettingProgress(
              progress?.counted.length ?? 0,
              requirements.minStatements,
            ),
            child: Column(
              key: const Key('vtc_join_vetting_requirements'),
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 8,
              children: [
                for (final need in progress?.needs ?? const <VettingNeed>[])
                  if (need case MoreByMethod(:final method, :final count))
                    _Note(l10n.vtcJoinVettingMethodNeed(count, method.name)),
                if (requirements.requiredClaims.isNotEmpty)
                  _Note(
                    l10n.vtcJoinVettingChecks(
                      requirements.requiredClaims
                          .map((type) => vtcClaimTypeLabel(l10n, type))
                          .join(', '),
                    ),
                  ),
                if (requirements.maxStatementAge case final age?)
                  _Note(l10n.vtcJoinVettingMaxAge(age.inDays)),
                if (progress != null &&
                    (!progress.independent || !progress.commitmentsConsistent))
                  _Note(l10n.vtcJoinVettingNotIndependent),
              ],
            ),
          ),
        if (state.vetting?.requests case final requests?
            when requests.isNotEmpty)
          GlassCard(
            title: l10n.vtcJoinVettersHeading,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 12,
              children: [
                for (final request in requests.reversed)
                  OnboardingLine(
                    key: Key('vtc_join_vetter_${request.status.name}'),
                    icon: _vettingIcon(request.status),
                    title: switch (request.vetterName) {
                      // Their own choice of name, not checked.
                      final name? => l10n.vtcJoinVetterListedAs(name),
                      null => l10n.vtcVetterUnnamed,
                    },
                    titleTooltip: vtcVetterDetails(
                      l10n,
                      request.vetterDid,
                      _listedVetter(state, request.vetterDid),
                    ),
                    subtitle: [
                      l10n.vtcJoinVettingStatus(request.status.name),
                      ?request.declineMessage,
                      if (request.failure case final failure?)
                        l10n.vtcJoinVettingFailure(failure.name),
                    ].join(' · '),
                  ),
              ],
            ),
          ),
        if (state.vettingFailure case final failure?)
          OnboardingMessage(
            l10n.vtcJoinVettingFailure(failure.name),
            isError: true,
          ),
        const SizedBox(height: 12),
        if (progress?.satisfied ?? false)
          OnboardingButton(
            key: const Key('vtc_join_vetting_send'),
            label: l10n.vtcJoinVettingSendAction,
            onPressed: onSend,
          ),
        OnboardingButton(
          key: const Key('vtc_join_vetting_scan'),
          label: l10n.vtcJoinVettingScanAction,
          isOutlined: progress?.satisfied ?? false,
          onPressed: hasCamera ? scan : null,
        ),
        OnboardingButton(
          key: const Key('vtc_join_vetting_code'),
          label: l10n.vtcJoinVettingCodeAction,
          isOutlined: true,
          onPressed: onEnterCode,
        ),
        OnboardingTextButton(
          key: const Key('vtc_join_vetting_stop'),
          label: l10n.vtcJoinVettingStopAction,
          onPressed: onStop,
        ),
        OnboardingTextButton(label: l10n.generalDone, onPressed: onDone),
      ],
    );
  }
}

IconData _vettingIcon(VtcVettingStatus status) => switch (status) {
  VtcVettingStatus.vouched => McIcons.verified,
  VtcVettingStatus.declined ||
  VtcVettingStatus.refused ||
  VtcVettingStatus.abandoned => McIcons.block,
  VtcVettingStatus.inSession => McIcons.swap,
  _ => McIcons.pending,
};

/// The vetters the community lists, to pick the one in front of the member.
/// Their names are their own.
class _ChooseVetter extends StatelessWidget {
  const _ChooseVetter({
    required this.state,
    required this.onChoose,
    required this.onBack,
  });

  final VtcJoinState state;
  final ValueChanged<String> onChoose;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 12,
      children: [
        OnboardingTitle(l10n.vtcJoinChooseVetterTitle),
        if (state.vetters.isEmpty)
          OnboardingSubtitle(l10n.vtcJoinNoVetters(state.communityName ?? ''))
        else ...[
          OnboardingSubtitle(l10n.vtcJoinChooseVetterIntro),
          for (final vetter in state.vetters)
            InkWell(
              key: Key('vtc_join_vetter_${vetter.did}'),
              onTap: () => onChoose(vetter.did),
              child: OnboardingLine(
                icon: McIcons.personSearch,
                title: vetter.displayName ?? l10n.vtcVetterUnnamed,
                titleTooltip: vtcVetterDetails(l10n, vetter.did, vetter),
                subtitle: [
                  ?vetter.place,
                  ...vetter.events,
                  ?vetter.contactHint,
                ].join(' · '),
              ),
            ),
        ],
        const SizedBox(height: 12),
        OnboardingTextButton(label: l10n.generalCancel, onPressed: onBack),
      ],
    );
  }
}

/// The code the vetter at hand reads out.
class _VettingCode extends HookWidget {
  const _VettingCode({
    required this.state,
    required this.onSubmit,
    required this.onBack,
  });

  final VtcJoinState state;
  final ValueChanged<String> onSubmit;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final field = useTextEditingController();
    useListenable(field);
    final code = field.text.trim();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 12,
      children: [
        OnboardingTitle(
          l10n.vtcJoinVettingCodeTitle(
            _vetterName(l10n, state, state.vetterDid),
          ),
        ),
        OnboardingSubtitle(l10n.vtcJoinVettingCodeIntro),
        OnboardingTextField(
          key: const Key('vtc_join_vetting_code_field'),
          controller: field,
          label: l10n.vtcJoinVettingCodeHint,
          hint: 'K7QF-2M9X',
          onSubmitted: onSubmit,
        ),
        if (state.vettingFailure case final failure?)
          OnboardingMessage(
            l10n.vtcJoinVettingFailure(failure.name),
            isError: true,
          ),
        const SizedBox(height: 12),
        OnboardingButton(
          label: l10n.vtcJoinContinueAction,
          onPressed: code.isEmpty ? null : () => onSubmit(code),
        ),
        OnboardingTextButton(label: l10n.generalCancel, onPressed: onBack),
      ],
    );
  }
}

/// The session's match code, for the member and the vetter to compare
/// before anything is shared, with the vetter's checked role.
class _ConfirmMatch extends StatelessWidget {
  const _ConfirmMatch({
    required this.state,
    required this.onMatch,
    required this.onMismatch,
  });

  final VtcJoinState state;
  final VoidCallback onMatch;
  final VoidCallback onMismatch;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final request = state.vetting?.requestTo(state.vetterDid ?? '');
    final vetter = _vetterName(l10n, state, state.vetterDid);
    final code = switch (request?.session) {
      {'id': final String id} => vettingMatchCode(id),
      _ => '',
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 12,
      children: [
        OnboardingTitle(l10n.vtcJoinMatchTitle),
        OnboardingSubtitle(l10n.vtcJoinMatchIntro(vetter)),
        GlassCard(
          title: l10n.vtcJoinMatchCodeHeading,
          child: Text(
            code,
            key: const Key('vtc_join_match_code'),
            textAlign: TextAlign.center,
            style: McTypography.code.copyWith(
              fontSize: context.textTheme.displaySmall?.fontSize,
              color: context.mcColors.textPrimary,
              letterSpacing: 4,
            ),
          ),
        ),
        if (request?.roleValidUntil case final until?)
          OnboardingLine(
            icon: McIcons.credentials,
            title: vetter,
            subtitle: l10n.vtcJoinVettingVerified(
              vetter,
              state.communityName ?? '',
              MaterialLocalizations.of(context).formatMediumDate(until),
            ),
          ),
        const SizedBox(height: 12),
        OnboardingButton(
          key: const Key('vtc_join_match_yes'),
          label: l10n.vtcJoinMatchYes,
          onPressed: onMatch,
        ),
        OnboardingButton(
          key: const Key('vtc_join_match_no'),
          label: l10n.vtcJoinMatchNo,
          isDestructive: true,
          onPressed: onMismatch,
        ),
      ],
    );
  }
}

/// The details the vetting card would carry, as the VTA would disclose
/// them; nothing is sent until the member approves.
class _ApproveVettingCard extends StatelessWidget {
  const _ApproveVettingCard({
    required this.state,
    required this.onShare,
    required this.onDecline,
  });

  final VtcJoinState state;
  final VoidCallback onShare;
  final VoidCallback onDecline;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final vetter = _vetterName(l10n, state, state.vetterDid);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 12,
      children: [
        OnboardingTitle(l10n.vtcJoinVettingCardTitle(vetter)),
        GlassCard(
          title: l10n.vtcJoinVettingCardHeading,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 12,
            children: [
              for (final detail in state.details)
                OnboardingLine(
                  icon: McIcons.badge,
                  title: detail.value,
                  subtitle: vtcClaimTypeLabel(l10n, detail.type),
                ),
              Text(
                l10n.vtcJoinVettingCardNote(vetter),
                style: onboardingNote(context),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        OnboardingButton(
          key: const Key('vtc_join_vetting_card_share'),
          label: l10n.vtcJoinShareAction,
          onPressed: onShare,
        ),
        OnboardingTextButton(
          label: l10n.vtcJoinVettingCardDecline,
          onPressed: onDecline,
        ),
      ],
    );
  }
}

/// An application waiting for the community: who it went to, the path it
/// took as a trail of signed steps, then Done, Check again and Withdraw.
class _Pending extends StatelessWidget {
  const _Pending({
    required this.state,
    required this.onCheckAgain,
    required this.onWithdraw,
    required this.onDone,
  });

  final VtcJoinState state;
  final VoidCallback onCheckAgain;
  final VoidCallback onWithdraw;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final name = state.communityName ?? '';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 12,
      children: [
        if (state.logoUrl case final logoUrl?) VtcCommunityLogo(logoUrl),
        OnboardingTitle(name),
        OnboardingSubtitle(l10n.vtcJoinPending(name)),
        GlassCard(
          title: l10n.vtcJoinTrailHeading,
          child: VtcJoinTrail(
            communityName: name,
            submit: state.submitExchange,
            receipt: state.submitReceipt,
            requestId: state.requestId,
            deferred: state.deferred,
            checking: state.checking,
            lastCheckedAt: state.lastCheckedAt,
            lastCheck: state.lastCheckExchange,
            autoCheckInterval: VtcJoinController.pendingCheckInterval,
          ),
        ),
        const SizedBox(height: 12),
        OnboardingButton(label: l10n.generalDone, onPressed: onDone),
        OnboardingButton(
          label: l10n.vtcJoinCheckAgain,
          isOutlined: true,
          onPressed: onCheckAgain,
        ),
        OnboardingTextButton(
          label: l10n.vtcJoinWithdrawAction,
          onPressed: onWithdraw,
        ),
      ],
    );
  }
}

/// How joining ended: a white [icon], the [message], then Done and an
/// optional [secondary] action.
class _Outcome extends StatelessWidget {
  const _Outcome({
    required this.icon,
    required this.message,
    required this.onDone,
    this.trail,
    this.secondary,
  });

  final IconData icon;
  final String message;
  final VoidCallback onDone;

  /// How the outcome came about, under [message].
  final Widget? trail;
  final Widget? secondary;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 12,
      children: [
        Icon(icon, size: 72, color: context.mcColors.textPrimary),
        const SizedBox(height: 4),
        Text(
          message,
          textAlign: TextAlign.center,
          style: context.textTheme.titleMedium?.copyWith(
            color: context.mcColors.textPrimary,
          ),
        ),
        ?trail,
        const SizedBox(height: 12),
        OnboardingButton(label: context.l10n.generalDone, onPressed: onDone),
        ?secondary,
      ],
    );
  }
}

/// Joining could not go ahead: why, then Retry with another code or Cancel.
class _Failed extends StatelessWidget {
  const _Failed({
    required this.message,
    required this.onRetry,
    required this.onCancel,
  });

  final String message;
  final VoidCallback onRetry;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 12,
      children: [
        Icon(McIcons.error, size: 72, color: context.mcColors.dangerText),
        const SizedBox(height: 4),
        OnboardingMessage(message, isError: true),
        const SizedBox(height: 12),
        OnboardingButton(label: l10n.generalRetry, onPressed: onRetry),
        OnboardingTextButton(label: l10n.generalCancel, onPressed: onCancel),
      ],
    );
  }
}

/// Opening a community, step by step: each step done, under way, or still
/// to come.
class _Opening extends StatelessWidget {
  const _Opening({required this.step});

  /// The step under way.
  final VtcOpenStep step;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return VtcBackgroundPanel(
      key: const Key('vtc_join_opening'),
      title: l10n.vtcOpenLoading,
      children: [
        for (final each in VtcOpenStep.values)
          VtcProgressLine(
            key: Key('vtc_open_step_${each.name}'),
            title: switch (each) {
              VtcOpenStep.finding => l10n.vtcOpenStepFinding,
              VtcOpenStep.readingRules => l10n.vtcOpenStepRules,
              VtcOpenStep.readingProfile => l10n.vtcOpenStepProfile,
              VtcOpenStep.checkingMembership => l10n.vtcOpenStepMembership,
              VtcOpenStep.checkingCredentials => l10n.vtcOpenStepCredentials,
            },
            stage: _stageOf(each, step),
          ),
      ],
    );
  }
}

/// Leaving a community, step by step, as [_Opening] shows opening it.
class _Leaving extends StatelessWidget {
  const _Leaving({required this.step, required this.communityName});

  /// The step under way.
  final VtcLeaveStep step;
  final String communityName;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return VtcBackgroundPanel(
      key: const Key('vtc_join_leaving'),
      title: l10n.vtcLeaveLoading(communityName),
      children: [
        for (final each in VtcLeaveStep.values)
          VtcProgressLine(
            key: Key('vtc_leave_step_${each.name}'),
            title: switch (each) {
              VtcLeaveStep.readingCard => l10n.vtcLeaveStepCard,
              VtcLeaveStep.tellingCommunity => l10n.vtcLeaveStepTelling(
                communityName,
              ),
              VtcLeaveStep.archivingCard => l10n.vtcLeaveStepArchiving,
            },
            stage: _stageOf(each, step),
          ),
      ],
    );
  }
}

/// Applying to a community, step by step, as [_Opening] shows opening it.
/// The steps after an admission show only while it is on its way.
class _Applying extends StatelessWidget {
  const _Applying({
    required this.step,
    required this.communityName,
    required this.withCredential,
  });

  /// The step under way.
  final VtcApplyStep step;
  final String communityName;

  /// Whether the application carries a credential the member approved.
  final bool withCredential;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return VtcBackgroundPanel(
      key: const Key('vtc_join_applying'),
      title: l10n.vtcApplyLoading(communityName),
      children: [
        for (final each in VtcApplyStep.values)
          VtcProgressLine(
            key: Key('vtc_apply_step_${each.name}'),
            title: switch (each) {
              VtcApplyStep.preparingIdentity => l10n.vtcApplyStepIdentity,
              VtcApplyStep.sending =>
                withCredential
                    ? l10n.vtcApplyStepSendingCredential(communityName)
                    : l10n.vtcApplyStepSending(communityName),
              VtcApplyStep.keepingCards => l10n.vtcApplyStepKeeping,
              VtcApplyStep.confirming => l10n.vtcApplyStepConfirming(
                communityName,
              ),
            },
            stage: _stageOf(each, step),
          ),
      ],
    );
  }
}

/// How far [current] got with [step], both of the same ordered steps.
VtcTrailStage _stageOf(Enum step, Enum current) =>
    switch (step.index.compareTo(current.index)) {
      < 0 => VtcTrailStage.done,
      0 => VtcTrailStage.current,
      _ => VtcTrailStage.next,
    };
