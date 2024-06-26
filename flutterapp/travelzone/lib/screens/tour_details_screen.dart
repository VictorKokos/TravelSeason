import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:http/http.dart' as http;
import 'package:travelzone/database_helper.dart';
import 'package:travelzone/screens/tour_booking_screen.dart';
import 'package:travelzone/screens/profile_screen.dart'; // Импортируем экран авторизации

class TourDetailsScreen extends StatefulWidget {
  final String tourId;
  const TourDetailsScreen({Key? key, required this.tourId}) : super(key: key);
  @override
  State<TourDetailsScreen> createState() => _TourDetailsScreenState();
}

class _TourDetailsScreenState extends State<TourDetailsScreen> {
  late Future<DocumentSnapshot> tourFuture;
  late Future<DocumentSnapshot> hotelFuture;
  int currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    tourFuture = FirebaseFirestore.instance
        .collection('tours')
        .doc(widget.tourId)
        .get();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Details'),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: tourFuture,
        builder: (context, tourSnapshot) {
          if (tourSnapshot.hasData && tourSnapshot.data!.exists) {
            final tourData = tourSnapshot.data!.data() as Map<String, dynamic>;
            final tourId = tourSnapshot.data!.id;
            final hotelId = tourData['hotel_id'];
            hotelFuture = FirebaseFirestore.instance
                .collection('hotels')
                .doc(hotelId)
                .get();
            return FutureBuilder<DocumentSnapshot>(
              future: hotelFuture,
              builder: (context, hotelSnapshot) {
                if (hotelSnapshot.hasData && hotelSnapshot.data!.exists) {
                  final hotelData =
                      hotelSnapshot.data!.data() as Map<String, dynamic>;
                  final hotelImages = hotelData['images'] as List<dynamic>;
                  return SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Просмотр изображений отеля
                        SizedBox(
                          height: 200,
                          child: PageView.builder(
                            onPageChanged: (index) {
                              setState(() {
                                currentImageIndex = index;
                              });
                            },
                            itemCount: hotelImages.length,
                            itemBuilder: (context, index) {
                              return Image.network(
                                hotelImages[index],
                                fit: BoxFit.cover,
                              );
                            },
                          ),
                        ),
                        // Индикатор текущего изображения
                        Center(
                          child: DotsIndicator(
                            dotsCount: hotelImages.length,
                            position: currentImageIndex.toDouble(),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Название отеля
                              Text(
                                hotelData['name'],
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              // Местоположение
                              Text(
                                hotelData['location'],
                                style: const TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 16),
                              // Описание
                              Text(
                                hotelData['description'],
                                style: const TextStyle(fontSize: 16),
                              ),
                              const SizedBox(height: 16),
                              // Удобства
                              const Text(
                                'Amenities:',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              // Список удобств
                              ...hotelData['amenities']
                                  .map<Widget>((amenity) {
                                return Text('- $amenity');
                              }).toList(),
                            ],
                          ),
                        ),
                        // Кнопки действий
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 24.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 16.0),
                                  textStyle:
                                      const TextStyle(color: Colors.white),
                                ),
                                onPressed: () async {
                                  // Добавляем тур в избранное
                                  print(tourId);
                                  // Сразу показываем SnackBar
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content:
                                          Text('Добавлено в избранное'),
                                    ),
                                  );

                                  // Скачиваем изображения и сохраняем в БД
                                  await _downloadAndSaveHotelImages(
                                      hotelId, hotelImages);

                                  await DatabaseHelper()
                                      .addToFavorites(
                                          tourId,
                                          hotelId,
                                          tourData,
                                          hotelData,
                                          hotelImages);
                                },
                                icon: const Icon(
                                  Icons.bookmark_border,
                                  color: Colors.white,
                                ),
                                label: const Text(
                                  'Add to bookmarks',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 16.0),
                                  textStyle:
                                      const TextStyle(color: Colors.white),
                                ),
                                onPressed: () {
                                  // Проверяем, авторизован ли пользователь
                                  final user = FirebaseAuth.instance.currentUser;
                                  if (user != null) {
                                    // Переход на страницу бронирования
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            TourBookingScreen(tourId: tourId),
                                      ),
                                    );
                                  } else {
                                    // Показываем уведомление
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            'Для бронирования тура необходимо авторизоваться'),
                                      ),
                                    );
                                  }
                                },
                                icon: const Icon(
                                  Icons.flight_takeoff,
                                  color: Colors.white,
                                ),
                                label: const Text(
                                  'Book Tour',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                } else if (hotelSnapshot.hasError) {
                  return Text('Error: ${hotelSnapshot.error}');
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              },
            );
          } else if (tourSnapshot.hasError) {
            return Text('Error: ${tourSnapshot.error}');
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  // Функция для скачивания и сохранения изображений отеля
  Future<void> _downloadAndSaveHotelImages(
      String hotelId, List<dynamic> imageUrls) async {
    final appDir = await getApplicationDocumentsDirectory();
    for (final imageUrl in imageUrls) {
      final imageName = imageUrl.split('/').last;
      final imagePath = join(appDir.path, imageName);
      try {
        final response = await http.get(Uri.parse(imageUrl));
        final file = File(imagePath);
        await file.writeAsBytes(response.bodyBytes);
        // Сохраняем локальный путь к изображению в БД
        await DatabaseHelper().insertHotelImage(hotelId, imagePath);
      } catch (e) {
        print('Error downloading image: $e');
      }
    }
  }
}

// Виджет для индикатора изображений
class DotsIndicator extends StatelessWidget {
  final int dotsCount;
  final double position;
  const DotsIndicator(
      {Key? key, required this.dotsCount, this.position = 0.0})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(dotsCount, (index) {
        return Container(
          width: 8,
          height: 8,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            // Используем BoxShape.circle для круглой формы
            color: index == position ? Colors.blue : Colors.grey,
          ),
        );
      }),
    );
  }
}