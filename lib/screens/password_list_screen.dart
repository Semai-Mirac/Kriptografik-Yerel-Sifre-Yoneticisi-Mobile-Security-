import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/storage_keys.dart';
import '../helpers/security_helper.dart';
import '../models/password_entry.dart';
import 'add_password_screen.dart';

class PasswordListScreen extends StatefulWidget {
  const PasswordListScreen({super.key, required this.masterPassword});

  final String masterPassword;

  @override
  State<PasswordListScreen> createState() => _PasswordListScreenState();
}

class _PasswordListScreenState extends State<PasswordListScreen> {
  final List<PasswordEntry> _entries = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  Future<void> _loadEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(kEntriesStorageKey);

    if (raw != null && raw.isNotEmpty) {
      final decoded = jsonDecode(raw) as List<dynamic>;
      _entries
        ..clear()
        ..addAll(
          decoded
              .map((item) => PasswordEntry.fromMap(item as Map<String, dynamic>))
              .toList(),
        );
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _persistEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(_entries.map((entry) => entry.toMap()).toList());
    await prefs.setString(kEntriesStorageKey, raw);
  }

  Future<void> _goToAddForm() async {
    final newEntry = await Navigator.of(context).push<PasswordEntry>(
      MaterialPageRoute(
        builder: (_) => AddPasswordScreen(masterPassword: widget.masterPassword),
      ),
    );

    if (newEntry != null) {
      setState(() {
        _entries.add(newEntry);
      });
      await _persistEntries();
    }
  }

  void _showRealPassword(PasswordEntry entry) {
    try {
      final realPassword = SecurityHelper.decryptData(
        entry.encryptedPassword,
        widget.masterPassword,
      );

      showDialog<void>(
        context: context,
        builder: (_) => AlertDialog(
          title: Text(entry.title),
          content: Text('Gerçek şifre: $realPassword'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Kapat'),
            ),
          ],
        ),
      );
    } on FormatException {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bu master şifre ile veri çözülemedi.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Şifreler')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _entries.isEmpty
              ? const Center(child: Text('Henüz kayıt yok.'))
              : ListView.builder(
                  itemCount: _entries.length,
                  itemBuilder: (context, index) {
                    final entry = _entries[index];
                    return ListTile(
                      title: Text(entry.title),
                      subtitle: const Text('******'),
                      trailing: IconButton(
                        icon: const Icon(Icons.visibility),
                        onPressed: () => _showRealPassword(entry),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _goToAddForm,
        child: const Icon(Icons.add),
      ),
    );
  }
}
