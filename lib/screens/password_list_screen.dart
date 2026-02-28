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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0A1424), // borealisSurface color
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: Colors.white.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        title: const Row(
          children: [
            Icon(Icons.info_outline, color: Color(0xFF4FE3C1)), // borealisPrimary color
            SizedBox(width: 10),
            Text(
              'Çıkış Yapılıyor',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
        content: Text(
          'Çıkış yapmak üzeresiniz, emin misiniz?',
          style: TextStyle(color: Colors.white.withValues(alpha: 0.8)),
        ),
        actionsAlignment: MainAxisAlignment.center, // Butonları ortaya hizala
        actionsPadding: const EdgeInsets.only(bottom: 16, top: 0, left: 16, right: 16),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(14),
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
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () => Navigator.of(context).pop(), // Uyarıyı kapatır (Vazgeç)
                    child: const Text('Vazgeçtim'),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(14),
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
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop(); // Uyarıyı kapat
                      // Giriş ekranına yönlendir ve geçmişi temizle
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => const MasterLoginScreen()),
                        (_) => false,
                      );
                    },
                    child: const Text('Devam Et'),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
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
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red.withValues(alpha: 0.12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(color: Colors.red.withValues(alpha: 0.6), width: 1),
          ),
          content: Row(
            children: [
              const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Yedekleme başarısız: $error',
                  style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ),
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
          backgroundColor: const Color(0xFF0A1424), // borealisSurface color
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: Colors.white.withValues(alpha: 0.1),
              width: 1,
            ),
          ),
          title: Row(
            children: [
              const Icon(Icons.key, color: Color(0xFF4FE3C1)),
              const SizedBox(width: 10),
              Text(
                entry.title,
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Kategori: ${entry.category}',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.8)),
              ),
              const SizedBox(height: 8),
              Text(
                'Kullanıcı adı: ${entry.username}',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.8)),
              ),
              const SizedBox(height: 8),
              Text(
                'Gerçek şifre: $realPassword',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontWeight: FontWeight.bold),
              ),
            ],
          ),
          actionsAlignment: MainAxisAlignment.center,
          actionsPadding: const EdgeInsets.only(bottom: 16, top: 0, left: 16, right: 16),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(14),
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
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Kapat'),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    } on FormatException {
      final messenger = ScaffoldMessenger.of(context);
      messenger.clearSnackBars();
      messenger.showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red.withValues(alpha: 0.12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(color: Colors.red.withValues(alpha: 0.6), width: 1),
          ),
          content: const Row(
            children: [
              Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 18),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Data could not be decrypted with this master password.',
                  style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ),
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
      final entriesList = grouped[category]!;
      
      widgets.add(
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(2),
              border: Border.all(
                color: Colors.white,
                width: 1.5,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Kategori Başlığı
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: Text(
                    category,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                // Liste çizgisini ayıran ince çizgi (Düşündüğünüz tasarımdaki üst ayrım için)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Container(
                    height: 1,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                // İçerikteki şifre kutuları ve kartları
                ...entriesList.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(2), // Dik köşelere daha yakın
                        border: Border.all(
                          color: Colors.white,
                          width: 1.5,
                        ),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                        title: Text(
                          entry.title,
                          style: const TextStyle(color: Colors.white, fontSize: 15),
                        ),
                        subtitle: Text(
                          '${entry.username} • ******',
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 13),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.visibility, color: Colors.white),
                              onPressed: () => _showRealPassword(entry),
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.white),
                              onPressed: () => _goToEditForm(entry),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      );
    }

    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          return;
        }
        _logout();
      },
      child: Scaffold(
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
      ),
    );
  }
}



