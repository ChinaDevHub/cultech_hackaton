import 'package:material_ui/material_ui.dart';

/// Plays a one-shot fade + slide entrance when first inserted into the tree.
///
/// Give it a stable key (e.g. the entity id) inside lists so only genuinely
/// new items animate.
class FadeSlideIn extends StatefulWidget {
  const FadeSlideIn({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 520),
    this.offset = const Offset(0, 0.08),
    this.highlight,
  });

  final Widget child;
  final Duration delay;
  final Duration duration;
  final Offset offset;

  /// When set, a soft glow of this color fades out behind the child.
  final Color? highlight;

  @override
  State<FadeSlideIn> createState() => _FadeSlideInState();
}

class _FadeSlideInState extends State<FadeSlideIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.duration,
  );
  late final Animation<double> _curve = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOutCubic,
  );
  late final Animation<Offset> _slide = Tween<Offset>(
    begin: widget.offset,
    end: Offset.zero,
  ).animate(_curve);

  @override
  void initState() {
    super.initState();
    if (widget.delay == Duration.zero) {
      _controller.forward();
    } else {
      Future<void>.delayed(widget.delay, () {
        if (mounted) _controller.forward();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget content = SlideTransition(
      position: _slide,
      child: FadeTransition(opacity: _curve, child: widget.child),
    );
    final Color? highlight = widget.highlight;
    if (highlight != null) {
      content = AnimatedBuilder(
        animation: _controller,
        builder: (BuildContext context, Widget? child) {
          final double glow = (1 - _controller.value) * 0.18;
          return DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: highlight.withValues(alpha: glow),
            ),
            child: child,
          );
        },
        child: content,
      );
    }
    return content;
  }
}
