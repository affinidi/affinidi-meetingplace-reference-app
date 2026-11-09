import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../../infrastructure/extensions/build_context_extensions.dart';
import '../../themes/tokens/mc_colors.dart';
import '../../themes/tokens/mc_icons.dart';
import '../../widgets/onboarding_style/onboarding_style.dart';
import 'vtc_detail_line.dart';
import 'vtc_flow_diagram.dart';
import 'vtc_join_json_dialog.dart';

/// How far a trail got with a step.
enum VtcTrailStage {
  /// Done.
  done,

  /// Being worked on, or waited for.
  current,

  /// Still to come.
  next,

  /// Failed this time.
  failed,
}

/// One technical fact behind a step, such as the key that signed, with an
/// icon for what it is.
class VtcTrailDetail {
  /// Creates a [VtcTrailDetail].
  const VtcTrailDetail(this.icon, this.label, this.value, {this.isId = false})
    : items = const [];

  /// Creates a [VtcTrailDetail] of several [items], listed one a line.
  const VtcTrailDetail.list(this.icon, this.label, this.items)
    : value = '',
      isId = false;

  final IconData icon;
  final String label;
  final String value;

  /// The fact's items, when it has several.
  final List<String> items;

  /// Whether [value] is an identifier, such as a DID, a DID URL or a
  /// document id, shown in monospace.
  final bool isId;
}

/// A step of the trail: a marker on the line, a title and summary with its
/// actions beside them — its signed [document], if any, behind an icon, and
/// the toggle for its [details] — and the details below, shown on tap.
class VtcTrailStep extends HookWidget {
  /// Creates a [VtcTrailStep].
  const VtcTrailStep({
    super.key,
    required this.icon,
    required this.stage,
    required this.title,
    required this.summary,
    this.details = const [],
    this.document,
    this.documentTitle = '',
    this.documentKey,
    this.busy = false,
    this.isLast = false,
    this.actor,
    this.tasks = const [],
    this.highlights = const [],
    this.flow,
  });

  final IconData icon;
  final VtcTrailStage stage;
  final String title;
  final String summary;
  final List<VtcTrailDetail> details;

  /// The signed document behind the step, as it was on the wire.
  final Map<String, dynamic>? document;
  final String documentTitle;
  final Key? documentKey;

  /// Whether the step is being worked on right now, which its marker shows.
  final bool busy;
  final bool isLast;

  /// Who did the step, such as the member's VTA, if the trail says: the
  /// first of its details.
  final String? actor;

  /// The Trust Tasks the step took, by Type URI: listed after [actor], so
  /// whoever reads the details can match the step to the audit trails.
  final List<String> tasks;

  /// Names in [summary], such as the member's identity and the community,
  /// set apart from the words around them.
  final List<String> highlights;

  /// What the summary says, pictured once the step is opened, such as a
  /// `VtcFlowDiagram`: in a tinted box above the [details], the summary
  /// moved under it.
  final Widget? flow;

  static const _markerSize = 32.0;

  /// Room above each detail, beyond the column's own spacing.
  static const _detailSpacing = 10.0;

  /// Room between a step's picture and its details, beyond theirs.
  static const _flowSpacing = 6.0;
  static const _lineWidth = 2.0;

  @override
  Widget build(BuildContext context) {
    final expanded = useState(false);
    final details = [
      if (actor case final actor?)
        VtcTrailDetail(McIcons.userCheck, context.l10n.vtcTrailDoneBy, actor),
      if (tasks case [final task])
        VtcTrailDetail(McIcons.clipboard, context.l10n.vtcJoinTrailTask, task)
      else if (tasks.isNotEmpty)
        VtcTrailDetail.list(
          McIcons.clipboard,
          context.l10n.vtcTrailTasks,
          tasks,
        ),
      ...this.details,
    ];
    final canExpand = details.isNotEmpty || flow != null;
    // Once opened, the summary moves under the step's picture, if any.
    final pictured = expanded.value && flow != null;
    final mc = context.mcColors;
    final summary = Text.rich(
      _summarySpan(mc.textPrimary),
      style: onboardingNote(context),
    );
    final document = this.document;
    final foreground = stage == VtcTrailStage.next
        ? mc.textTertiary
        : mc.textPrimary;

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
                VtcTrailMarker(
                  icon: icon,
                  stage: stage,
                  size: _markerSize,
                  busy: busy,
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: _lineWidth,
                      color: stage == VtcTrailStage.done
                          ? McColors.blue
                          : mc.hairlineStrong,
                    ),
                  ),
              ],
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(top: 6, bottom: isLast ? 0 : 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // The step's actions sit beside its title, so the
                    // details below have the step's full width.
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            spacing: 4,
                            children: [
                              Text(
                                title,
                                style: context.textTheme.bodyMedium?.copyWith(
                                  color: foreground,
                                  fontWeight: stage == VtcTrailStage.current
                                      ? FontWeight.w500
                                      : null,
                                ),
                              ),
                              if (!pictured) summary,
                            ],
                          ),
                        ),
                        if (document != null)
                          IconButton(
                            key: documentKey,
                            icon: Icon(McIcons.receipt, color: mc.textPrimary),
                            tooltip: context.l10n.vtcJoinTrailShowDocument,
                            visualDensity: VisualDensity.compact,
                            onPressed: () => showVtcJoinJson(
                              context,
                              title: documentTitle,
                              json: document,
                              icon: McIcons.receipt,
                              subtitle: switch (document['type']) {
                                final String type => type,
                                _ => null,
                              },
                            ),
                          ),
                        if (canExpand)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Icon(
                              expanded.value
                                  ? McIcons.chevronUp
                                  : McIcons.chevronDown,
                              color: mc.textSecondary,
                            ),
                          ),
                      ],
                    ),
                    // Opened, the picture and, under it, what it shows.
                    if (pictured)
                      Padding(
                        padding: const EdgeInsets.only(
                          top: _detailSpacing,
                          bottom: _flowSpacing,
                        ),
                        child: VtcFlowBox(
                          key: const Key('vtc_trail_flow_box'),
                          flow: flow!,
                          summary: summary,
                        ),
                      ),
                    if (expanded.value)
                      for (final detail in details)
                        Padding(
                          padding: const EdgeInsets.only(top: _detailSpacing),
                          child: VtcDetailLine(
                            icon: detail.icon,
                            label: detail.label,
                            value: detail.value,
                            isId: detail.isId,
                            items: detail.items,
                          ),
                        ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Splits a step's summary into its words and its [VtcTrailStep.highlights],
/// the first and longest name found at each place.
extension on VtcTrailStep {
  TextSpan _summarySpan(Color highlightColor) {
    final highlight = TextStyle(
      color: highlightColor,
      fontWeight: FontWeight.w500,
    );
    final names = highlights.where((name) => name.isNotEmpty).toList()
      ..sort((a, b) => b.length.compareTo(a.length));
    final spans = <TextSpan>[];
    var at = 0;
    while (at < summary.length) {
      final (start, name) = names
          .map((name) => (summary.indexOf(name, at), name))
          .where((found) => found.$1 >= 0)
          .fold<(int, String?)>((
            summary.length,
            null,
          ), (first, found) => found.$1 < first.$1 ? found : first);
      if (start > at) spans.add(TextSpan(text: summary.substring(at, start)));
      if (name == null) break;
      spans.add(TextSpan(text: name, style: highlight));
      at = start + name.length;
    }
    return TextSpan(children: spans);
  }
}

/// A step's marker: filled when done, ringed when current, faint when
/// still to come, and ringed in the danger colour, never filled, when it
/// failed. While
/// [busy], its icon turns, easing round once a cycle, and comes to rest
/// upright.
class VtcTrailMarker extends HookWidget {
  /// Creates a [VtcTrailMarker].
  const VtcTrailMarker({
    required this.icon,
    required this.stage,
    required this.size,
    this.busy = false,
  });

  final IconData icon;
  final VtcTrailStage stage;
  final double size;
  final bool busy;

  static const _turn = Duration(milliseconds: 1200);

  @override
  Widget build(BuildContext context) {
    final turning = useAnimationController(duration: _turn);
    useEffect(() {
      if (busy) {
        turning.repeat();
      } else {
        // Finish the turn under way, so the icon comes to rest upright.
        if (turning.isAnimating) turning.forward();
      }
      return null;
    }, [busy]);
    final turns = useMemoized(
      () => turning.drive(CurveTween(curve: Curves.easeInOutCubic)),
      [turning],
    );

    final mc = context.mcColors;
    final failed = stage == VtcTrailStage.failed;
    return Container(
      key: failed ? const Key('vtc_trail_marker_failed') : null,
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: switch (stage) {
          VtcTrailStage.done => McColors.blue,
          VtcTrailStage.failed => mc.dangerText.withValues(alpha: 0.12),
          VtcTrailStage.current => McColors.controlHoverWash,
          VtcTrailStage.next => Colors.transparent,
        },
        border: Border.all(
          color: switch (stage) {
            VtcTrailStage.done || VtcTrailStage.current => McColors.blue,
            VtcTrailStage.failed => mc.dangerText,
            VtcTrailStage.next => mc.hairlineStrong,
          },
          width: 2,
        ),
      ),
      child: RotationTransition(
        key: busy ? const Key('vtc_join_trail_marker_busy') : null,
        turns: turns,
        child: Icon(
          failed ? McIcons.error : icon,
          size: size / 2,
          color: switch (stage) {
            VtcTrailStage.done => McColors.textOnPrimary,
            VtcTrailStage.failed => mc.dangerText,
            VtcTrailStage.current => mc.textPrimary,
            VtcTrailStage.next => mc.textTertiary,
          },
        ),
      ),
    );
  }
}
