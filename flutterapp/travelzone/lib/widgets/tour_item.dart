import 'package:flutter/material.dart';
import 'package:travelzone/screens/tour_details_screen.dart';

class TourItem extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String description;
  final int duration;
  final double price;

  const TourItem({
    Key? key,
    required this.imageUrl,
    required this.title,
    required this.description,
    required this.duration,
    required this.price,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox( // Ограничиваем ширину TourItem шириной экрана
      width: 300,
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        child: InkWell( // InkWell вместо GestureDetector для визуального отклика
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TourDetailsScreen(
                  tourName: title,
                  tourDescription: description,
                  imageUrl: imageUrl,
                  duration: duration,
                  price: price,
                  // ... другие данные о туре ...
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                SizedBox( // Ограничиваем размер изображения
                  width: 80,
                  height: 80,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      imageUrl,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.schedule, size: 16),
                          const SizedBox(width: 4),
                          Text('$duration дней'),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.attach_money, size: 16),
                          const SizedBox(width: 4),
                          Text('$price руб.'), 
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}