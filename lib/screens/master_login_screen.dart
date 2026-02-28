import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../constants/storage_keys.dart';
import '../helpers/database_helper.dart';
import '../helpers/security_helper.dart';
import '../widgets/borealis_animated_background.dart';
import '../widgets/edge_swipe_back.dart';
import 'password_list_screen.dart';

class MasterLoginScreen extends StatefulWidget {
  const MasterLoginScreen({
    super.key,
    this.initialBackgroundProgress = 0,
    this.backgroundAnchor,
  });

  final double initialBackgroundProgress;
  final DateTime? backgroundAnchor;

  @override
  State<MasterLoginScreen> createState() => _MasterLoginScreenState();
}

class _MasterLoginScreenState extends State<MasterLoginScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _masterPasswordController = TextEditingController();
  bool _isChecking = false;
  late final AnimationController _contentController;

  @override
  void initState() {
    super.initState();
    _contentController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2300),
    );
    _contentController.forward();
  }

  @override
  void dispose() {
    _masterPasswordController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _showStyledSnackBar({
    required IconData icon,
    required String message,
  }) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        elevation: 0,
        backgroundColor: Colors.white.withValues(alpha: 0.08),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(
            color: Colors.white.withValues(alpha: 0.42),
            width: 1,
          ),
        ),
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _login() async {
    final masterPassword = _masterPasswordController.text.trim();
    if (masterPassword.isEmpty) {
      _showStyledSnackBar(
        icon: Icons.warning_amber_rounded,
        message: 'Password cannot be empty.',
      );
      return;
    }

    setState(() {
      _isChecking = true;
    });

    final verifierCipher = await DatabaseHelper.instance.getSetting(
      kMasterVerifierKey,
    );

    if (verifierCipher == null || verifierCipher.isEmpty) {
      final entries = await DatabaseHelper.instance.getEntries();
      if (entries.isNotEmpty) {
        try {
          SecurityHelper.decryptData(
            entries.first.encryptedPassword,
            masterPassword,
          );
        } on FormatException {
          if (!mounted) {
            return;
          }
          setState(() {
            _isChecking = false;
          });
          _showStyledSnackBar(
            icon: Icons.error_outline_rounded,
            message: 'Incorrect master password.',
          );
          return;
        }
      }

      final newVerifier = SecurityHelper.encryptData(
        kMasterVerifierValue,
        masterPassword,
      );
      await DatabaseHelper.instance.setSetting(kMasterVerifierKey, newVerifier);
    } else {
      try {
        final verifierPlain = SecurityHelper.decryptData(
          verifierCipher,
          masterPassword,
        );
        if (verifierPlain != kMasterVerifierValue) {
          throw const FormatException('Master verification failed');
        }
      } on FormatException {
        if (!mounted) {
          return;
        }
        setState(() {
          _isChecking = false;
        });
        _showStyledSnackBar(
          icon: Icons.error_outline_rounded,
          message: 'Incorrect master password.',
        );
        return;
      }
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _isChecking = false;
    });

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => PasswordListScreen(masterPassword: masterPassword),
      ),
    );
  }

  Widget _buildStaggeredItem({
    required int order,
    required Widget child,
  }) {
    final start = (0.18 + (order * 0.20)).clamp(0.0, 0.9);
    final end = (start + 0.46).clamp(0.0, 1.0);

    final fade = CurvedAnimation(
      parent: _contentController,
      curve: Interval(start, end, curve: Curves.easeInOutCubic),
    );

    final slide = Tween<Offset>(
      begin: const Offset(0, 0.14),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _contentController,
        curve: Interval(start, end, curve: Curves.easeInOutCubic),
      ),
    );

    return FadeTransition(
      opacity: fade,
      child: SlideTransition(
        position: slide,
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: EdgeSwipeBack(
        onSwipeBack: () async {
          await SystemNavigator.pop();
        },
        child: BorealisAnimatedBackground(
          initialProgress: widget.initialBackgroundProgress,
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildStaggeredItem(
                      order: 0,
                      child: TextField(
                        controller: _masterPasswordController,
                        decoration: const InputDecoration(
                          labelText: 'Password',
                          prefixIcon: Icon(Icons.lock_outline_rounded),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(14)),
                          ),
                        ),
                        obscureText: true,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildStaggeredItem(
                      order: 1,
                      child: Align(
                        alignment: Alignment.center,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.42),
                              width: 1,
                            ),
                          ),
                          child: FilledButton.icon(
                            style: FilledButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shadowColor: Colors.transparent,
                              side: BorderSide.none,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            onPressed: _isChecking ? null : _login,
                            icon: Icon(
                              _isChecking
                                  ? Icons.hourglass_top_rounded
                                  : Icons.login_rounded,
                              size: 18,
                            ),
                            label: Text(
                              _isChecking ? 'Checking...' : 'Sign In',
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
