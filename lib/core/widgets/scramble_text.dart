import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

/// "Decrypting" text effect: when [text] changes, characters resolve from
/// random glyphs into the final string from left to right.
class ScrambleText extends StatefulWidget {
  const ScrambleText(
    this.text, {
    super.key,
    this.style,
    this.duration = const Duration(milliseconds: 900),
    this.maxLines = 1,
  });

  final String text;
  final TextStyle? style;
  final Duration duration;
  final int maxLines;

  @override
  State<ScrambleText> createState() => _ScrambleTextState();
}

class _ScrambleTextState extends State<ScrambleText>
    with SingleTickerProviderStateMixin {
  static const String _glyphs = 'abcdef0123456789#%&@*';

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.duration,
    value: 1,
  );
  final math.Random _random = math.Random();

  @override
  void didUpdateWidget(ScrambleText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _frame(double t) {
    if (t >= 1) return widget.text;
    final String target = widget.text;
    final int resolved = (target.length * Curves.easeOut.transform(t)).floor();
    final StringBuffer buffer = StringBuffer(target.substring(0, resolved));
    for (int i = resolved; i < target.length; i++) {
      final String char = target[i];
      buffer.write(
        char == '_' || char == ' ' || char == '•'
            ? char
            : _glyphs[_random.nextInt(_glyphs.length)],
      );
    }
    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (BuildContext context, Widget? _) {
        return Text(
          _frame(_controller.value),
          style: widget.style,
          maxLines: widget.maxLines,
          overflow: TextOverflow.ellipsis,
          semanticsLabel: widget.text,
        );
      },
    );
  }
}
