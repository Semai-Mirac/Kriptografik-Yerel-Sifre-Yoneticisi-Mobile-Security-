import 'package:flutter/material.dart';

import '../widgets/borealis_animated_background.dart';
import 'master_login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  static const Duration _backgroundDuration = Duration(seconds: 9);

  late final DateTime _backgroundAnchor;
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _backgroundAnchor = DateTime.now();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 7),
    );

    _goNext();
  }

  double _currentBackgroundProgress() {
    final totalMs = _backgroundDuration.inMilliseconds;
    if (totalMs <= 0) {
      return 0;
    }

    final elapsedMs = DateTime.now().difference(_backgroundAnchor).inMilliseconds;
    final loopMs = elapsedMs % totalMs;
    return (loopMs / totalMs).clamp(0.0, 1.0);
  }

  Future<void> _goNext() async {
    await _controller.forward();
    if (!mounted) {
      return;
    }

    final backgroundProgress = _currentBackgroundProgress();

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
        pageBuilder: (_, __, ___) => MasterLoginScreen(
          initialBackgroundProgress: backgroundProgress,
        ),
      ),
    );
  }

  double _intervalProgress(double t, double begin, double end) {
    if (end <= begin) {
      return 0;
    }
    return ((t - begin) / (end - begin)).clamp(0.0, 1.0);
  }

  double _fadeWindow({
    required double t,
    required double fadeInBegin,
    required double fadeInEnd,
    required double fadeOutBegin,
    required double fadeOutEnd,
  }) {
    final fadeIn = Curves.easeInOutCubic.transform(
      _intervalProgress(t, fadeInBegin, fadeInEnd),
    );
    final fadeOut = Curves.easeInOutCubic.transform(
      _intervalProgress(t, fadeOutBegin, fadeOutEnd),
    );
    return (fadeIn * (1 - fadeOut)).clamp(0.0, 1.0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BorealisAnimatedBackground(
        anchorTime: _backgroundAnchor,
        duration: _backgroundDuration,
        child: Center(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              final t = _controller.value;

              final merhabaOpacity = _fadeWindow(
                t: t,
                fadeInBegin: 0.10,
                fadeInEnd: 0.38,
                fadeOutBegin: 0.46,
                fadeOutEnd: 0.74,
              );

              final hosGeldinizOpacity = _fadeWindow(
                t: t,
                fadeInBegin: 0.52,
                fadeInEnd: 0.86,
                fadeOutBegin: 0.90,
                fadeOutEnd: 1.00,
              );

              final merhabaScale = 0.98 + (0.02 * merhabaOpacity);
              final hosGeldinizScale = 0.98 + (0.02 * hosGeldinizOpacity);

              const textStyle = TextStyle(
                fontSize: 64,
                height: 1.0,
                color: Colors.white,
                fontWeight: FontWeight.w300,
                letterSpacing: 0.0,
                fontFamilyFallback: [
                  '.SF Pro Display',
                  'SF Pro Display',
                  'SF Pro Text',
                  'Roboto',
                  'Arial',
                ],
              );

              return Stack(
                alignment: Alignment.center,
                children: [
                  Transform.scale(
                    scale: merhabaScale,
                    child: Opacity(
                      opacity: merhabaOpacity,
                      child: const Text(
                        'Merhaba',
                        textAlign: TextAlign.center,
                        style: textStyle,
                      ),
                    ),
                  ),
                  Transform.scale(
                    scale: hosGeldinizScale,
                    child: Opacity(
                      opacity: hosGeldinizOpacity,
                      child: const Text(
                        'Hoş Geldiniz',
                        textAlign: TextAlign.center,
                        style: textStyle,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}



