import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:intl/intl.dart';
import 'package:meeting_place_vtc/meeting_place_vtc.dart';

import '../../../infrastructure/extensions/build_context_extensions.dart';
import '../../widgets/onboarding_style/onboarding_style.dart';

/// Where an open application stands, drawn as the path it took: signed by
/// the member's VTA as their identity in the community, sent from this
/// phone and answered by the community, now with its administrators, and
/// the membership card still to come. Each step opens to the proof behind
/// it, as [receipt] and [lastCheck] hold it.
class VtcJoinTrail extends StatelessWidget {
  const VtcJoinTrail({
    super.key,
    required this.communityName,
    required this.autoCheckInterval,
    this.receipt,
    this.requestId,
    this.deferred = false,
    this.lastCheckedAt,
    this.lastCheck,
  });

  final String communityName;

  /// The signed application and the community's verified answer, or null
  /// when this phone has no receipt for it.
  final TrustTaskReceipt? receipt;

  /// The community's id of the application, if known.
  final String? requestId;

  /// Whether the administrators put the application off.
  final bool deferred;

  /// When this phone last asked the community, if it has since applying.
  final DateTime? lastCheckedAt;

  /// The last signed status request and the community's verified answer.
  final TrustTaskReceipt? lastCheck;

  /// How often the screen asks the community again.
  final Duration autoCheckInterval;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final receipt = this.receipt;
    final lastCheck = this.lastCheck;
    final locale = l10n.localeName;
    String time(DateTime at) =>
        DateFormat.yMMMd(locale).add_Hm().format(at.toLocal());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Step(
          key: const Key('vtc_join_trail_vta'),
          icon: Icons.draw_outlined,
          stage: _Stage.done,
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
          details: [
            if (receipt != null) ...[
              _Detail(l10n.vtcJoinTrailIdentity, receipt.signer, isId: true),
              _Detail(l10n.vtcJoinTrailTask, receipt.type),
              _Detail(
                l10n.vtcJoinTrailDocument,
                receipt.documentId,
                isId: true,
              ),
              if (receipt.cryptosuite case final cryptosuite?)
                _Detail(l10n.vtcJoinTrailCryptosuite, cryptosuite),
              if (receipt.verificationMethod case final key?)
                _Detail(l10n.vtcJoinTrailKey, key, isId: true),
              if (receipt.signedAt case final at?)
                _Detail(l10n.vtcJoinTrailSignedAt, time(at)),
            ],
          ],
        ),
        _Step(
          key: const Key('vtc_join_trail_community'),
          icon: Icons.verified_user_outlined,
          stage: _Stage.done,
          title: l10n.vtcJoinTrailCommunity(communityName),
          summary: receipt == null
              ? l10n.vtcJoinTrailNoReceipt
              : l10n.vtcJoinTrailCommunitySummary,
          details: [
            if (receipt != null) ...[
              _Detail(
                l10n.vtcJoinTrailAnsweredBy,
                receipt.answeredBy,
                isId: true,
              ),
              if (receipt.answeredAt case final at?)
                _Detail(l10n.vtcJoinTrailAnsweredAt, time(at)),
            ],
            if (requestId case final id?)
              _Detail(l10n.vtcJoinTrailRequestId, id, isId: true),
          ],
        ),
        _Step(
          key: const Key('vtc_join_trail_review'),
          icon: deferred ? Icons.schedule : Icons.hourglass_top,
          stage: _Stage.current,
          title: deferred ? l10n.vtcJoinTrailDeferred : l10n.vtcJoinTrailReview,
          summary: switch (lastCheckedAt) {
            final at? => l10n.vtcJoinTrailLastChecked(
              DateFormat.Hm(locale).format(at),
            ),
            null => l10n.vtcJoinTrailAutoCheck(autoCheckInterval.inSeconds),
          },
          details: [
            if (lastCheck != null) ...[
              _Detail(l10n.vtcJoinTrailCheckTask, lastCheck.type),
              if (lastCheck.signedAt case final at?)
                _Detail(l10n.vtcJoinTrailCheckSignedAt, time(at)),
              if (lastCheck.answeredAt case final at?)
                _Detail(l10n.vtcJoinTrailCheckAnsweredAt, time(at)),
            ],
          ],
        ),
        _Step(
          key: const Key('vtc_join_trail_card'),
          icon: Icons.badge_outlined,
          stage: _Stage.next,
          title: l10n.vtcJoinTrailCard,
          summary: l10n.vtcJoinTrailCardSummary,
          isLast: true,
        ),
      ],
    );
  }
}

/// How far the application got with a step.
enum _Stage { done, current, next }

/// One technical fact behind a step, such as the key that signed.
class _Detail {
  const _Detail(this.label, this.value, {this.isId = false});

  final String label;
  final String value;

  /// Whether [value] is an identifier, such as a DID, a DID URL or a
  /// document id, shown in monospace.
  final bool isId;
}

/// A step of the trail: a marker on the line, a title and summary, and its
/// [details] shown on tap.
class _Step extends HookWidget {
  const _Step({
    super.key,
    required this.icon,
    required this.stage,
    required this.title,
    required this.summary,
    this.details = const [],
    this.isLast = false,
  });

  final IconData icon;
  final _Stage stage;
  final String title;
  final String summary;
  final List<_Detail> details;
  final bool isLast;

  static const _markerSize = 32.0;
  static const _lineWidth = 2.0;

  @override
  Widget build(BuildContext context) {
    final expanded = useState(false);
    final canExpand = details.isNotEmpty;
    final foreground = stage == _Stage.next ? Colors.white54 : Colors.white;

    return InkWell(
      onTap: canExpand ? () => expanded.value = !expanded.value : null,
      // The line runs the step's full height, so the row is as tall as its
      // text.
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 12,
          children: [
            Column(
              children: [
                _Marker(icon: icon, stage: stage, size: _markerSize),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: _lineWidth,
                      color: stage == _Stage.done
                          ? Colors.white70
                          : Colors.white24,
                    ),
                  ),
              ],
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(top: 6, bottom: isLast ? 0 : 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 4,
                  children: [
                    Text(
                      title,
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: foreground,
                        fontWeight: stage == _Stage.current
                            ? FontWeight.bold
                            : null,
                      ),
                    ),
                    Text(summary, style: onboardingNote(context)),
                    if (expanded.value)
                      for (final detail in details) ...[
                        Text(detail.label, style: onboardingNote(context)),
                        if (detail.isId)
                          MonospaceDid(detail.value)
                        else
                          SelectableText(
                            detail.value,
                            style: context.textTheme.bodySmall?.copyWith(
                              color: Colors.white,
                            ),
                          ),
                      ],
                  ],
                ),
              ),
            ),
            if (canExpand)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Icon(
                  expanded.value ? Icons.expand_less : Icons.expand_more,
                  color: Colors.white,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// A step's marker: filled when done, ringed when current, faint when
/// still to come.
class _Marker extends StatelessWidget {
  const _Marker({required this.icon, required this.stage, required this.size});

  final IconData icon;
  final _Stage stage;
  final double size;

  @override
  Widget build(BuildContext context) {
    final done = stage == _Stage.done;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: done ? Colors.white : Colors.white.withAlpha(25),
        border: Border.all(
          color: stage == _Stage.next ? Colors.white38 : Colors.white,
          width: 2,
        ),
      ),
      child: Icon(
        icon,
        size: size / 2,
        color: done
            ? context.colorScheme.primary
            : stage == _Stage.next
            ? Colors.white54
            : Colors.white,
      ),
    );
  }
}
