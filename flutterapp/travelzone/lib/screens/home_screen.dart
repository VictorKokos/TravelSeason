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
  late Stream<QuerySnapshot> toursStream;

  @override
  void initState() {
    super.initState();
    toursStream = FirebaseFirestore.instance.collection('tours').snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Туры'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: toursStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Ошибка: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final tours = snapshot.data!.docs;
          return ListView.builder(
            itemCount: tours.length,
            reverse: true, // Листаем снизу вверх
            itemBuilder: (context, index) {
              final tour = tours[index].data() as Map<String, dynamic>; // Получаем данные из документа
              return TourItem(
                tourId: tours[index].id,
              );
            },
          );
        },
      ),
    );
  }
}