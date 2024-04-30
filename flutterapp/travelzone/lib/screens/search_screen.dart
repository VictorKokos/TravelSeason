import 'package:flutter/material.dart';
import 'package:travelzone/screens/profile_screen.dart';
import '../widgets/tour_item.dart';
// ... (остальной код из предыдущего ответа)

// Скелет экрана поиска
class SearchScreen extends StatelessWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Поиск'),
      ),
      body: SingleChildScrollView( // Используем SingleChildScrollView для прокрутки
        child: Column(
          children: [
            // Здесь будут элементы поиска, например:
            // Поле ввода для поиска
            // Фильтры
            // Список результатов поиска
            ListTile(
              leading: Icon(Icons.flight),
              title: Text('Авиабилеты'),
            ),
            ListTile(
              leading: Icon(Icons.hotel),
              title: Text('Отели'),
            ),
            ListTile(
              leading: Icon(Icons.tour),
              title: Text('Туры'),
            ),
            // ... и другие элементы
          ],
        ),
      ),
    );
  }
}
