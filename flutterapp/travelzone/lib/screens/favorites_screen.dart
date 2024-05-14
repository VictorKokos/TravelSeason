import 'package:flutter/material.dart';
import '../widgets/mini_tour_item.dart';
import 'package:travelzone/database_helper.dart'; // Импортируем DatabaseHelper

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({Key? key}) : super(key: key);

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  late Stream<List<Map<String, dynamic>>> _favoriteToursStream;

  @override
  void initState() {
    super.initState();
    _favoriteToursStream = DatabaseHelper().getFavoriteToursStream();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Избранное'),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _favoriteToursStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Ошибка: ${snapshot.error}'));
          } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            print('Snapshot Data: ${snapshot.data}');
            final tourDocs = snapshot.data!;
            return GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: tourDocs.length,
              itemBuilder: (context, index) {
                final tourData = tourDocs[index];
                final tourId = tourData['tourId']; // Используйте 'tourId' 
                return MiniTourItem(tourId: tourId); 
              },
            );
          } else {
            return const Center(child: Text('В избранном пусто'));
          }
        },
      ),
    );
  }
}