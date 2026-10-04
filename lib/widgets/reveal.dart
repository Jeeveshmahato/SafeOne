import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// Scrolls the nearest scrollable just enough to show all of [context]'s
/// widget, e.g. a section that has just expanded near the bottom of the
/// screen. It never scrolls the widget's top edge (its header) out of view:
/// if the widget is taller than the screen, it's aligned to the top instead.
///
/// Call it after the expand animation has finished so the final size is
/// measured. Respects the system "remove animations" setting.
Future<void> revealInScrollable(BuildContext context,
    {double topPadding = 8}) async {
  // Two passes: a list's scroll range can grow a frame after its content
  // does, so check again once the first scroll has settled.
  for (var pass = 0; pass < 2; pass++) {
    // Measure only after the frame that lays out the final size.
    await WidgetsBinding.instance.endOfFrame;
    if (!context.mounted) return;
    if (!await _revealOnce(context, topPadding)) return;
  }
}

/// Scrolls once if needed; returns whether it scrolled.
Future<bool> _revealOnce(BuildContext context, double topPadding) async {
  final object = context.findRenderObject();
  if (object == null || !object.attached) return false;
  final viewport = RenderAbstractViewport.maybeOf(object);
  final scrollable = Scrollable.maybeOf(context);
  if (viewport == null || scrollable == null) return false;

  final position = scrollable.position;
  // Offset that puts the widget's bottom at the bottom of the viewport, and
  // the offset that puts its top at the top.
  final bottomAligned = viewport.getOffsetToReveal(object, 1.0).offset;
  final topAligned = viewport.getOffsetToReveal(object, 0.0).offset - topPadding;
  final target = (bottomAligned < topAligned ? bottomAligned : topAligned)
      .clamp(position.minScrollExtent, position.maxScrollExtent);
  // Only ever scroll *down* to reveal; never yank content the user is
  // already looking at.
  if (target <= position.pixels + 1) return false;

  final instant = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
  if (instant) {
    position.jumpTo(target);
  } else {
    await position.animateTo(
      target,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );
  }
  return true;
}

/// An [ExpansionTile] that, when opened, scrolls its content into view.
///
/// Without this, opening a tile near the bottom of a list expands its content
/// below the screen edge, so it looks like nothing happened.
class RevealExpansionTile extends StatefulWidget {
  const RevealExpansionTile({
    super.key,
    required this.title,
    required this.children,
    this.leading,
    this.subtitle,
    this.childrenPadding,
    this.expandedCrossAxisAlignment,
    this.shape,
    this.collapsedShape,
  });

  final Widget title;
  final List<Widget> children;
  final Widget? leading;
  final Widget? subtitle;
  final EdgeInsetsGeometry? childrenPadding;
  final CrossAxisAlignment? expandedCrossAxisAlignment;
  final ShapeBorder? shape;
  final ShapeBorder? collapsedShape;

  @override
  State<RevealExpansionTile> createState() => _RevealExpansionTileState();
}

class _RevealExpansionTileState extends State<RevealExpansionTile> {
  // ExpansionTile's expand animation (200ms). [revealInScrollable] then waits
  // for the next laid-out frame, so the final height is what gets measured.
  static const _expandDuration = Duration(milliseconds: 200);

  Future<void> _onExpansionChanged(bool expanded) async {
    if (!expanded) return;
    await Future<void>.delayed(_expandDuration);
    if (mounted) await revealInScrollable(context);
  }

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      leading: widget.leading,
      title: widget.title,
      subtitle: widget.subtitle,
      shape: widget.shape,
      collapsedShape: widget.collapsedShape,
      childrenPadding: widget.childrenPadding,
      expandedCrossAxisAlignment: widget.expandedCrossAxisAlignment,
      onExpansionChanged: _onExpansionChanged,
      children: widget.children,
    );
  }
}
