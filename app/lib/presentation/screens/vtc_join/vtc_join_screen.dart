import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:meeting_place_vtc/meeting_place_vtc.dart';

import '../../../application/services/identities_service/identities_service.dart';
import '../../../domain/models/vtc/vtc_card_delivery.dart';
import '../../../infrastructure/extensions/build_context_extensions.dart';
import '../../../infrastructure/services/camera_service/camera_service.dart';
import '../../../l10n/app_localizations.dart';
import '../../dialogs/qr_code_picker/qr_code_picker.dart';
import '../../widgets/onboarding_style/onboarding_style.dart';
import '../../widgets/swipeable_cards.dart';
import '../../widgets/vta_identity_card.dart';
import 'vtc_card_delivery_trail.dart';
import 'vtc_claim_type_label.dart';
import 'vtc_flow_diagram.dart';
import 'vtc_identity_check_view.dart';
import 'vtc_join_controller.dart';
import 'vtc_join_json_dialog.dart';
import 'vtc_join_state.dart';
import 'vtc_join_trail.dart';
import 'vtc_membership_card_view.dart';

/// Joins a community: scan its code or enter its DID, read what it asks,
/// apply as an identity from the member's VTA. In the look of linking the
/// VTA, the review laid out like a consent screen.
class VtcJoinScreen extends HookConsumerWidget {
  const VtcJoinScreen({super.key, this.communityDid});

  /// The community to open at once, as if its code were scanned; null to
  /// ask for a code.
  final String? communityDid;

  /// Opens joining over the current screen, at [communityDid] if given.
  static Future<void> show(BuildContext context, {String? communityDid}) =>
      Navigator.of(context, rootNavigator: true).push<void>(
        MaterialPageRoute<void>(
          builder: (context) => VtcJoinScreen(communityDid: communityDid),
        ),
      );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(vtcJoinControllerProvider);
    final controller = ref.read(vtcJoinControllerProvider.notifier);
    useEffect(() {
      if (communityDid case final did?) {
        // Not while building: reading the community changes the state.
        Future.microtask(() => controller.onScanned(did));
      }
      return null;
    }, const []);
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
        VtcJoinStep.approveCredential => _ApproveCredential(
          state: state,
          onShare: controller.approveCredential,
          onCancel: close,
        ),
        VtcJoinStep.joined => _Joined(
          state: state,
          onDone: close,
          leave: OnboardingButton(
            label: l10n.vtcJoinLeaveAction,
            isOutlined: true,
            onPressed: () async {
              if (await _confirm(
                context,
                title: l10n.vtcJoinLeaveTitle(name),
                message: l10n.vtcJoinLeaveMessage,
                action: l10n.vtcJoinLeaveAction,
              )) {
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
          icon: Icons.undo,
          message: l10n.vtcJoinWithdrawn(name),
          onDone: close,
          secondary: OnboardingButton(
            label: l10n.vtcJoinApplyAgain,
            isOutlined: true,
            onPressed: controller.applyAgain,
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
          style: ElevatedButton.styleFrom(
            backgroundColor: context.colorScheme.error,
            foregroundColor: Colors.white,
          ),
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
          icon: Icons.sticky_note_2_outlined,
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
            icon: switch (group) {
              DirectoryAudience.admins => Icons.admin_panel_settings_outlined,
              DirectoryAudience.public => Icons.public,
              _ => Icons.visibility_outlined,
            },
            // Anyone, not only members, sees these: worth a second look.
            iconColor: group == DirectoryAudience.public
                ? context.customColors.warning
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
      color: Colors.white,
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

/// A small label on the gradient, as [_Pill] but without an icon.
class _Tag extends StatelessWidget {
  const _Tag(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: Colors.white.withAlpha(25),
      border: Border.all(color: Colors.white.withAlpha(76)),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: Text(
        text,
        style: context.textTheme.labelSmall?.copyWith(color: Colors.white),
      ),
    ),
  );
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

  /// Tints the icon, white when null.
  final Color? iconColor;
  final String title;
  final String? subtitle;
  final List<Widget> details;

  @override
  Widget build(BuildContext context) {
    final expanded = useState(false);
    final canExpand = details.isNotEmpty;

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
              Icon(icon, size: 20, color: iconColor ?? Colors.white),
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
                    if (subtitle case final subtitle?)
                      Text(subtitle, style: onboardingNote(context)),
                    if (expanded.value) ...details,
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

  /// Room for a way's icon, title and a few lines of the community's words.
  static const _deckHeight = 180.0;

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

/// A way in, as a card in the deck of ways in: what admission under it
/// takes, or why this app cannot apply under it yet.
class _WayCard extends StatelessWidget {
  const _WayCard(this.way);

  final VtcJoinWay way;

  static const _radius = BorderRadius.all(Radius.circular(20));

  /// Blurs the card stacked behind, as the identity deck does.
  static const _blurSigma = 20.0;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: _radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: _blurSigma, sigmaY: _blurSigma),
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.white.withAlpha(60), Colors.white.withAlpha(25)],
            ),
            borderRadius: _radius,
            border: Border.all(color: Colors.white.withAlpha(90)),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              spacing: 8,
              children: [
                Icon(_iconOf(way), size: 28, color: Colors.white),
                Text(
                  _titleOf(context.l10n, way),
                  textAlign: TextAlign.center,
                  style: context.textTheme.titleSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (way.credentialType case final type?)
                  Text(
                    context.l10n.vtcJoinWayWithCredential(type),
                    textAlign: TextAlign.center,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: Colors.white,
                    ),
                  ),
                if (way.description case final description?)
                  Text(
                    description,
                    textAlign: TextAlign.center,
                    style: onboardingNote(context),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

IconData _iconOf(VtcJoinWay way) => way.unsupported != null
    ? Icons.block
    : way.automatic
    ? Icons.how_to_reg
    : Icons.rate_review;

String _titleOf(AppLocalizations l10n, VtcJoinWay way) => switch (way) {
  VtcJoinWay(unsupported: VtcJoinUnsupported.credentialMissing) =>
    l10n.vtcJoinCredentialMissing,
  VtcJoinWay(:final unsupported?) => l10n.vtcJoinWayUnsupported(
    unsupported.name,
  ),
  VtcJoinWay(automatic: true) => l10n.vtcJoinWayAutomatic,
  _ => l10n.vtcJoinWayReviewed,
};

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
                  icon: Icons.badge,
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
                  icon: Icons.badge,
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
        if (state.logoUrl case final logoUrl?) _Logo(logoUrl),
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

/// The member is a member: the community's message, the membership card it
/// issued — or that it is on its way to the member's VTA — then Done and
/// [leave].
class _Joined extends StatelessWidget {
  const _Joined({
    required this.state,
    required this.onDone,
    required this.leave,
  });

  final VtcJoinState state;
  final VoidCallback onDone;
  final Widget leave;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final name = state.communityName ?? '';
    final card = state.membershipCard;
    final delivery = state.cardDelivery;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 12,
      children: [
        const Icon(Icons.verified, size: 72, color: Colors.white),
        const SizedBox(height: 4),
        Text(
          state.wasMember
              ? l10n.vtcJoinAlreadyMember(name)
              : l10n.vtcJoinJoined(name),
          textAlign: TextAlign.center,
          style: context.textTheme.titleMedium?.copyWith(color: Colors.white),
        ),
        const SizedBox(height: 4),
        if (card != null) ...[
          VtcMembershipCardView(
            card: card,
            communityName: name,
            logoUrl: state.logoUrl,
          ),
          _CardRoute(communityName: name, memberDid: card.memberDid),
          if (delivery != null)
            _CardArrival(delivery: delivery, communityName: name),
        ] else if (delivery != null)
          VtcCardDeliveryTrail(delivery: delivery, communityName: name)
        else
          Row(
            key: const Key('vtc_membership_card_pending'),
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 8,
            children: [
              const Icon(Icons.hourglass_top, size: 16, color: Colors.white70),
              Flexible(
                child: Text(
                  l10n.vtcMembershipCardOnItsWay,
                  style: onboardingNote(context),
                ),
              ),
            ],
          ),
        if (state.identityCheck case final check?)
          VtcIdentityCheckView(check: check, communityName: name),
        const SizedBox(height: 12),
        OnboardingButton(label: l10n.generalDone, onPressed: onDone),
        leave,
      ],
    );
  }
}

/// Where the card on show came from, as the Credentials tab draws it: the
/// community issued it to the identity, which passed it on to the VTA.
class _CardRoute extends ConsumerWidget {
  const _CardRoute({required this.communityName, required this.memberDid});

  final String communityName;

  /// The DID of the identity the card is for.
  final String memberDid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final name = ref
        .watch(identitiesServiceProvider)
        .identities
        .where((identity) => identity.did == memberDid)
        .firstOrNull
        ?.card
        .displayName
        .trim();
    final identity = name == null || name.isEmpty
        ? l10n.vtcJoinTrailIdentity
        : name;
    return VtcFlowBox(
      key: const Key('vtc_join_card_route'),
      flow: VtcFlowDiagram(
        nodes: [
          VtcFlowNode(Icons.groups_outlined, l10n.membershipFlowCommunity),
          VtcFlowNode(Icons.person_outline, identity),
          VtcFlowNode(Icons.shield_outlined, l10n.membershipTrailYourVta),
        ],
      ),
      summary: Text(
        l10n.vtcJoinCardRoute(communityName, identity),
        style: onboardingNote(context),
      ),
    );
  }
}

/// How the card on show came to the VTA, folded away behind a toggle.
class _CardArrival extends HookWidget {
  const _CardArrival({required this.delivery, required this.communityName});

  final VtcCardDelivery delivery;
  final String communityName;

  @override
  Widget build(BuildContext context) {
    final expanded = useState(false);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 8,
      children: [
        InkWell(
          key: const Key('vtc_delivery_toggle'),
          onTap: () => expanded.value = !expanded.value,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              spacing: 8,
              children: [
                const Icon(Icons.route_outlined, color: Colors.white),
                Expanded(
                  child: Text(
                    context.l10n.vtcDeliveryHeading,
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),
                Icon(
                  expanded.value ? Icons.expand_less : Icons.expand_more,
                  color: Colors.white,
                ),
              ],
            ),
          ),
        ),
        if (expanded.value)
          VtcCardDeliveryTrail(
            delivery: delivery,
            communityName: communityName,
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
