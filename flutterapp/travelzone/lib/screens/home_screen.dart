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

  @override
  void initState() {
    super.initState();
    toursStream = FirebaseFirestore.instance.collection('tours').snapshots();
    _checkAdminStatus(); // Проверяем статус администратора при инициализации
  }

  // Функция для проверки статуса администратора
  void _checkAdminStatus() async {
    final authService = AuthService();
    isAdmin = await authService.isCurrentUserAdmin();
    if (mounted) { // Проверка, в дереве ли виджет
      setState(() {});
    }
  }

  // Подписываемся на изменения состояния аутентификации
  void _listenToAuthChanges() {
    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null) {
        _checkAdminStatus(); // Check admin status after authentication
      } else {
        isAdmin = false; // Set isAdmin to false if the user logs out
        if (mounted) { // Check if the widget is still mounted
          setState(() {}); // Update state if mounted
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Туры'),
      ),
      body: Column(
        children: [
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
                  reverse: true, // Листаем снизу вверх
                  itemBuilder: (context, index) {
                    final tour = tours[index].data() as Map<String, dynamic>; // Получаем данные из документа
                    return TourItem(
                      tourId: tours[index].id,
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