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

  // Ortak şeffaf ve köşesi yuvarlak InputDecoration oluşturucu
  InputDecoration _buildGlassInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.05), // Içi hafif transparan cama benzesin
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: Colors.white.withValues(alpha: 0.2), // Saydam beyaz çizgi
          width: 1.0,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: Color(0xFF4FE3C1), // Temanın ana rengi focus olunca yanar
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
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Kaydı Düzenle' : 'Şifre Ekle'),
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
                    dropdownColor: const Color(0xFF0A1424), // Açılan kutunun rengi karanlık neon
                    value: _selectedCategory,
                    items: _categories
                        .map(
                          (category) => DropdownMenuItem<String>(
                            value: category,
                            child: Text(category, style: const TextStyle(color: Colors.white)),
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
                    decoration: _buildGlassInputDecoration('Kategori'),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _titleController,
                    style: const TextStyle(color: Colors.white),
                    decoration: _buildGlassInputDecoration('Başlık'),
                    validator: (value) => (value == null || value.trim().isEmpty)
                        ? 'Başlık zorunlu'
                        : null,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _usernameController,
                    style: const TextStyle(color: Colors.white),
                    decoration: _buildGlassInputDecoration('Kullanıcı adı veya E-posta'),
                    validator: (value) => (value == null || value.trim().isEmpty)
                        ? 'Kullanıcı adı zorunlu'
                        : null,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _passwordController,
                    style: const TextStyle(color: Colors.white),
                    decoration: _buildGlassInputDecoration(_isEdit ? 'Yeni Şifre (boşsa değişmez)' : 'Şifre'),
                    obscureText: true,
                    validator: (value) {
                      if (_isEdit) {
                        return null;
                      }
                      return (value == null || value.isEmpty) ? 'Şifre zorunlu' : null;
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
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        onPressed: _save,
                        child: Text(
                          _isEdit ? 'Güncelle' : 'Kaydet',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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


