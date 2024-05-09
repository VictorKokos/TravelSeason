import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:travelzone/screens/profile_screen.dart';
import '../widgets/tour_item.dart';
import 'package:travelzone/db_service.dart'; // Импорт файла с DbService

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

  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if (_selectedIndex == 3) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ProfileScreen()),
      ).then((_) => setState(() {})); 
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: RichText(
          text: const TextSpan(
            style: TextStyle(fontSize: 18),
            children: [
              TextSpan(text: 'Hello there, '),
              TextSpan(
                text: 'Ana!',
                style: TextStyle(color: Colors.orange),
              ),
            ],
          ),
        ),
        actions: const [
          CircleAvatar(
            backgroundImage: AssetImage('assets/images/profile_picture.jpg'),
            radius: 50,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Select a category',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              // Category list

              const SizedBox(height: 24),
              const Text(
                'Popular',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              // Popular recipes list
              FutureBuilder<List<Map<String, dynamic>>>(
                future: toursFuture,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } 
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final tours = snapshot.data!;
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: tours
                           .map((doc) => TourItem(tourId: doc['id'])) // Использование doc.id
                          .toList(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 24),
              const Text(
                'Search by cuisine',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              // Cuisine list
            ],
          ),
        ),
      ),
    );
  }
}