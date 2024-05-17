import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:travelzone/database_helper.dart';
import 'package:travelzone/screens/tour_details_screen.dart';

class MiniTourItem extends StatefulWidget {
  final String tourId;
  const MiniTourItem({Key? key, required this.tourId}) : super(key: key);

  @override
  State<MiniTourItem> createState() => _MiniTourItemState();
}

class _MiniTourItemState extends State<MiniTourItem> {
  Map<String, dynamic>? _tourData; // Храним данные о туре

  @override
  void initState() {
    super.initState();
    _fetchTourData();
  }

  // Метод для получения данных о туре из SQLite
  Future _fetchTourData() async {
    final db = await DatabaseHelper().database;
    final tourData = await db.query('favorites', where: 'tourId = ?', whereArgs: [widget.tourId]);
    if (tourData.isNotEmpty) {
      setState(() {
        _tourData = Map.from(tourData.first); // Создаем копию Map
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Проверяем, есть ли данные о туре
    if (_tourData != null) {
      final title = _tourData!['name'];
      final price = _tourData!['price'];
      final hotelId = _tourData!['hotelId'];

      return SizedBox(
        width: double.infinity, // Занимаем всю доступную ширину
        child: Card(
          clipBehavior: Clip.antiAlias,
          margin: const EdgeInsets.symmetric(horizontal: 16), // Добавляем отступы по бокам
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TourDetailsScreen(tourId: widget.tourId),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(16.0), // Добавляем внутренние отступы
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '\$$price',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      await DatabaseHelper().deleteFavorite(widget.tourId, hotelId);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Закладка удалена')),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    } else {
      return const Center(child: CircularProgressIndicator());
    }
  }
}