import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:travelzone/screens/profile_screen.dart';
import '../widgets/mini_tour_item.dart';
import 'package:travelzone/database_helper.dart'; // Импортируем DatabaseHelper

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({Key? key}) : super(key: key);

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  late Future<List<Map<String, dynamic>>> _favoriteTours;

  @override
  void initState() {
    super.initState();
    _favoriteTours = DatabaseHelper().getAllFavoriteTours();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Избранное'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _favoriteTours,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final tourDocs = snapshot.data!;
            if (tourDocs.isEmpty) {
              return const Center(child: Text('В избранном пусто'));
            }
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
          } else if (snapshot.hasError) {
            return Center(child: Text('Ошибка: ${snapshot.error}'));
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}