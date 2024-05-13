import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:travelzone/db_service.dart'; // Импорт файла с DbService
import '../widgets/tour_item.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Map<String, dynamic>>> toursFuture;

  @override
  void initState() {
    super.initState();
    toursFuture = DbService().getTours(); // Получаем данные из Firestore
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Туры'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: toursFuture,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Ошибка: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final tours = snapshot.data!;
          return ListView.builder(
            itemCount: tours.length,
            reverse: true, // Листаем снизу вверх
            itemBuilder: (context, index) {
              final tour = tours[index];
              return TourItem(
                tourId: tour['id'],
                
              );
            },
          );
        },
      ),
    );
  }
}