import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:travelzone/db_service.dart'; // Импорт файла с DbService
import 'package:travelzone/screens/add_tour_screen.dart'; // Импорт AddTourScreen
import 'package:travelzone/auth_service.dart'; // Импорт AuthService
import '../widgets/tour_item.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Stream<QuerySnapshot<Map<String, dynamic>>> toursStream;
  bool isAdmin = false; // Переменная для хранения статуса администратора
  bool isSuperAdmin = false; // Переменная для хранения статуса супер-администратора
  String? _userIdToManage; // ID пользователя для управления правами

  @override
  void initState() {
    super.initState();
    toursStream = FirebaseFirestore.instance.collection('tours').snapshots();
    _checkAdminStatus(); // Проверяем статус администратора при инициализации
  }

  // Функция для проверки статуса администратора и супер-администратора
  void _checkAdminStatus() async {
    final authService = AuthService();
    isAdmin = await authService.isCurrentUserAdmin();
    isSuperAdmin = await authService.isCurrentUserSuperAdmin();
    if (mounted) {
      setState(() {});
    }
  }

  // Подписываемся на изменения состояния аутентификации
  void _listenToAuthChanges() {
    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null) {
        _checkAdminStatus(); // Check admin status after authentication
      } else {
        isAdmin = false;
        isSuperAdmin = false;
        _userIdToManage = null; // Сбрасываем ID пользователя для управления
        if (mounted) {
          setState(() {});
        }
      }
    });
  }


  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _listenToAuthChanges(); // Начинаем слушать изменения состояния аутентификации
  }

  @override
  void dispose() {
    FirebaseAuth.instance.authStateChanges().listen((user) {
      // Remove the listener here
    }).cancel(); // This will cancel the listener and free up resources
    super.dispose();
  }

  // Функция для обновления прав доступа пользователя
  void _updateAdminStatus(bool newAdminStatus) async {
    final dbService = DbService();
    try {
      await dbService.updateAdminStatus(_userIdToManage!, newAdminStatus);
      _userIdToManage = null; // Сбрасываем ID пользователя для управления
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      print('Ошибка при обновлении статуса администратора: $e');
      // Handle the error, e.g., show an error message to the user.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Туры'),
      ),
      body: Column(
        children: [
          // Если пользователь - супер-администратор, показываем поле для ввода ID пользователя
            if (isSuperAdmin)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Поле для ввода ID пользователя
                  TextField(
                    decoration: const InputDecoration(
                      hintText: 'Введите ID пользователя',
                    ),
                    onChanged: (value) {
                      setState(() {
                        _userIdToManage = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16.0),
                  // Кнопки отдать/забрать права
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _userIdToManage != null
                              ? () => _updateAdminStatus(true)
                              : null,
                          child: const Text('Отдать права'),
                        ),
                      ),
                      const SizedBox(width: 16.0),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _userIdToManage != null
                              ? () => _updateAdminStatus(false)
                              : null,
                          child: const Text('Забрать права'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          // Кнопка "Добавить тур", если пользователь - администратор
          if (isAdmin)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () {
                  // Переход к AddTourScreen
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AddTourScreen(),
                    ),
                  );
                },
                child: const Text('Добавить тур'),
              ),
            ),
          // StreamBuilder для отображения списка туров
      Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: toursStream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Ошибка: ${snapshot.error}'));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final tours = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: tours.length,
                  reverse: true,
                  itemBuilder: (context, index) {
                    final tour = tours[index].data() as Map<String, dynamic>;
                    return TourItem(
                      tourId: tours[index].id, //  Используем ID тура из документа
                      key: Key(tours[index].id), // Ключ для каждого элемента
    );
  },
);
              },
            ),
          ),
        ],
      ),
    );
  }
}

