import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileWidget extends StatefulWidget {
  final User user;
  final Function() onSignOut;

  const ProfileWidget({Key? key, required this.user, required this.onSignOut})
      : super(key: key);

  @override
  State<ProfileWidget> createState() => _ProfileWidgetState();
}

class _ProfileWidgetState extends State<ProfileWidget> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _firstNameController.text = widget.user.displayName?.split(' ')[0] ?? '';
    _lastNameController.text = widget.user.displayName?.split(' ')[1] ?? '';
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      try {
        await widget.user.updateDisplayName(
            '${_firstNameController.text} ${_lastNameController.text}');
        setState(() {
          _errorMessage = null;
        });
        // Возможно, потребуется дополнительная логика для сохранения данных в Firestore
      } catch (e) {
        setState(() {
          _errorMessage = 'Ошибка при обновлении профиля';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Фото профиля
              CircleAvatar(
                radius: 60,
                backgroundImage: widget.user.photoURL != null
                    ? NetworkImage(widget.user.photoURL!)
                    : null,
                child: widget.user.photoURL == null
                    ? const Icon(Icons.person, size: 60)
                    : null,
              ),
              const SizedBox(height: 24),

              // Имя
              TextFormField(
                controller: _firstNameController,
                decoration: const InputDecoration(labelText: 'Имя'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Пожалуйста, введите имя';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Фамилия
              TextFormField(
                controller: _lastNameController,
                decoration: const InputDecoration(labelText: 'Фамилия'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Пожалуйста, введите фамилию';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Сообщение об ошибке
              if (_errorMessage != null)
                Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              const SizedBox(height: 24),

              // Кнопка "Обновить профиль"
              ElevatedButton(
                onPressed: _updateProfile,
                child: const Text('Обновить профиль'),
              ),
              const SizedBox(height: 24),

              // Кнопка "Выйти"
              ElevatedButton(
                onPressed: widget.onSignOut,
                child: const Text('Выйти'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}