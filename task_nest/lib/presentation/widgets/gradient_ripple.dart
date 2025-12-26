import 'package:flutter/material.dart';

class GradientRipple extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final Color color;

  const GradientRipple({
    required this.child,
    required this.color,
    this.onTap,
    super.key,
  });

  @override
  State<GradientRipple> createState() => _GradientRippleState();
}

class _GradientRippleState extends State<GradientRipple>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  Offset? _tapPosition;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 250),
        )..addStatusListener((status) {
          if (status == AnimationStatus.completed) {
            setState(() => _tapPosition = null);
          }
        });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown() {
    widget.onTap?.call();
    _startRipple();
  }

  void _startRipple() {
    final renderBox = context.findRenderObject() as RenderBox;
    _tapPosition = renderBox.size.center(Offset.zero);
    _controller.forward(from: 0);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _onTapDown(),
      child: CustomPaint(
        painter: _tapPosition == null
            ? null
            : _RipplePainter(_tapPosition!, widget.color, _controller),
        child: widget.child,
      ),
    );
  }
}

class _RipplePainter extends CustomPainter {
  final Offset position;
  final Color color;
  final Animation<double> animation;

  _RipplePainter(this.position, this.color, this.animation)
    : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final radius = 60 * animation.value;
    final gradient = RadialGradient(
      colors: [color.withAlpha(80), color.withAlpha(0)],
    );
    final paint = Paint()
      ..shader = gradient.createShader(
        Rect.fromCircle(center: position, radius: radius),
      );
    canvas.drawCircle(position, radius, paint);
  }

  @override
  bool shouldRepaint(_RipplePainter oldDelegate) =>
      oldDelegate.position != position || oldDelegate.animation != animation;
}
