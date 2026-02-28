import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/storage_keys.dart';
import '../helpers/security_helper.dart';
import '../models/password_entry.dart';
import 'password_list_screen.dart';

class MasterLoginScreen extends StatefulWidget {
  const MasterLoginScreen({super.key});

  @override
  State<MasterLoginScreen> createState() => _MasterLoginScreenState();
}

class _MasterLoginScreenState extends State<MasterLoginScreen> {
  final TextEditingController _masterPasswordController = TextEditingController();
  bool _isChecking = false;

  @override
  void dispose() {
    _masterPasswordController.dispose();
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

    final prefs = await SharedPreferences.getInstance();
    final verifierCipher = prefs.getString(kMasterVerifierKey);

    if (verifierCipher == null || verifierCipher.isEmpty) {
      final rawEntries = prefs.getString(kEntriesStorageKey);
      if (rawEntries != null && rawEntries.isNotEmpty) {
        try {
          final decoded = jsonDecode(rawEntries) as List<dynamic>;
          if (decoded.isNotEmpty) {
            final first = PasswordEntry.fromMap(decoded.first as Map<String, dynamic>);
            SecurityHelper.decryptData(first.encryptedPassword, masterPassword);
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

      final newVerifier = SecurityHelper.encryptData(kMasterVerifierValue, masterPassword);
      await prefs.setString(kMasterVerifierKey, newVerifier);
    } else {
      try {
        final verifierPlain = SecurityHelper.decryptData(verifierCipher, masterPassword);
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
      body: Center(
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
                    child: Text(_isChecking ? 'Kontrol ediliyor...' : 'Giriş Yap'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
