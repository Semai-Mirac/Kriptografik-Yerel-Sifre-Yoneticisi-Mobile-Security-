import 'dart:math' as math;

import 'package:flutter/material.dart';

class BorealisAnimatedBackground extends StatefulWidget {
  const BorealisAnimatedBackground({
    super.key,
    this.initialProgress = 0,
    this.duration = const Duration(seconds: 14),
    this.anchorTime,
    this.child,
  });

  final double initialProgress;
  final Duration duration;
  final DateTime? anchorTime;
  final Widget? child;

  @override
  State<BorealisAnimatedBackground> createState() =>
      _BorealisAnimatedBackgroundState();
}

class _BorealisAnimatedBackgroundState extends State<BorealisAnimatedBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    final clampedInitial = widget.initialProgress.clamp(0.0, 1.0);
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
      value: clampedInitial,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double _progressFromAnchor() {
    final anchor = widget.anchorTime;
    if (anchor == null) {
      return _controller.value;
    }

    final totalMs = widget.duration.inMilliseconds;
    if (totalMs <= 0) {
      return 0;
    }

    final elapsedMs = DateTime.now().difference(anchor).inMilliseconds;
    final loopMs = elapsedMs % totalMs;
    return loopMs / totalMs;
  }

  Color _tone(double phase, double hueShift) {
    final wave = (math.sin((phase + hueShift) * 2 * math.pi) + 1) * 0.5;
    final hue = 190 + (90 * wave);
    final saturation = 0.55 + (0.2 * wave);
    final lightness = 0.08 + (0.14 * wave);
    return HSLColor.fromAHSL(1, hue, saturation, lightness).toColor();
  }

  List<Color> _gradientColors(double phase) {
    final c1 = Color.lerp(const Color(0xFF02040A), _tone(phase, 0.00), 0.90)!;
    final c2 = Color.lerp(const Color(0xFF040912), _tone(phase, 0.33), 0.92)!;
    final c3 = Color.lerp(const Color(0xFF070B18), _tone(phase, 0.66), 0.94)!;
    return [c1, c2, c3];
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final phase = _progressFromAnchor();
        final drift = math.sin(phase * 2 * math.pi) * 0.15;

        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment(-1 + drift, -1),
              end: Alignment(1 - drift, 1),
              stops: const [0.0, 0.5, 1.0],
              colors: _gradientColors(phase),
            ),
          ),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}
