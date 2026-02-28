import 'package:flutter/material.dart';

import '../helpers/security_helper.dart';
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
  static const List<String> _categories = [
    'Sosyal Medya',
    'İş',
    'Kişisel',
    'Diğer',
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
      _selectedCategory = initial.category;
    } else {
      _selectedCategory = _categories[0];
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEdit ? 'Kaydı Düzenle' : 'Şifre Ekle')),
      body: EdgeSwipeBack(
        child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                items: _categories
                    .map(
                      (category) => DropdownMenuItem<String>(
                        value: category,
                        child: Text(category),
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
                decoration: const InputDecoration(
                  labelText: 'Kategori',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Başlık',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => (value == null || value.trim().isEmpty)
                    ? 'Başlık zorunlu'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'Kullanıcı adı',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => (value == null || value.trim().isEmpty)
                    ? 'Kullanıcı adı zorunlu'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: _isEdit
                      ? 'Yeni Şifre (boşsa değişmez)'
                      : 'Şifre',
                  border: const OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (value) {
                  if (_isEdit) {
                    return null;
                  }
                  return (value == null || value.isEmpty) ? 'Şifre zorunlu' : null;
                },
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _save,
                  child: Text(_isEdit ? 'Güncelle' : 'Kaydet'),
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

