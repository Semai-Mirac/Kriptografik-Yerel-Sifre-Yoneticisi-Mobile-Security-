import 'dart:async';

import 'package:flutter/material.dart';

import '../widgets/borealis_animated_background.dart';
import 'master_login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late final DateTime _backgroundAnchor;

  @override
  void initState() {
    super.initState();
    _backgroundAnchor = DateTime.now();
    _goNext();
  }

  Future<void> _goNext() async {
    await Future<void>.delayed(const Duration(seconds: 7));
    if (!mounted) {
      return;
    }

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
        pageBuilder: (_, __, ___) => MasterLoginScreen(
          backgroundAnchor: _backgroundAnchor,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BorealisAnimatedBackground(
        anchorTime: _backgroundAnchor,
      ),
    );
  }
}
