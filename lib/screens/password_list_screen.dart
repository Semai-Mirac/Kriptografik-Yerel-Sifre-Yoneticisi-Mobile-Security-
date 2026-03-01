import 'package:flutter/material.dart';

import '../helpers/backup_helper.dart';
import '../helpers/database_helper.dart';
import '../helpers/security_helper.dart';
import '../localization/app_localizations.dart';
import '../models/password_entry.dart';
import '../widgets/edge_swipe_back.dart';
import 'add_password_screen.dart';
import 'master_login_screen.dart';

class PasswordListScreen extends StatefulWidget {
  const PasswordListScreen({super.key, required this.masterPassword});

  final String masterPassword;

  @override
  State<PasswordListScreen> createState() => _PasswordListScreenState();
}

class _PasswordListScreenState extends State<PasswordListScreen> {
  static const List<String> _categoryOrder = [
    'social',
    'work',
    'personal',
    'other',
  ];

  final List<PasswordEntry> _entries = [];
  bool _isLoading = true;
  bool _isBackingUp = false;
  bool _isRestoring = false;

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  String _normalizeCategoryKey(String category) {
    final value = category.trim().toLowerCase();
    switch (value) {
      case 'social':
      case 'sosyal medya':
        return 'social';
      case 'work':
      case 'iş':
      case 'is':
        return 'work';
      case 'personal':
      case 'kişisel':
      case 'kisisel':
        return 'personal';
      case 'other':
      case 'diğer':
      case 'diger':
        return 'other';
      default:
        return 'other';
    }
  }

  String _categoryLabel(String key, AppLocalizations loc) {
    switch (key) {
      case 'social':
        return loc.t('categorySocial');
      case 'work':
        return loc.t('categoryWork');
      case 'personal':
        return loc.t('categoryPersonal');
      default:
        return loc.t('categoryOther');
    }
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

  Future<void> _deleteEntry(PasswordEntry entry) async {
    final loc = AppLocalizations.of(context);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0A1424),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.1), width: 1),
        ),
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.orangeAccent),
            const SizedBox(width: 10),
            Text(loc.t('confirmDeleteTitle'), style: const TextStyle(color: Colors.white)),
          ],
        ),
        content: Text(
          '"${entry.title}" ${loc.t('confirmDeleteBody')}',
          style: TextStyle(color: Colors.white.withValues(alpha: 0.8)),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actionsPadding: const EdgeInsets.only(bottom: 16, top: 0, left: 16, right: 16),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white.withValues(alpha: 0.08),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(loc.t('cancel')),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.redAccent.withValues(alpha: 0.8),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text(loc.t('delete')),
                ),
              ),
            ],
          ),
        ],
      ),
    );

    if (confirm == true && entry.id != null) {
      await DatabaseHelper.instance.deleteEntry(entry.id!);
      _loadEntries();
    }
  }

  void _logout() {
    final loc = AppLocalizations.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0A1424),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: Colors.white.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        title: Row(
          children: [
            const Icon(Icons.info_outline, color: Color(0xFF4FE3C1)),
            const SizedBox(width: 10),
            Text(
              loc.t('logoutTitle'),
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
        content: Text(
          loc.t('logoutBody'),
          style: TextStyle(color: Colors.white.withValues(alpha: 0.8)),
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
                    child: Text(loc.t('cancelExit')),
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
                      Navigator.of(context).pop();
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => const MasterLoginScreen()),
                        (_) => false,
                      );
                    },
                    child: Text(loc.t('continueAction')),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

    Future<void> _restoreFromCloud() async {
    if (_isRestoring) return;

    final loc = AppLocalizations.of(context);

    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0A1424),
        title: Text(loc.t('confirmRestoreTitle')),
        content: Text(loc.t('confirmRestoreBody')),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(loc.t('cancel') ?? 'Vazgeç'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(loc.t('continueAction') ?? 'Devam Et'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() {
      _isRestoring = true;
    });

    try {
      await BackupHelper.downloadEncryptedBackup(masterPassword: widget.masterPassword);
      await _loadEntries();
      
      if (!mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      messenger.clearSnackBars();
      messenger.showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFF4FE3C1).withValues(alpha: 0.12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(color: const Color(0xFF4FE3C1).withValues(alpha: 0.6), width: 1),
          ),
          content: Row(
            children: [
              const Icon(Icons.check_circle_outline_rounded, color: Color(0xFF4FE3C1), size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  loc.t('restoreSuccess'),
                  style: const TextStyle(color: Color(0xFF4FE3C1), fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;
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
                  "${loc.t('restoreFailedPrefix')}: $error",
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
          _isRestoring = false;
        });
      }
    }
  }

Future<void> _backupToCloud() async {
    if (_isBackingUp) {
      return;
    }

    final loc = AppLocalizations.of(context);

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
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFF4FE3C1).withValues(alpha: 0.12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(color: const Color(0xFF4FE3C1).withValues(alpha: 0.6), width: 1),
          ),
          content: Row(
            children: [
              const Icon(Icons.check_circle_outline_rounded, color: Color(0xFF4FE3C1), size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  loc.t('backupSuccess'),
                  style: const TextStyle(color: Color(0xFF4FE3C1), fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ),
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
                  '${loc.t('backupFailedPrefix')}: $error',
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
    final loc = AppLocalizations.of(context);

    try {
      final realPassword = SecurityHelper.decryptData(
        entry.encryptedPassword,
        widget.masterPassword,
      );

      showDialog<void>(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: const Color(0xFF0A1424),
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
                '${loc.t('category')}: ${_categoryLabel(_normalizeCategoryKey(entry.category), loc)}',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.8)),
              ),
              const SizedBox(height: 8),
              Text(
                '${loc.t('username')}: ${entry.username}',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.8)),
              ),
              const SizedBox(height: 8),
              Text(
                '${loc.t('realPassword')}: $realPassword',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontWeight: FontWeight.bold,
                ),
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
                      child: Text(loc.t('close')),
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
          content: Row(
            children: [
              const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  loc.t('decryptFailed'),
                  style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  List<Widget> _buildSectionedList() {
    final loc = AppLocalizations.of(context);

    final grouped = <String, List<PasswordEntry>>{};
    for (final entry in _entries) {
      final categoryKey = _normalizeCategoryKey(entry.category);
      grouped.putIfAbsent(categoryKey, () => []).add(entry);
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
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10, spreadRadius: 1),
              ],
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.15),
                width: 1.0,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: Text(
                    _categoryLabel(category, loc),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Container(
                    height: 1,
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                ),
                const SizedBox(height: 8),
                ...entriesList.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.08),
                          width: 1.0,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        entry.title,
                                        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${entry.username} • ******',
                                        style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 13),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.visibility_outlined, color: Colors.white),
                                  onPressed: () => _showRealPassword(entry),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: SizedBox(
                                    height: 40,
                                    child: OutlinedButton.icon(
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: Colors.redAccent,
                                        side: BorderSide(color: const Color(0xFF4FE3C1).withValues(alpha: 0.15), width: 1.5),
                                        padding: EdgeInsets.zero,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      ),
                                      icon: const Icon(Icons.delete_outline_rounded, size: 16),
                                      label: Text(
                                        loc.t('delete'),
                                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                                      ),
                                      onPressed: () => _deleteEntry(entry),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: SizedBox(
                                    height: 40,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF4FE3C1).withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: FilledButton.icon(
                                        style: FilledButton.styleFrom(
                                          backgroundColor: Colors.transparent,
                                          foregroundColor: const Color(0xFF4FE3C1),
                                          elevation: 0,
                                          padding: EdgeInsets.zero,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                        ),
                                        icon: const Icon(Icons.edit_rounded, size: 16),
                                        label: Text(
                                          loc.t('update'),
                                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                                        ),
                                        onPressed: () => _goToEditForm(entry),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
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
    final loc = AppLocalizations.of(context);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          return;
        }
        _logout();
      },
      child: Scaffold(
        body: SafeArea(
          child: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) => [
              SliverPadding(
                padding: const EdgeInsets.all(12),
                sliver: SliverAppBar(
                  title: Text(loc.t('passwords')),
                  floating: true,
                  snap: true,
                  backgroundColor: const Color(0xFF0A1424),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  actions: [
                    IconButton(
                      onPressed: _isRestoring ? null : _restoreFromCloud,
                      icon: _isRestoring
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.cloud_download),
                      tooltip: loc.t('restoreFromDrive'),
                    ),
                    IconButton(
                      onPressed: _isBackingUp ? null : _backupToCloud,
                      icon: _isBackingUp
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.cloud_upload),
                      tooltip: loc.t('backupToDrive'),
                    ),
                    IconButton(
                      onPressed: _logout,
                      icon: const Icon(Icons.logout),
                      tooltip: loc.t('logout'),
                    ),
                  ],
                ),
              ),
            ],
            body: EdgeSwipeBack(
              onSwipeBack: () async {
                _logout();
              },
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _entries.isEmpty
                      ? Center(child: Text(loc.t('noRecordsYet')))
                      : ListView(
                          padding: const EdgeInsets.only(top: 0),
                          children: _buildSectionedList(),
                        ),
            ),
          ),
        ),
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 24.0),
          child: FloatingActionButton(
            backgroundColor: const Color(0xFF4FE3C1).withValues(alpha: 0.6),
            elevation: 0,
            onPressed: _goToAddForm,
            child: const Icon(Icons.add, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
