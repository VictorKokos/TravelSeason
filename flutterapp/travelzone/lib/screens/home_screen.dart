import 'package:flutter/material.dart';
import 'package:travelzone/screens/profile_screen.dart';
import '../widgets/tour_item.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (_selectedIndex == 3) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ProfileScreen()),
      ).then((_) => setState(() {})); // Обновляем состояние после возвращения с ProfileScreen
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
      body: const SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
             
              Text(
                'Select a category',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              // Category list
           
              SizedBox(height: 24),
              Text(
                'Popular',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              // Popular recipes list
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    TourItem(
                        imageUrl: 'assets/images/blueberry_pancakes.jpg',
                        title: 'Blueberry Pancakes',
                        description: 'Amazing combo of sweet and sour taste!',
                        duration: 25,
                        price: 4.9),
                    TourItem(
                        imageUrl: 'assets/images/tart.jpg',
                        title: 'Raspberry Tart',
                        description: 'Amazing combo of sweet and sour taste!',
                        duration: 35,
                        price: 4.7),
                  ],
                ),
              ),
              SizedBox(height: 24),
              Text(
                'Search by cuisine',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              // Cuisine list
             
            
            ],
          ),
        ),
      ),
     
    );
  }
}