import 'package:flutter/material.dart';

import '../helpers/security_helper.dart';
import '../localization/app_localizations.dart';
import '../models/password_entry.dart';
import '../widgets/edge_swipe_back.dart';

class AddPasswordScreen extends StatefulWidget {
  const AddPasswordScreen({
    super.key,
    required this.masterPassword,
    this.initialEntry,
  });

  final String masterPassword;
  final PasswordEntry? initialEntry;

  @override
  State<AddPasswordScreen> createState() => _AddPasswordScreenState();
}

class _AddPasswordScreenState extends State<AddPasswordScreen> {
  static const List<String> _categoryKeys = [
    'social',
    'work',
    'personal',
    'other',
  ];

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  late String _selectedCategory;

  bool get _isEdit => widget.initialEntry != null;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialEntry;
    if (initial != null) {
      _titleController.text = initial.title;
      _usernameController.text = initial.username;
      _selectedCategory = _normalizeCategoryKey(initial.category);
    } else {
      _selectedCategory = _categoryKeys.first;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
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
        return _categoryKeys.first;
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

  void _save() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final current = widget.initialEntry;
    final shouldKeepPassword = _isEdit && _passwordController.text.isEmpty;

    final encryptedPassword = shouldKeepPassword
        ? current!.encryptedPassword
        : SecurityHelper.encryptData(
            _passwordController.text,
            widget.masterPassword,
          );

    final entry = PasswordEntry(
      id: current?.id,
      title: _titleController.text.trim(),
      username: _usernameController.text.trim(),
      category: _selectedCategory,
      encryptedPassword: encryptedPassword,
      createdAt: current?.createdAt ?? DateTime.now().millisecondsSinceEpoch,
    );

    Navigator.of(context).pop(entry);
  }

  InputDecoration _buildGlassInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.05),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1.0,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: Color(0xFF4FE3C1),
          width: 1.5,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: Colors.redAccent.withValues(alpha: 0.5),
          width: 1.0,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: Colors.redAccent,
          width: 1.5,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? loc.t('editRecord') : loc.t('addPassword')),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: EdgeSwipeBack(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    key: ValueKey(_selectedCategory),
                    dropdownColor: const Color(0xFF0A1424),
                    initialValue: _selectedCategory,
                    items: _categoryKeys
                        .map(
                          (category) => DropdownMenuItem<String>(
                            value: category,
                            child: Text(
                              _categoryLabel(category, loc),
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value == null) {
                        return;
                      }
                      setState(() {
                        _selectedCategory = value;
                      });
                    },
                    decoration: _buildGlassInputDecoration(loc.t('category')),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _titleController,
                    style: const TextStyle(color: Colors.white),
                    decoration: _buildGlassInputDecoration(loc.t('title')),
                    validator: (value) => (value == null || value.trim().isEmpty)
                        ? loc.t('titleRequired')
                        : null,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _usernameController,
                    style: const TextStyle(color: Colors.white),
                    decoration: _buildGlassInputDecoration(loc.t('usernameOrEmail')),
                    validator: (value) => (value == null || value.trim().isEmpty)
                        ? loc.t('usernameRequired')
                        : null,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _passwordController,
                    style: const TextStyle(color: Colors.white),
                    decoration: _buildGlassInputDecoration(
                      _isEdit ? loc.t('newPasswordOptional') : loc.t('password'),
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (_isEdit) {
                        return null;
                      }
                      return (value == null || value.isEmpty)
                          ? loc.t('passwordRequired')
                          : null;
                    },
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF4FE3C1).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFF4FE3C1).withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor: const Color(0xFF4FE3C1),
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: _save,
                        child: Text(
                          _isEdit ? loc.t('update') : loc.t('save'),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
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
    );
  }
}
