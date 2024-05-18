import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:travelzone/db_service.dart';
import 'package:travelzone/screens/tour_details_screen.dart';
import 'package:travelzone/auth_service.dart'; // Импортируем AuthService
import 'package:travelzone/screens/edit_tour_screen.dart'; // Импортируем EditTourScreen

class TourItem extends StatefulWidget {
  final String tourId; // ID тура из Firestore
  const TourItem({Key? key, required this.tourId}) : super(key: key);

  @override
  State<TourItem> createState() => _TourItemState();
}

class _TourItemState extends State<TourItem> {
  bool isAdmin = false; // Переменная для хранения статуса администратора
  Map<String, dynamic>? tourData; // Добавлен для хранения данных тура
  Map<String, dynamic>? hotelData; // Добавлен для хранения данных отеля
  List<dynamic> hotelImages = []; // Добавлен для хранения изображений отеля
  List<String> amenities = []; // Добавлен для хранения удобств отеля

  @override
  void initState() {
    super.initState();
    _checkAdminStatus(); // Проверяем статус администратора при инициализации
    _fetchTourData(); // Получаем данные о туре при инициализации
  }

  // Функция для проверки статуса администратора
  void _checkAdminStatus() async {
    final authService = AuthService();
    isAdmin = await authService.isCurrentUserAdmin();
    if (mounted) {
      // Проверка, в дереве ли виджет
      setState(() {});
    }
  }

  // Функция для получения данных о туре
  void _fetchTourData() async {
    final dbService = DbService();
    tourData = await dbService.getTourById(widget.tourId);
    if (tourData != null) {
      // Получаем ID отеля
      final hotelId = tourData!['hotel_id'];
      // Получаем данные об отеле
      hotelData = await dbService.getHotelById(hotelId);
      if (hotelData != null) {
        // Извлекаем изображения отеля
        hotelImages = hotelData!['images'];
        // Извлекаем удобства отеля
        amenities = hotelData!['amenities'].cast<String>();
      }
      if (mounted) {
        // Обновляем состояние, если виджет все еще смонтирован
        setState(() {});
      }
    }
  }

  // Подписываемся на изменения состояния аутентификации
  void _listenToAuthChanges() {
    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null) {
        _checkAdminStatus(); // Check admin status after authentication
      } else {
        isAdmin = false; // Set isAdmin to false if the user logs out
        if (mounted) {
          // Check if the widget is still mounted
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

  // Функция для удаления тура
  void _deleteTour() async {
    final dbService = DbService();
    await dbService.deleteTour(widget.tourId); // Вызываем функцию удаления
    // После удаления можно перейти на предыдущий экран или обновить список туров
  }

  // Функция для перехода на экран редактирования
  void _editTour() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditTourScreen(
          tourId: widget.tourId,
          tourData: tourData!,
          hotelData: hotelData!,
          hotelImages: hotelImages,
          amenities: amenities,
          updateState: _updateState, // Передаем функцию обновления состояния
        ),
      ),
    );
  }

  // Функция для обновления состояния
  void _updateState() {
    setState(() {
      // Обновляем данные тура и отеля после редактирования
      _fetchTourData();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Проверяем наличие данных о туре
    if (tourData == null) {
      return const CircularProgressIndicator();
    }

    // Извлекаем данные из tourData
    final imageUrl = tourData!['image'];
    final title = tourData!['name'];
    final description = tourData!['description'];
    final duration = tourData!['duration']; // Предполагаем, что у тура есть поле duration
    final price = tourData!['price'];

    // Выводим URL изображения в консоль
    print('Image URL: $imageUrl');

    return SizedBox(
      width: 300,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            // Переход к экрану деталей тура при нажатии
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TourDetailsScreen(
                  tourId: widget.tourId,
                ),
              ),
            );
          },
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Изображение тура
                  if (imageUrl != null && imageUrl.isNotEmpty)
                    Image.network(
                      imageUrl,
                      height: 150,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    )
                  else
                    const SizedBox(
                        height: 150,
                        child: Center(child: Text('Нет изображения'))),

                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Название тура
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Страна
                        Text(
                          tourData!['country'], // Используем 'country' из данных
                          style:
                              const TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                        const SizedBox(height: 8),
                        // Цена
                        Text(
                          '\$$price', // Отображаем цену с символом доллара
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              // Иконка редактирования, если пользователь - администратор
              if (isAdmin)
                Positioned(
                  top: 10,
                  right: 50,
                  child: IconButton(
                    onPressed: _editTour,
                    icon: Icon(Icons.edit, color: Colors.blue),
                  ),
                ),
              // Иконка мусорной корзины, если пользователь - администратор
              if (isAdmin)
                Positioned(
                  top: 10,
                  right: 10,
                  child: IconButton(
                    onPressed: _deleteTour, // Вызываем _deleteTour при нажатии
                    icon: Icon(Icons.delete, color: Colors.red),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}