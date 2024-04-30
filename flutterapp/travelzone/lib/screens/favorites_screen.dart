import 'package:flutter/material.dart';
import 'package:travelzone/screens/profile_screen.dart';
import '../widgets/tour_item.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Избранное'),
      ),
      body: const SingleChildScrollView( // Используем SingleChildScrollView для прокрутки
     child:  Column(
          children: [
            // Здесь будут элементы избранного, например:
            // Список сохраненных туров
            // Список сохраненных отелей
            // ... и другие элементы
            ListTile(
              leading: Icon(Icons.favorite),
              title: Text('Тур в Париж'),
              subtitle: Text('7 дней, 8 ночей'),
            ),
            ListTile(
              leading: Icon(Icons.favorite),
              title: Text('Отель "Мариотт"'),
              subtitle: Text('Москва, 5 звезд'),
            ),
            // ... и другие элементы
          ],
        ),
      ),
    );
  }
}