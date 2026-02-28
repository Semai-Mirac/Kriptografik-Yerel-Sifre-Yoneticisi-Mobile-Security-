import 'dart:math' as math;

import 'package:flutter/material.dart';

class BorealisAnimatedBackground extends StatefulWidget {
  const BorealisAnimatedBackground({
    super.key,
    this.initialProgress = 0,
    this.duration = const Duration(seconds: 9),
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

    final startValue = _resolveInitialProgress();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
      value: startValue,
    )..repeat();
  }

  double _resolveInitialProgress() {
    final anchor = widget.anchorTime;
    if (anchor == null) {
      return widget.initialProgress.clamp(0.0, 1.0);
    }

    final totalMs = widget.duration.inMilliseconds;
    if (totalMs <= 0) {
      return 0;
    }

    final elapsedMs = DateTime.now().difference(anchor).inMilliseconds;
    final loopMs = elapsedMs % totalMs;
    return (loopMs / totalMs).clamp(0.0, 1.0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _tone(double phase, double hueShift) {
    final wave = (math.sin((phase + hueShift) * 2 * math.pi) + 1) * 0.5;
    final hue = 185 + (105 * wave);
    final saturation = 0.62 + (0.28 * wave);
    final lightness = 0.07 + (0.20 * wave);
    return HSLColor.fromAHSL(1, hue, saturation, lightness).toColor();
  }

  List<Color> _gradientColors(double phase) {
    final c1 = Color.lerp(const Color(0xFF010208), _tone(phase, 0.00), 0.94)!;
    final c2 = Color.lerp(const Color(0xFF03060F), _tone(phase, 0.34), 0.96)!;
    final c3 = Color.lerp(const Color(0xFF050914), _tone(phase, 0.68), 0.96)!;
    return [c1, c2, c3];
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final phase = _controller.value;
        final angle = phase * 2 * math.pi;
        final driftX = math.sin(angle) * 0.30;
        final driftY = math.cos(angle * 0.85) * 0.20;

        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment(-1 + driftX, -1 + driftY),
              end: Alignment(1 - driftX, 1 - driftY),
              stops: const [0.0, 0.48, 1.0],
              colors: _gradientColors(phase),
            ),
          ),
          child: RepaintBoundary(child: child),
        );
      },
      child: widget.child,
    );
  }
}
