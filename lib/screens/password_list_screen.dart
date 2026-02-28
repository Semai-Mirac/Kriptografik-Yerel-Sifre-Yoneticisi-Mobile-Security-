import 'package:flutter/material.dart';

import '../helpers/backup_helper.dart';
import '../helpers/database_helper.dart';
import '../helpers/security_helper.dart';
import '../models/password_entry.dart';
import 'add_password_screen.dart';
import 'master_login_screen.dart';
import '../widgets/edge_swipe_back.dart';

class PasswordListScreen extends StatefulWidget {
  const PasswordListScreen({super.key, required this.masterPassword});

  final String masterPassword;

  @override
  State<PasswordListScreen> createState() => _PasswordListScreenState();
}

class _PasswordListScreenState extends State<PasswordListScreen> {
  static const List<String> _categoryOrder = [
    'Sosyal Medya',
    'İş',
    'Kişisel',
    'Diğer',
  ];

  final List<PasswordEntry> _entries = [];
  bool _isLoading = true;
  bool _isBackingUp = false;

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  Future<void> _loadEntries() async {
    final items = await DatabaseHelper.instance.getEntries();

    if (!mounted) {
      return;
    }

    setState(() {
      _entries
        ..clear()
        ..addAll(items);
      _isLoading = false;
    });
  }

  void _logout() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const MasterLoginScreen()),
      (_) => false,
    );
  }

  Future<void> _backupToCloud() async {
    if (_isBackingUp) {
      return;
    }

    setState(() {
      _isBackingUp = true;
    });

    try {
      await BackupHelper.uploadEncryptedBackup(
        masterPassword: widget.masterPassword,
      );
      if (!mounted) {
        return;
      }
      final messenger = ScaffoldMessenger.of(context);
      messenger.clearSnackBars();
      messenger.showSnackBar(
        const SnackBar(content: Text('Yedek Google Drive hesabına yüklendi.')),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Yedekleme başarısız: $error')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isBackingUp = false;
        });
      }
    }
  }

  Future<void> _goToAddForm() async {
    final newEntry = await Navigator.of(context).push<PasswordEntry>(
      MaterialPageRoute(
        builder: (_) => AddPasswordScreen(masterPassword: widget.masterPassword),
      ),
    );

    if (newEntry != null) {
      await DatabaseHelper.instance.insertEntry(newEntry);
      await _loadEntries();
    }
  }

  Future<void> _goToEditForm(PasswordEntry entry) async {
    final updated = await Navigator.of(context).push<PasswordEntry>(
      MaterialPageRoute(
        builder: (_) => AddPasswordScreen(
          masterPassword: widget.masterPassword,
          initialEntry: entry,
        ),
      ),
    );

    if (updated != null) {
      await DatabaseHelper.instance.updateEntry(updated);
      await _loadEntries();
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
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Kategori: ${entry.category}'),
              const SizedBox(height: 8),
              Text('Kullanıcı adı: ${entry.username}'),
              const SizedBox(height: 8),
              Text('Gerçek şifre: $realPassword'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Kapat'),
            ),
          ],
        ),
      );
    } on FormatException {
      final messenger = ScaffoldMessenger.of(context);
      messenger.clearSnackBars();
      messenger.showSnackBar(
        const SnackBar(content: Text('Data could not be decrypted with this master password.')),
      );
    }
  }

  List<Widget> _buildSectionedList() {
    final grouped = <String, List<PasswordEntry>>{};
    for (final entry in _entries) {
      grouped.putIfAbsent(entry.category, () => []).add(entry);
    }

    final unknownCategories = grouped.keys
        .where((category) => !_categoryOrder.contains(category))
        .toList()
      ..sort();

    final orderedCategories = <String>[..._categoryOrder, ...unknownCategories]
        .where((category) => grouped[category]?.isNotEmpty == true)
        .toList();

    final widgets = <Widget>[];

    for (final category in orderedCategories) {
      widgets.add(
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            category,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
      );

      for (final entry in grouped[category]!) {
        widgets.add(
          ListTile(
            title: Text(entry.title),
            subtitle: Text('${entry.username} • ******'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.visibility),
                  onPressed: () => _showRealPassword(entry),
                ),
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _goToEditForm(entry),
                ),
              ],
            ),
          ),
        );
      }
    }

    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Şifreler'),
        actions: [
          IconButton(
            onPressed: _isBackingUp ? null : _backupToCloud,
            icon: _isBackingUp
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.cloud_upload),
            tooltip: 'Google Drive yedekle',
          ),
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout),
            tooltip: 'Çıkış Yap',
          ),
        ],
      ),
      body: EdgeSwipeBack(
        onSwipeBack: () async {
          _logout();
        },
        child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _entries.isEmpty
              ? const Center(child: Text('Henüz kayıt yok.'))
              : ListView(children: _buildSectionedList()),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _goToAddForm,
        child: const Icon(Icons.add),
      ),
    );
  }
}







