import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:local_auth/local_auth.dart';
import '../app.dart';
import '../localization/app_localizations.dart';
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
  final LocalAuthentication _localAuth = LocalAuthentication();
  final TextEditingController _masterPasswordController = TextEditingController();
  bool _isChecking = false;
  bool _isLanguagePanelOpen = false;
  int _selectedLanguageIndex = 0;
  String _selectedLanguageCode = 'tr';
  late final AnimationController _contentController;
  OverlayEntry? _topMessageEntry;
  Timer? _topMessageTimer;

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
    _topMessageTimer?.cancel();
    _topMessageEntry?.remove();
    _masterPasswordController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _showStyledSnackBar({
    required IconData icon,
    required String message,
    bool showAtTop = false,
  }) {
    if (!showAtTop) {
      final messenger = ScaffoldMessenger.of(context);
      messenger.clearSnackBars();
      messenger.showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          elevation: 0,
          backgroundColor: Colors.red.withValues(alpha: 0.12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(
              color: Colors.red.withValues(alpha: 0.6),
              width: 1,
            ),
          ),
          content: Row(
            children: [
              Icon(icon, color: Colors.redAccent, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: Colors.redAccent,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
      return;
    }

    _topMessageTimer?.cancel();
    _topMessageEntry?.remove();

    final overlay = Overlay.of(context);
    final topInset = MediaQuery.of(context).padding.top + 12;

    final entry = OverlayEntry(
      builder: (_) => Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                _topMessageTimer?.cancel();
                _topMessageEntry?.remove();
                _topMessageEntry = null;
              },
              child: const SizedBox.expand(),
            ),
          ),
          Positioned(
            top: topInset,
            left: 16,
            right: 16,
            child: Material(
              color: Colors.transparent,
              child: GestureDetector(
                onTap: () {
                  _topMessageTimer?.cancel();
                  _topMessageEntry?.remove();
                  _topMessageEntry = null;
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: Colors.red.withValues(alpha: 0.6),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(icon, color: Colors.redAccent, size: 18),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          message,
                          style: const TextStyle(
                            color: Colors.redAccent,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );

    overlay.insert(entry);
    _topMessageEntry = entry;

    _topMessageTimer = Timer(const Duration(seconds: 3), () {
      _topMessageEntry?.remove();
      _topMessageEntry = null;
    });
  }

  Future<void> _login() async {
    final masterPassword = _masterPasswordController.text.trim();
    final loc = AppLocalizations.of(context);

    if (masterPassword.isEmpty) {
      _showStyledSnackBar(
        icon: Icons.warning_amber_rounded,
        message: loc.t('passwordEmpty'),
        showAtTop: true,
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
            message: loc.t('incorrectMasterPassword'),
            showAtTop: true,
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
          message: loc.t('incorrectMasterPassword'),
          showAtTop: true,
        );
        return;
      }
    }

    if (!mounted) {
      return;
    }

    // --- Biyometrik Doğrulama ---
    bool authenticated = false;
    try {
      final bool canAuthenticateWithBiometrics = await _localAuth.canCheckBiometrics;
      final bool canAuthenticate = canAuthenticateWithBiometrics || await _localAuth.isDeviceSupported();

      if (canAuthenticate) {
        authenticated = await _localAuth.authenticate(
          localizedReason: loc.t('biometricPrompt'),
          biometricOnly: true,
          persistAcrossBackgrounding: true,
        );
      } else {
        // Cihaz biyometriği desteklemiyorsa şifre doğru olduğu için devam et
        authenticated = true;
      }
    } catch (e) {
      debugPrint('Biyometrik doğrulama hatası: $e');
      authenticated = false;
    }

    if (!mounted) return;

    if (!authenticated) {
      setState(() {
        _isChecking = false;
      });
      _showStyledSnackBar(
        icon: Icons.fingerprint_rounded,
        message: loc.t('biometricFailed'),
        showAtTop: true,
      );
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

  Widget _buildLanguageSelector() {
    const globeAccents = <Color>[
      Color(0xFF4FE3C1),
      Color(0xFF8B7CFF),
      Color(0xFF63B4FF),
      Color(0xFFFFA94F),
    ];
    final loc = AppLocalizations.of(context);

    final languageOptions = <Map<String, String>>[
      {
        'code': 'tr',
        'label': loc.t('langTurkish'),
        'asset': 'assets/images/turk.png',
      },
      {
        'code': 'en',
        'label': loc.t('langEnglish'),
        'asset': 'assets/images/ingiliz.png',
      },
      {
        'code': 'it',
        'label': loc.t('langItalian'),
        'asset': 'assets/images/italyan.png',
      },
      {
        'code': 'ko',
        'label': loc.t('langKorean'),
        'asset': 'assets/images/kore.png',
      },
    ];

    return Align(
      alignment: Alignment.bottomCenter,
      child: SafeArea(
        minimum: const EdgeInsets.only(bottom: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              switchInCurve: Curves.easeOutQuad,
              switchOutCurve: Curves.easeInQuad,
              layoutBuilder: (currentChild, previousChildren) {
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    ...previousChildren,
                    if (currentChild != null) currentChild,
                  ],
                );
              },
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SizeTransition(
                    axisAlignment: 0,
                    sizeFactor: animation,
                    child: child,
                  ),
                );
              },
              child: !_isLanguagePanelOpen
                  ? const SizedBox.shrink()
                  : Align(
                      alignment: Alignment.center,
                      child: Container(
                      key: const ValueKey('language-panel'),
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.45),
                          width: 1,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(22),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: List.generate(languageOptions.length, (index) {
                              final selected = _selectedLanguageIndex == index;
                              final imagePadding = (index == 1 || index == 2) ? 1.4 : 2.0;
                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 4),
                                child: Tooltip(
                                  message: languageOptions[index]['label']!,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(20),
                                    onTap: () {
                                      setState(() {
                                        _selectedLanguageIndex = index;
                                        _selectedLanguageCode = languageOptions[index]['code']!;
                                        _isLanguagePanelOpen = false;
                                      });
                                      MyApp.setLocale(context, _selectedLanguageCode);
                                    },
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 200),
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: globeAccents[index].withValues(
                                          alpha: selected ? 0.34 : 0.20,
                                        ),
                                        border: Border.all(
                                          color: selected
                                              ? globeAccents[index].withValues(alpha: 0.95)
                                              : Colors.white.withValues(alpha: 0.45),
                                          width: selected ? 1.6 : 1,
                                        ),
                                      ),
                                      child: Padding(
                                        padding: EdgeInsets.all(imagePadding),
                                        child: ClipOval(
                                          child: Image.asset(
                                            languageOptions[index]['asset']!,
                                            fit: BoxFit.cover,
                                            width: double.infinity,
                                            height: double.infinity,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),
                      ),
                    ),
                    ),
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(32),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.42),
                  width: 1,
                ),
              ),
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shadowColor: Colors.transparent,
                  side: BorderSide.none,
                  minimumSize: const Size(56, 56),
                  shape: const CircleBorder(),
                ),
                onPressed: () {
                  setState(() {
                    _isLanguagePanelOpen = !_isLanguagePanelOpen;
                  });
                },
                child: Icon(
                  Icons.public_rounded,
                  size: 24,
                  semanticLabel: '${loc.t('selectedLanguage')}: $_selectedLanguageCode',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Scaffold(
      body: EdgeSwipeBack(
        onSwipeBack: () async {
          await SystemNavigator.pop();
        },
        child: BorealisAnimatedBackground(
          initialProgress: widget.initialBackgroundProgress,
          child: Stack(
            children: [
              Center(
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
                            decoration: InputDecoration(
                              labelText: loc.t('password'),
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
                                  _isChecking ? loc.t('checking') : loc.t('signIn'),
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
              _buildStaggeredItem(
                order: 1,
                child: _buildLanguageSelector(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

