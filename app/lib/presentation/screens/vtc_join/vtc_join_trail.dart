import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:meeting_place_vtc/meeting_place_vtc.dart';

import '../../../infrastructure/extensions/build_context_extensions.dart';
import '../../themes/tokens/mc_icons.dart';
import 'vtc_trail_step.dart';

/// Where an open application stands, drawn as the path it took: the
/// credentials it presents, if any; signed by the member's VTA as their
/// identity in the community, sent from this phone and answered by the
/// community, now with its administrators, and the membership card still
/// to come. Each step opens to the proof behind
/// it, and shows its signed document in full, as [submit] and [lastCheck]
/// hold them.
class VtcJoinTrail extends StatelessWidget {
  const VtcJoinTrail({
    super.key,
    required this.communityName,
    required this.autoCheckInterval,
    this.submit,
    this.receipt,
    this.requestId,
    this.deferred = false,
    this.checking = false,
    this.lastCheckedAt,
    this.lastCheck,
  });

  final String communityName;

  /// The signed application and the community's verified answer, or null
  /// when this phone has no receipt for it.
  final TrustTaskExchange? submit;

  /// What shows the application was signed and answered when this phone
  /// keeps no documents for it, only the receipt.
  final TrustTaskReceipt? receipt;

  /// The community's id of the application, if known.
  final String? requestId;

  /// Whether the administrators put the application off.
  final bool deferred;

  /// Whether this phone is asking the community right now; the review
  /// step's marker turns while it does.
  final bool checking;

  /// When this phone last asked the community, if it has since applying.
  final DateTime? lastCheckedAt;

  /// The last signed status request and the community's verified answer.
  final TrustTaskExchange? lastCheck;

  /// How often the screen asks the community again.
  final Duration autoCheckInterval;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final receipt = submit?.receipt ?? this.receipt;
    final presentation = _presentationOf(submit);
    final credentials = _credentialsOf(presentation);
    final lastCheck = this.lastCheck?.receipt;
    final locale = l10n.localeName;
    String time(DateTime at) =>
        DateFormat.yMMMd(locale).add_Hm().format(at.toLocal());
    // How a document was signed, as far as its proof says.
    List<VtcTrailDetail> proof({
      String? cryptosuite,
      String? key,
      String? purpose,
      DateTime? signedAt,
    }) => [
      if (cryptosuite != null)
        VtcTrailDetail(
          McIcons.encrypted,
          l10n.vtcJoinTrailCryptosuite,
          cryptosuite,
        ),
      if (key != null)
        VtcTrailDetail(McIcons.key, l10n.vtcJoinTrailKey, key, isId: true),
      if (purpose != null)
        VtcTrailDetail(
          McIcons.verified,
          l10n.vtcJoinTrailProofPurpose,
          purpose,
        ),
      if (signedAt != null)
        VtcTrailDetail(
          McIcons.clock,
          l10n.vtcJoinTrailSignedAt,
          time(signedAt),
        ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (presentation != null && credentials.isNotEmpty)
          VtcTrailStep(
            key: const Key('vtc_join_trail_presentation'),
            icon: McIcons.award,
            stage: VtcTrailStage.done,
            title: l10n.vtcJoinTrailPresentation,
            summary: l10n.vtcJoinTrailPresentationSummary(
              credentials.map(_typesOf).join(', '),
            ),
            // Found and read on the VTA; the presentation itself is built
            // on this phone.
            tasks: const [VtaTask.credentialsQuery, VtaTask.credentialsGet],
            details: [
              if (presentation['holder'] case final String holder)
                VtcTrailDetail(
                  McIcons.identities,
                  l10n.vtcJoinTrailHolder,
                  holder,
                  isId: true,
                ),
              for (final credential in credentials) ...[
                VtcTrailDetail(
                  McIcons.award,
                  l10n.vtcJoinTrailCredential,
                  _typesOf(credential),
                ),
                if (_issuerOf(credential) case final issuer?)
                  VtcTrailDetail(
                    McIcons.institution,
                    l10n.vtcJoinTrailIssuer,
                    issuer,
                    isId: true,
                  ),
                if (DateTime.tryParse('${credential['validUntil']}')
                    case final until?)
                  VtcTrailDetail(
                    McIcons.calendar,
                    l10n.vtcJoinTrailValidUntil,
                    time(until),
                  ),
              ],
            ],
            document: presentation,
            documentTitle: l10n.vtcJoinTrailPresentationDocument,
            documentKey: const Key('vtc_join_trail_presentation_document'),
          ),
        VtcTrailStep(
          key: const Key('vtc_join_trail_vta'),
          icon: McIcons.signature,
          stage: VtcTrailStage.done,
          title: l10n.vtcJoinTrailVta,
          summary: switch (receipt) {
            TrustTaskReceipt(:final cryptosuite?, :final signedAt?) =>
              l10n.vtcJoinTrailVtaSummary(
                communityName,
                cryptosuite,
                time(signedAt),
              ),
            _ => l10n.vtcJoinTrailVtaIdentity(communityName),
          },
          // The VTA signs the application as the member's identity.
          tasks: [VtaTask.signTrustTask, ?receipt?.type],
          details: [
            if (receipt != null) ...[
              VtcTrailDetail(
                McIcons.identities,
                l10n.vtcJoinTrailIdentity,
                receipt.signer,
                isId: true,
              ),
              ...proof(
                cryptosuite: receipt.cryptosuite,
                key: receipt.verificationMethod,
                purpose: receipt.proofPurpose,
                signedAt: receipt.signedAt,
              ),
            ],
          ],
          document: submit?.request.toJson(),
          documentTitle: l10n.vtcJoinTrailSubmitDocument,
          documentKey: const Key('vtc_join_trail_vta_document'),
        ),
        VtcTrailStep(
          key: const Key('vtc_join_trail_community'),
          icon: McIcons.credentials,
          stage: VtcTrailStage.done,
          title: l10n.vtcJoinTrailCommunity(communityName),
          summary: receipt == null
              ? l10n.vtcJoinTrailNoReceipt
              : l10n.vtcJoinTrailCommunitySummary,
          tasks: [?receipt?.answerType],
          details: [
            if (receipt != null) ...[
              VtcTrailDetail(
                McIcons.community,
                l10n.vtcJoinTrailAnsweredBy,
                receipt.answeredBy,
                isId: true,
              ),
              if (receipt.answeredAt case final at?)
                VtcTrailDetail(
                  McIcons.clock,
                  l10n.vtcJoinTrailAnsweredAt,
                  time(at),
                ),
              ...proof(
                cryptosuite: receipt.answerCryptosuite,
                key: receipt.answerVerificationMethod,
                purpose: receipt.answerProofPurpose,
                signedAt: receipt.answerSignedAt,
              ),
            ],
            if (requestId case final id?)
              VtcTrailDetail(
                McIcons.tag,
                l10n.vtcJoinTrailRequestId,
                id,
                isId: true,
              ),
          ],
          document: submit?.answer.toJson(),
          documentTitle: l10n.vtcJoinTrailAnswerDocument,
          documentKey: const Key('vtc_join_trail_community_document'),
        ),
        VtcTrailStep(
          key: const Key('vtc_join_trail_review'),
          icon: deferred ? McIcons.clock : McIcons.pending,
          stage: VtcTrailStage.current,
          busy: checking,
          title: deferred ? l10n.vtcJoinTrailDeferred : l10n.vtcJoinTrailReview,
          summary: switch (lastCheckedAt) {
            final at? => l10n.vtcJoinTrailLastChecked(
              DateFormat.Hm(locale).format(at),
            ),
            null => l10n.vtcJoinTrailAutoCheck(autoCheckInterval.inSeconds),
          },
          details: [
            if (lastCheck != null) ...[
              VtcTrailDetail(
                McIcons.clipboard,
                l10n.vtcJoinTrailCheckTask,
                lastCheck.type,
              ),
              if (lastCheck.signedAt case final at?)
                VtcTrailDetail(
                  McIcons.clock,
                  l10n.vtcJoinTrailCheckSignedAt,
                  time(at),
                ),
              if (lastCheck.answeredAt case final at?)
                VtcTrailDetail(
                  McIcons.clock,
                  l10n.vtcJoinTrailCheckAnsweredAt,
                  time(at),
                ),
              if (lastCheck.answerVerificationMethod case final key?)
                VtcTrailDetail(
                  McIcons.key,
                  l10n.vtcJoinTrailCheckAnswerKey,
                  key,
                  isId: true,
                ),
            ],
          ],
          document: this.lastCheck?.answer.toJson(),
          documentTitle: l10n.vtcJoinTrailCheckDocument,
          documentKey: const Key('vtc_join_trail_review_document'),
        ),
        VtcTrailStep(
          key: const Key('vtc_join_trail_card'),
          icon: McIcons.badge,
          stage: VtcTrailStage.next,
          title: l10n.vtcJoinTrailCard,
          summary: l10n.vtcJoinTrailCardSummary,
          // Sent by the community, kept on the VTA, and the membership
          // confirmed back to the community.
          tasks: const [
            credentialIssueTask,
            VtaTask.credentialsReceive,
            MemberTask.vmc,
          ],
          isLast: true,
        ),
      ],
    );
  }
}

/// The withdraw, as a step of the application's trail: signed by the
/// member's VTA and confirmed by the community, its signed [exchange]
/// behind an icon. Without one, the community no longer held the
/// application open, and there is nothing to show.
class VtcWithdrawStep extends StatelessWidget {
  const VtcWithdrawStep({
    super.key,
    required this.communityName,
    this.exchange,
  });

  final String communityName;
  final TrustTaskExchange? exchange;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final receipt = exchange?.receipt;
    String time(DateTime at) =>
        DateFormat.yMMMd(l10n.localeName).add_Hm().format(at.toLocal());
    return VtcTrailStep(
      key: const Key('vtc_join_trail_withdrawn'),
      icon: McIcons.undo,
      stage: VtcTrailStage.done,
      title: l10n.vtcJoinTrailWithdrawn,
      summary: receipt == null
          ? l10n.vtcJoinTrailWithdrawnNotHeld(communityName)
          : l10n.vtcJoinTrailWithdrawnSummary(communityName),
      highlights: [communityName],
      tasks: const [VtaTask.signTrustTask, JoinTask.withdraw],
      details: [
        if (receipt != null) ...[
          if (receipt.signedAt case final at?)
            VtcTrailDetail(McIcons.clock, l10n.vtcJoinTrailSignedAt, time(at)),
          VtcTrailDetail(
            McIcons.community,
            l10n.vtcJoinTrailAnsweredBy,
            receipt.answeredBy,
            isId: true,
          ),
          if (receipt.answeredAt case final at?)
            VtcTrailDetail(
              McIcons.clock,
              l10n.vtcJoinTrailAnsweredAt,
              time(at),
            ),
        ],
      ],
      document: exchange?.toJson(),
      documentTitle: l10n.vtcJoinTrailWithdrawnDocument,
      documentKey: const Key('vtc_join_trail_withdrawn_document'),
      isLast: true,
    );
  }
}

/// The presentation [submit] carries, as the application holds it.
Map<String, dynamic>? _presentationOf(TrustTaskExchange? submit) =>
    switch (submit?.request.payload['vp']) {
      final Map<String, dynamic> vp => vp,
      _ => null,
    };

/// The credentials [presentation] holds.
List<Map<String, dynamic>> _credentialsOf(Map<String, dynamic>? presentation) =>
    switch (presentation?['verifiableCredential']) {
      final Map<String, dynamic> credential => [credential],
      final List<dynamic> credentials =>
        credentials.whereType<Map<String, dynamic>>().toList(),
      _ => const [],
    };

/// A credential's own types, without the `VerifiableCredential` every one
/// has.
String _typesOf(Map<String, dynamic> credential) {
  final types = switch (credential['type']) {
    final String type => [type],
    final List<dynamic> types => types.whereType<String>(),
    _ => const <String>[],
  }.where((type) => type != 'VerifiableCredential');
  return types.isEmpty ? 'VerifiableCredential' : types.join(', ');
}

String? _issuerOf(Map<String, dynamic> credential) =>
    switch (credential['issuer']) {
      final String id => id,
      {'id': final String id} => id,
      _ => null,
    };
