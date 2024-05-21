import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:travelzone/auth_service.dart';
import 'package:travelzone/widgets/profile_widget.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _showSignInForm = true; // По умолчанию показываем форму входа
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  User? _currentUser; // Добавляем переменную для хранения текущего пользователя

  void _toggleForm() {
    setState(() {
      _showSignInForm = !_showSignInForm;
    });
    _formKey.currentState?.reset(); // Очищаем поля формы
  }

  @override
  void initState() {
    super.initState();
    // Подписываемся на изменения состояния аутентификации
    FirebaseAuth.instance.authStateChanges().listen((user) {
      print('authStateChanges: user = $user');
      setState(() {
        _currentUser = user; // Обновляем состояние с текущим пользователем
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Профиль'),
      ),
      body: FutureBuilder<User?>(
        future: _authService.getCurrentUser(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator(); // Индикатор загрузки
          } else if (snapshot.hasError) {
            return Text('Ошибка: ${snapshot.error}');
          } else if (snapshot.hasData && snapshot.data != null) {
            return ProfileWidget(
              user: snapshot.data!,
              onSignOut: () async {
                await _authService.signOut();
                setState(() {});
              },
              onUpdateProfile: _authService.updateUserProfile,
            );
          } else {
            // Пользователь не аутентифицирован, отображаем форму входа
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center, // Выравнивание по центру
                  children: [
                    // Заголовок формы
                    Text(
                      _showSignInForm ? 'Вход' : 'Регистрация',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 32), // Добавляем отступ
                    // Поля ввода
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(labelText: 'Email'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Пожалуйста, введите email';
                        }
                        if (!value.contains('@')) {
                          return 'Пожалуйста, введите корректный email';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(labelText: 'Пароль'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Пожалуйста, введите пароль';
                        }
                        if (value.length < 6) {
                          return 'Пароль должен содержать не менее 6 символов';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    // Кнопка отправки формы
                    ElevatedButton(
                      onPressed: _submitForm,
                      child: Text(_showSignInForm ? 'Войти' : 'Зарегистрироваться'),
                    ),
                    const SizedBox(height: 16),
                    // Кнопка переключения формы
                    TextButton(
                      onPressed: _toggleForm,
                      child: Text(
                        _showSignInForm
                            ? 'Нет аккаунта? Зарегистрируйтесь'
                            : 'Уже есть аккаунт? Войдите',
                        style: const TextStyle(color: Colors.blue),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }

  Future _submitForm() async {
    if (_formKey.currentState!.validate()) {
      try {
        User? user;
        if (_showSignInForm) {
          // Проверка существования email перед входом
          await FirebaseAuth.instance.fetchSignInMethodsForEmail(_emailController.text);
          user = await _authService.signInWithEmailAndPassword(
            _emailController.text,
            _passwordController.text,
          );
        } else {
          // Проверка существования email перед регистрацией
          await FirebaseAuth.instance.fetchSignInMethodsForEmail(_emailController.text);
          user = await _authService.registerWithEmailAndPassword(
            _emailController.text,
            _passwordController.text,
          );
        }
        if (user != null) {
          // Успешная аутентификация/регистрация
          setState(() {
            _currentUser = user;
          });
          print('Вход выполнен успешно! User ID: ${user.uid}');
        }
      } catch (e) {
        print('Ошибка аутентификации: $e');
        // Показываем попап с ошибкой
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Ошибка'),
              content: Text(
                _getErrorMessage(e), // Используем функцию для получения сообщения
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      }
    }
  }

  // Функция для получения более понятного сообщения об ошибке
  String _getErrorMessage(dynamic e) {
    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'weak-password':
          return 'Пароль слишком слабый.';
        case 'email-already-in-use':
          return 'Email уже используется.';
        case 'invalid-email':
          return 'Неверный email.';
        case 'user-not-found':
          return 'Пользователь не найден.';
        case 'wrong-password':
          return 'Неверный пароль.';
        case 'invalid-credential':
          return 'Неверный email или пароль.'; // Добавленное сообщение
        default:
          return 'Произошла ошибка аутентификации.';
      }
    } else {
      return 'Произошла ошибка аутентификации.';
    }
  }
}