import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:travelzone/screens/tour_details_screen.dart';

class MiniTourItem extends StatelessWidget {
  final String tourId; // ID тура из Firestore
  const MiniTourItem({Key? key, required this.tourId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('tours').doc(tourId).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data!.exists) {
          final tourData = snapshot.data!.data() as Map<String, dynamic>;

          final imageUrl = tourData['image'];
          final title = tourData['name'];
          final price = tourData['price'];

          return SizedBox(
            width: 150, // Сделаем виджет квадратным
            height: 150,
            child: Card(
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TourDetailsScreen(tourId: tourId),
                    ),
                  );
                },
                child: Stack(
                  children: [
                    if (imageUrl != null && imageUrl.isNotEmpty)
                      Image.network(
                        imageUrl,
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                      )
                    else
                      const SizedBox(
                          height: 150,
                          child: Center(child: Text('Нет изображения'))),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        color: Colors.black54,
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min, // Уменьшаем размер колонки
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              title,
                              style: const TextStyle(
                                fontSize: 14, // Уменьшаем размер текста
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '\$$price',
                              style: const TextStyle(
                                fontSize: 12, // Уменьшаем размер текста
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
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
          return const CircularProgressIndicator();
        }
      },
    );
  }
}