import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:meeting_place_vtc/meeting_place_vtc.dart';

import '../../../infrastructure/extensions/build_context_extensions.dart';
import '../../../infrastructure/services/camera_service/camera_service.dart';
import '../../dialogs/qr_code_picker/qr_code_picker.dart';
import '../../widgets/onboarding_style/onboarding_style.dart';
import '../../widgets/swipeable_cards.dart';
import '../../widgets/vta_identity_card.dart';
import 'vtc_join_controller.dart';
import 'vtc_join_state.dart';

/// Joins a community: scan its code or enter its DID, read what it asks,
/// apply as an identity from the member's VTA. In the look of linking the
/// VTA, the review laid out like a consent screen.
class VtcJoinScreen extends ConsumerWidget {
  const VtcJoinScreen({super.key});

  /// Opens joining over the current screen.
  static Future<void> show(BuildContext context) =>
      Navigator.of(context, rootNavigator: true).push<void>(
        MaterialPageRoute<void>(builder: (context) => const VtcJoinScreen()),
      );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(vtcJoinControllerProvider);
    final controller = ref.read(vtcJoinControllerProvider.notifier);
    final l10n = context.l10n;
    final name = state.communityName ?? '';
    void close() => Navigator.of(context).pop();

    return OnboardingLayout(
      onClose: close,
      child: switch (state.step) {
        VtcJoinStep.scanning => _EnterCode(onSubmit: controller.onScanned),
        VtcJoinStep.working => const Center(child: OnboardingSpinner()),
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
        VtcJoinStep.joined => _Outcome(
          icon: Icons.verified,
          message: state.wasMember
              ? l10n.vtcJoinAlreadyMember(name)
              : l10n.vtcJoinJoined(name),
          onDone: close,
          secondary: OnboardingButton(
            label: l10n.vtcJoinLeaveAction,
            isOutlined: true,
            onPressed: () async {
              if (await _confirmLeave(context, name)) {
                await controller.leave();
              }
            },
          ),
        ),
        VtcJoinStep.left => _Outcome(
          icon: Icons.logout,
          message: l10n.vtcJoinLeft(name),
          onDone: close,
        ),
        VtcJoinStep.pending => _Outcome(
          icon: Icons.hourglass_top,
          message: l10n.vtcJoinPending(name),
          onDone: close,
          secondary: OnboardingButton(
            label: l10n.vtcJoinCheckAgain,
            isOutlined: true,
            onPressed: controller.checkAgain,
          ),
        ),
        VtcJoinStep.denied => _Outcome(
          icon: Icons.block,
          message: switch (state.denialReason) {
            final reason? => l10n.vtcJoinDeniedWithReason(name, reason),
            null => l10n.vtcJoinDenied(name),
          },
          onDone: close,
        ),
        VtcJoinStep.needsMore => _Outcome(
          icon: Icons.info_outline,
          message: l10n.vtcJoinNeedsMore,
          onDone: close,
        ),
        VtcJoinStep.failed => _Failed(
          message: l10n.vtcJoinFailure(
            (state.failure ?? VtcJoinFailure.refused).name,
          ),
          onRetry: controller.restart,
          onCancel: close,
        ),
      },
    );
  }
}

/// Asks the member to confirm leaving the community [name].
Future<bool> _confirmLeave(BuildContext context, String name) async {
  final l10n = context.l10n;
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(l10n.vtcJoinLeaveTitle(name)),
      content: Text(l10n.vtcJoinLeaveMessage),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(l10n.generalCancel),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: ElevatedButton.styleFrom(
            backgroundColor: context.colorScheme.error,
            foregroundColor: Colors.white,
          ),
          child: Text(l10n.vtcJoinLeaveAction),
        ),
      ],
    ),
  );
  return confirmed ?? false;
}

/// Shows the community's join manifest as it sent it. Plain text only: the
/// community writes it.
Future<void> _showManifest(
  BuildContext context,
  Map<String, dynamic> manifest,
) {
  final l10n = context.l10n;
  return showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(l10n.vtcJoinManifestHeading),
      content: SingleChildScrollView(
        child: SelectableText(
          const JsonEncoder.withIndent('  ').convert(manifest),
          key: const Key('vtc_join_manifest_json'),
          style: context.textTheme.bodySmall?.copyWith(
            fontFamily: 'monospace',
            height: 1.4,
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.generalClose),
        ),
      ],
    ),
  );
}

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
          hint: 'did:webvh:…',
          onSubmitted: submit,
          suffixIcon: IconButton(
            tooltip: l10n.vtcJoinPasteAction,
            icon: const Icon(Icons.content_paste),
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
        if (state.logoUrl case final logoUrl?) _Logo(logoUrl),
        OnboardingTitle(
          hasName ? name : l10n.vtcJoinUnnamedCommunity,
          trailing: state.manifest.isEmpty
              ? null
              : IconButton(
                  key: const Key('vtc_join_manifest'),
                  icon: const Icon(Icons.data_object, color: Colors.white),
                  tooltip: l10n.vtcJoinShowManifest,
                  onPressed: () => _showManifest(context, state.manifest),
                ),
        ),
        OnboardingSubtitle(l10n.vtcJoinWantsYou),
        Center(child: _Pill(l10n.vtcJoinWithVtaIdentity)),
        _Profile(state: state),
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
                onPressed: state.canApply ? onJoin : null,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Who the community is: its description, website, contact and DID, which
/// can be copied.
class _Profile extends HookWidget {
  const _Profile({required this.state});

  final VtcJoinState state;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final did = state.communityDid ?? '';
    final copied = useState(false);

    Future<void> copyDid() async {
      await Clipboard.setData(ClipboardData(text: did));
      copied.value = true;
    }

    return GlassCard(
      title: l10n.vtcJoinProfileHeading,
      child: SelectionArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 12,
          children: [
            if (state.description case final description?)
              Text(
                description,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: Colors.white,
                ),
              ),
            if (state.website case final website?)
              OnboardingLine(
                icon: Icons.language,
                title: l10n.vtcJoinWebsite,
                subtitle: website.toString(),
              ),
            if (state.contactEmail case final email?)
              OnboardingLine(
                icon: Icons.mail_outline,
                title: l10n.vtcJoinContact,
                subtitle: email,
              ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 12,
              children: [
                const Icon(Icons.fingerprint, size: 20, color: Colors.white),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 2,
                    children: [
                      Text(
                        l10n.vtcJoinDidHint,
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: Colors.white,
                        ),
                      ),
                      MonospaceDid(
                        did,
                        textKey: const Key('vtc_join_community_did'),
                      ),
                      if (copied.value)
                        Text(
                          l10n.copiedToClipboard,
                          style: onboardingNote(context),
                        ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.copy, size: 18, color: Colors.white),
                  tooltip: l10n.linkedVtaCopyDid,
                  visualDensity: VisualDensity.compact,
                  onPressed: copyDid,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// A rounded, frosted label, such as which identity joins.
class _Pill extends StatelessWidget {
  const _Pill(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(25),
        border: Border.all(color: Colors.white.withAlpha(76)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 6,
          children: [
            const Icon(Icons.account_circle, size: 18, color: Colors.white),
            Flexible(
              child: Text(
                text,
                style: context.textTheme.bodySmall?.copyWith(
                  color: Colors.white,
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
          icon: Icons.badge_outlined,
          title: l10n.vtcJoinReceivesDetail(detail.type),
          details: [
            ?detail.purpose,
            detail.required
                ? l10n.vtcJoinDetailRequiredNote
                : l10n.vtcJoinDetailOptionalNote,
            l10n.vtcJoinDetailsNote,
          ],
        ),
      if (disclosure != null) ..._audienceItems(context, disclosure),
      if (disclosure?.adminNotes ?? false)
        _ConsentItem(
          icon: Icons.sticky_note_2_outlined,
          title: l10n.vtcJoinKeepsNotes,
          details: [l10n.vtcJoinAdminNotesDetail],
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
                        style: const TextStyle(color: Colors.white),
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
                  activeTrackColor: Colors.white,
                  activeThumbColor: context.colorScheme.primary,
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
            icon: group == DirectoryAudience.admins
                ? Icons.admin_panel_settings_outlined
                : Icons.visibility_outlined,
            title: l10n.vtcJoinShowsTo(
              [
                for (final field in fields) field.label,
                if (disclosure.membershipIdentifiers == group)
                  l10n.vtcJoinMembershipDidField,
              ].join(', '),
              audience(group),
            ),
            details: [
              for (final field in fields)
                [
                  field.label,
                  ?field.description,
                  if (field.ceiling != field.defaultVisibility)
                    l10n.vtcJoinFieldShareUpTo(audience(field.ceiling)),
                  if (field.source == DirectoryFieldSource.admin)
                    l10n.vtcJoinFieldSetByAdmins,
                ].join(' · '),
            ],
          ),
    ];
  }
}

/// A thin rule between the lines of a list on the gradient.
class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: Colors.white.withAlpha(40),
    child: const SizedBox(height: 1),
  );
}

/// One thing joining allows: an icon and a title, and [details] shown on
/// tap, as a consent screen explains a permission.
class _ConsentItem extends HookWidget {
  const _ConsentItem({
    required this.icon,
    required this.title,
    this.details = const [],
  });

  final IconData icon;
  final String title;
  final List<String> details;

  @override
  Widget build(BuildContext context) {
    final expanded = useState(false);
    final canExpand = details.isNotEmpty;

    return InkWell(
      onTap: canExpand ? () => expanded.value = !expanded.value : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 12,
          children: [
            Icon(icon, size: 20, color: Colors.white),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 4,
                children: [
                  Text(
                    title,
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  if (expanded.value)
                    for (final detail in details)
                      Text(detail, style: onboardingNote(context)),
                ],
              ),
            ),
            if (canExpand)
              Icon(
                expanded.value ? Icons.expand_less : Icons.expand_more,
                color: Colors.white,
              ),
          ],
        ),
      ),
    );
  }
}

/// How to get in: each way in the community offers and what admission
/// under it takes. When this app supports more than one, the member chooses
/// which to apply under.
class _WaysIn extends StatelessWidget {
  const _WaysIn({required this.state, required this.onChoose});

  final VtcJoinState state;
  final ValueChanged<String> onChoose;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final choosable = state.ways.where((way) => way.canApply).length > 1;
    return GlassCard(
      title: l10n.vtcJoinWaysHeading,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 12,
        children: [
          for (final way in state.ways)
            _Way(
              way: way,
              chosen: way.id == state.chosenWayId,
              onChoose: choosable && way.canApply
                  ? () => onChoose(way.id)
                  : null,
            ),
        ],
      ),
    );
  }
}

/// One way in: what admission under it takes and the community's words for
/// it. With [onChoose], a choice among the ways in, marked when [chosen].
class _Way extends StatelessWidget {
  const _Way({required this.way, required this.chosen, this.onChoose});

  final VtcJoinWay way;
  final bool chosen;
  final VoidCallback? onChoose;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final onChoose = this.onChoose;
    final line = OnboardingLine(
      icon: onChoose != null
          ? chosen
                ? Icons.radio_button_checked
                : Icons.radio_button_unchecked
          : way.unsupported != null
          ? Icons.block
          : way.automatic
          ? Icons.how_to_reg
          : Icons.rate_review,
      title: switch (way) {
        VtcJoinWay(:final unsupported?) => l10n.vtcJoinWayUnsupported(
          unsupported.name,
        ),
        VtcJoinWay(automatic: true) => l10n.vtcJoinWayAutomatic,
        _ => l10n.vtcJoinWayReviewed,
      },
      subtitle: way.description,
    );
    if (onChoose == null) return line;
    return Semantics(
      key: Key('vtc_join_way_${way.id}'),
      button: true,
      inMutuallyExclusiveGroup: true,
      selected: chosen,
      child: InkWell(
        onTap: onChoose,
        borderRadius: BorderRadius.circular(8),
        child: line,
      ),
    );
  }
}

/// The community's logo above the title; nothing while it cannot load.
class _Logo extends StatelessWidget {
  const _Logo(this.url);

  final Uri url;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          url.toString(),
          key: const Key('vtc_join_logo'),
          height: 64,
          fit: BoxFit.contain,
          errorBuilder: (_, _, _) => const SizedBox.shrink(),
        ),
      ),
    );
  }
}

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
    final current = useState(0);

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
          onCardChange: (index) => current.value = index,
          cardBuilder: (context, did) => VtaIdentityCard(
            key: did == null ? const Key('vtc_join_new_identity') : null,
            did: did,
            identity: state.identities[did],
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
          onPressed: () => onChoose(options[current.value]),
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
                  icon: Icons.badge,
                  title: detail.value,
                  subtitle: detail.type,
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

/// How joining ended: a white [icon], the [message], then Done and an
/// optional [secondary] action.
class _Outcome extends StatelessWidget {
  const _Outcome({
    required this.icon,
    required this.message,
    required this.onDone,
    this.secondary,
  });

  final IconData icon;
  final String message;
  final VoidCallback onDone;
  final Widget? secondary;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 12,
      children: [
        Icon(icon, size: 72, color: Colors.white),
        const SizedBox(height: 4),
        Text(
          message,
          textAlign: TextAlign.center,
          style: context.textTheme.titleMedium?.copyWith(color: Colors.white),
        ),
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
        const Icon(Icons.error_outline, size: 72, color: Colors.white),
        const SizedBox(height: 4),
        OnboardingMessage(message, isError: true),
        const SizedBox(height: 12),
        OnboardingButton(label: l10n.generalRetry, onPressed: onRetry),
        OnboardingTextButton(label: l10n.generalCancel, onPressed: onCancel),
      ],
    );
  }
}
