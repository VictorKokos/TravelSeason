import 'package:flutter/material.dart';

class TourDetailsScreen extends StatelessWidget {
  final String tourName;
  final String tourDescription;
  final String imageUrl;
  final int duration;
  final double price;
  // ... другие данные о туре ...

  const TourDetailsScreen({
    Key? key,
    required this.tourName,
    required this.tourDescription,
    required this.imageUrl,
    required this.duration,
    required this.price,
    // ... другие параметры ...
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(tourName),
        leading: BackButton(),
        actions: [
          IconButton(
            icon: Icon(Icons.favorite_border),
            onPressed: () {
              // Логика для добавления/удаления из избранного
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                imageUrl,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tourName,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(tourDescription),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(Icons.schedule),
                      const SizedBox(width: 4),
                      Text('$duration дней'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(Icons.attach_money),
                      const SizedBox(width: 4),
                      Text('$price руб.'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // ... другие детали о туре, например, информация об отеле, рейсах и т.д. ...
                  const SizedBox(height: 24),
                  Center(
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width / 2,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () {
                          // Логика для бронирования тура
                        },
                        icon: Icon(Icons.check),
                        label: Text('Забронировать'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}