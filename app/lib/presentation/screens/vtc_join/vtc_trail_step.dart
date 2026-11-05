import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../../infrastructure/extensions/build_context_extensions.dart';
import '../../widgets/onboarding_style/onboarding_style.dart';
import 'vtc_detail_line.dart';
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

  /// Names in [summary], such as the member's identity and the community,
  /// set apart from the words around them.
  final List<String> highlights;

  /// What the summary says, pictured under it, such as a
  /// `VtcFlowDiagram`.
  final Widget? flow;

  static const _markerSize = 32.0;

  /// Room above each detail, beyond the column's own spacing.
  static const _detailSpacing = 10.0;
  static const _lineWidth = 2.0;

  @override
  Widget build(BuildContext context) {
    final expanded = useState(false);
    final details = [
      if (actor case final actor?)
        VtcTrailDetail(
          Icons.how_to_reg_outlined,
          context.l10n.vtcTrailDoneBy,
          actor,
        ),
      ...this.details,
    ];
    final canExpand = details.isNotEmpty;
    final document = this.document;
    final foreground = stage == VtcTrailStage.next
        ? Colors.white54
        : Colors.white;

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
                                      ? FontWeight.bold
                                      : null,
                                ),
                              ),
                              Text.rich(
                                _summarySpan(),
                                style: onboardingNote(context),
                              ),
                              if (flow case final flow?)
                                Padding(
                                  padding: const EdgeInsets.only(top: 6),
                                  child: flow,
                                ),
                            ],
                          ),
                        ),
                        if (document != null)
                          IconButton(
                            key: documentKey,
                            icon: const Icon(
                              Icons.receipt_long_outlined,
                              color: Colors.white,
                            ),
                            tooltip: context.l10n.vtcJoinTrailShowDocument,
                            visualDensity: VisualDensity.compact,
                            onPressed: () => showVtcJoinJson(
                              context,
                              title: documentTitle,
                              json: document,
                              icon: Icons.receipt_long_outlined,
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
                                  ? Icons.expand_less
                                  : Icons.expand_more,
                              color: Colors.white,
                            ),
                          ),
                      ],
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
  static const _highlight = TextStyle(
    color: Colors.white,
    fontWeight: FontWeight.bold,
  );

  TextSpan _summarySpan() {
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
      spans.add(TextSpan(text: name, style: _highlight));
      at = start + name.length;
    }
    return TextSpan(children: spans);
  }
}

/// A step's marker: filled when done, ringed when current, faint when
/// still to come, and marked in the error colour when it failed. While
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

    final done = stage == VtcTrailStage.done;
    final failed = stage == VtcTrailStage.failed;
    return Container(
      key: failed ? const Key('vtc_trail_marker_failed') : null,
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: switch (stage) {
          VtcTrailStage.done => Colors.white,
          VtcTrailStage.failed => context.colorScheme.error,
          _ => Colors.white.withAlpha(25),
        },
        border: Border.all(
          color: stage == VtcTrailStage.next ? Colors.white38 : Colors.white,
          width: 2,
        ),
      ),
      child: RotationTransition(
        key: busy ? const Key('vtc_join_trail_marker_busy') : null,
        turns: turns,
        child: Icon(
          failed ? Icons.priority_high : icon,
          size: size / 2,
          color: done
              ? context.colorScheme.primary
              : stage == VtcTrailStage.next
              ? Colors.white54
              : Colors.white,
        ),
      ),
    );
  }
}
