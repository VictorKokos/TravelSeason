import 'package:flutter/material.dart';
import 'package:travelzone/screens/profile_screen.dart'; // Импорт ProfileScreen
import '../widgets/tour_item.dart';


class HomeScreen extends StatefulWidget  {
  
  const HomeScreen({Key? key}) : super(key: key);


  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0; // Индекс выбранного элемента BottomNavigationBar

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (_selectedIndex == 3) {
      // Переход на ProfileScreen, когда выбран последний элемент
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ProfileScreen()),
      );
    }
  }
 @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: RichText( // Используем RichText для форматирования части текста
          text: const TextSpan(
            style: TextStyle(fontSize: 18),
            children: [
              TextSpan(text: 'Hello there, '),
              TextSpan(
                text: 'Ana!',
                style: TextStyle(color: Colors.orange), // Оранжевый цвет для имени
              ),
            ],
          ),
        ),
       actions: const [
          CircleAvatar(
            backgroundImage: AssetImage('assets/images/profile_picture.jpg'), // Путь к изображению профиля
            radius: 50, // Настройте радиус по необходимости
        

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
    bottomNavigationBar: BottomNavigationBar(
  items: const [
    BottomNavigationBarItem(
      icon: Icon(Icons.home),
      label: 'Home',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.search),
      label: 'Search',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.favorite),
      label: 'Favorites',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.person),
      label: 'Profile',
    ),
  ],
   currentIndex: _selectedIndex,
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.black,
        onTap: _onItemTapped, // Обработчик нажатия на элемент 
),
    );
  }
}