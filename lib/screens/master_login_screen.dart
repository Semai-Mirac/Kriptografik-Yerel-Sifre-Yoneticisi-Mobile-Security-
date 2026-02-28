import 'package:flutter/material.dart';

import '../constants/storage_keys.dart';
import '../helpers/database_helper.dart';
import '../helpers/security_helper.dart';
import '../widgets/borealis_animated_background.dart';
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
  late final Animation<double> _contentFade;
  late final Animation<Offset> _contentSlide;

  @override
  void initState() {
    super.initState();
    _contentController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
    );
    _contentFade = CurvedAnimation(
      parent: _contentController,
      curve: Curves.easeOutCubic,
    );
    _contentSlide = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _contentController, curve: Curves.easeOutCubic),
    );
    _contentController.forward();
  }

  @override
  void dispose() {
    _masterPasswordController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final masterPassword = _masterPasswordController.text.trim();
    if (masterPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Master şifre boş olamaz.')),
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
          SecurityHelper.decryptData(entries.first.encryptedPassword, masterPassword);
        } on FormatException {
          if (!mounted) {
            return;
          }
          setState(() {
            _isChecking = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Master şifre yanlış.')),
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
          throw const FormatException('Master doğrulaması başarısız');
        }
      } on FormatException {
        if (!mounted) {
          return;
        }
        setState(() {
          _isChecking = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Master şifre yanlış.')),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BorealisAnimatedBackground(
        initialProgress: widget.initialBackgroundProgress,
        anchorTime: widget.backgroundAnchor,
        child: Center(
          child: FadeTransition(
            opacity: _contentFade,
            child: SlideTransition(
              position: _contentSlide,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Master Login',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 24),
                      TextField(
                        controller: _masterPasswordController,
                        decoration: const InputDecoration(
                          labelText: 'Master Şifre',
                          border: OutlineInputBorder(),
                        ),
                        obscureText: true,
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: _isChecking ? null : _login,
                          child: Text(
                            _isChecking ? 'Kontrol ediliyor...' : 'Giriş Yap',
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
      ),
    );
  }
}
