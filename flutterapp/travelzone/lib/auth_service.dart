import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class AuthService {
  final FirebaseAuth _auth;

  AuthService({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance;

  Future<User?> signInWithEmailAndPassword(String email, String password) async {
    try {
      final UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (result.user != null) {
        // Проверяем, существует ли документ пользователя в Firestore
        final docSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(result.user!.uid)
            .get();
        if (!docSnapshot.exists) {
          await createUserDocument(result.user!); // Создаем документ, если он не существует
        }
        return result.user;
      }
    } catch (e) {
      print('Error signing in: $e');
      rethrow;
    }
  }
Future<bool> isCurrentUserSuperAdmin() async {
  final user = _auth.currentUser;
  if (user == null) {
    return false; 
  }

  final docSnapshot = await FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .get();

  if (docSnapshot.exists) {
    final isSuperAdmin = docSnapshot.data()!['isSuperAdmin'];
    if (isSuperAdmin != null) {
      return isSuperAdmin as bool; // Приводим к типу bool только если isSuperAdmin не null
    } else {
      return false; // Возвращаем false, если isSuperAdmin равно null
    }
  } else {
    return false; 
  }
}
  Future<User?> registerWithEmailAndPassword(String email, String password) async {
    try {
      final UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (result.user != null) {
        await createUserDocument(result.user!); // Создаем документ пользователя в Firestore
      }
      return result.user;
    } catch (e) {
      print('Error registering: $e');
      rethrow;
    }
  }

  Future<User?> getCurrentUser() async {
    try {
      final User? currentUser = _auth.currentUser;
      return currentUser;
    } catch (e) {
      print('Error getting current user: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print('Error signing out: $e');
      rethrow;
    }
  }

// auth_service.dart 

// ... (остальной код) ...

  Future<void> createUserDocument(User user) async {
    final firestore = FirebaseFirestore.instance;
    // Создаем документ с ID, равным UID пользователя
    await firestore.collection('users').doc(user.uid).set({
      'firstName': user.displayName?.split(' ')[0] ?? '',
      'lastName': user.displayName?.split(' ')[1] ?? '',
      // Добавьте другие поля, которые хотите сохранить для пользователя
      'isAdmin': false, // Добавляем поле isAuth со значением false по умолчанию
    });
  }

  Future<void> updateUserProfile(
      User user, String firstName, String lastName, PlatformFile? image) async {
    final firestore = FirebaseFirestore.instance;

    // Загружаем изображение профиля, если оно выбрано
    String? photoURL;
    if (image != null && image.path != null) {
      // Проверяем, что image.path не null
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('user_profiles/${user.uid}.jpg');
      await storageRef.putFile(File(image.path!)); // Используем ! для указания, что image.path не null
      photoURL = await storageRef.getDownloadURL();
    }

    // Обновляем поля firstName, lastName и photoURL
    await firestore.collection('users').doc(user.uid).update({
      'firstName': firstName,
      'lastName': lastName,
      if (photoURL != null) 'photoURL': photoURL,
    });

    // Обновляем displayName пользователя в FirebaseAuth
    await user.updateDisplayName('$firstName $lastName');

    // При необходимости, обновите photoURL пользователя в FirebaseAuth
    if (photoURL != null) {
      await user.updatePhotoURL(photoURL);
    }
  }
Future<bool> isCurrentUserAdmin() async {
    final user = _auth.currentUser;
    if (user == null) {
      return false; // Пользователь не авторизован (включая гостя)
    }

    final docSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    if (docSnapshot.exists) {
      return docSnapshot.data()!['isAdmin'] as bool; // Проверяем поле isAdmin
    } else {
      return false; // Документ пользователя не найден (гость или ошибка)
    }
  }
}