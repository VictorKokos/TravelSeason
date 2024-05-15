import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:travelzone/auth_service.dart';
import 'package:file_picker/file_picker.dart';

class ProfileWidget extends StatefulWidget {
  final User user;
  final Function() onSignOut;
  final Function(User user, String firstName, String lastName, PlatformFile? image)
      onUpdateProfile;

  const ProfileWidget(
      {Key? key,
      required this.user,
      required this.onSignOut,
      required this.onUpdateProfile})
      : super(key: key);

  @override
  State<ProfileWidget> createState() => _ProfileWidgetState();
}

class _ProfileWidgetState extends State<ProfileWidget> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  String? _errorMessage;
  PlatformFile? _image;

  @override
  void initState() {
    super.initState();
   _firstNameController.text = widget.user.displayName?.split(' ')[0] ?? '';
    _lastNameController.text = widget.user.displayName?.split(' ')[1] ?? '';

    // Добавляем слушателей для автоматического обновления профиля
    _firstNameController.addListener(_updateProfile);
    _lastNameController.addListener(_updateProfile);
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  Future<void> _updateProfile() async {
    try {
      await widget.user.updateDisplayName(
          '${_firstNameController.text} ${_lastNameController.text}');
      setState(() {
        _errorMessage = null;
      });
      widget.onUpdateProfile(widget.user, _firstNameController.text,
          _lastNameController.text, _image);
    } catch (e) {
      setState(() {
        _errorMessage = 'Ошибка при обновлении профиля';
      });
    }
  }

  Future<void> _getImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );
    if (result != null) {
      setState(() {
        _image = result.files.first;
        // Обновляем профиль после выбора изображения
        _updateProfile();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.user == null) {
      return const Text('Пользователь не вошел в систему');
    }
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: _getImage,
              child: CircleAvatar(
                radius: 60,
                backgroundImage: _image != null
                    ? FileImage(File(_image!.path!)) as ImageProvider
                    : widget.user.photoURL != null
                        ? NetworkImage(widget.user.photoURL!) as ImageProvider
                        : const AssetImage('assets/default_profile.png')
                            as ImageProvider,
                child: _image == null && widget.user.photoURL == null
                    ? const Icon(Icons.person, size: 60)
                    : null,
              ),
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _firstNameController,
              decoration: const InputDecoration(labelText: 'Имя'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _lastNameController,
              decoration: const InputDecoration(labelText: 'Фамилия'),
            ),
            const SizedBox(height: 24),
            if (_errorMessage != null)
              Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: widget.onSignOut,
              child: const Text('Выйти'),
            ),
          ],
        ),
      ),
    );
  }
}