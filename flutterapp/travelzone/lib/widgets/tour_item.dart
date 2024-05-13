import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:travelzone/screens/tour_details_screen.dart';

class TourItem extends StatelessWidget {
  final String tourId; // ID тура из Firestore
  const TourItem({Key? key, required this.tourId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('tours').doc(tourId).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data!.exists) {
          final tourData = snapshot.data!.data() as Map<String, dynamic>;

          // Извлекаем данные из tourData
          final imageUrl = tourData['image'];
          final title = tourData['name'];
          final description = tourData['description'];
          final duration = tourData['duration']; // Предполагаем, что у тура есть поле duration
          final price = tourData['price'];

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
                      builder: (context) => TourDetailsScreen(tourId: tourId),
                    ),
                  );
                },
                child: Column(
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
                    height: 150, child: Center(child: Text('Нет изображения'))),

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
                            tourData['country'], // Используем 'country' из данных
                            style: const TextStyle(fontSize: 14, color: Colors.grey),
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
              ),
            ),
          );
        } else if (snapshot.hasError) {
          return Text('Ошибка: ${snapshot.error}');
        } else {
          return const CircularProgressIndicator(); // Пока данные загружаются
        }
      },
    );
  }
}