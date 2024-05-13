import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
const List<Map<String, dynamic>> hotelsData = [
{
  "name": "Hotel Belmond Splendido",
  "description": "Роскошный 5-звездочный отель в Портофино с потрясающим видом на море.",
  "location": "Портофино, Италия",
  "star_rating": 5,
  "images": [
    "https://firebasestorage.googleapis.com/v0/b/travel-season-54aac.appspot.com/o/hotels%2F2_1.jpg?alt=media&token=a1e0878c-31bb-4aa1-a73c-3b1bd4054257",
    "https://firebasestorage.googleapis.com/v0/b/travel-season-54aac.appspot.com/o/hotels%2F2_2.jpg?alt=media&token=61eee0ea-d94b-4cdb-a99e-9ed62cfdffc0"
  ],
  "amenities": ["бассейн", "спа", "фитнес-центр", "ресторан", "Wi-Fi"],
  "reviews": [
    {
      "user_id": "user123",
      "rating": 5,
      "text": "Прекрасный отель с великолепным видом и сервисом!"
    },
    {
      "user_id": "user456",
      "rating": 4,
      "text": "Отличное расположение, но завтраки могли быть разнообразнее."
    }
  ]
},
  {
 "name": "Hyatt Regency Kyoto",
  "description": "Современный 4-звездочный отель в центре Киото.",
  "location": "Киото, Япония",
  "star_rating": 4,
  "images": [
    "https://firebasestorage.googleapis.com/v0/b/travel-season-54aac.appspot.com/o/hotels%2F3_1.jpg?alt=media&token=9c93dd4a-d7b7-457f-838c-10d575a3b2b8",
    "https://firebasestorage.googleapis.com/v0/b/travel-season-54aac.appspot.com/o/hotels%2F3_2.jpg?alt=media&token=bad95c1b-4ea0-454a-a786-256dd22e7c20"
  ],
  "amenities": ["фитнес-центр", "ресторан", "бар", "Wi-Fi", "конференц-залы"],
  "reviews": [] // пустой массив, так как отзывов нет
  },
  {
   "name": "Mara Serena Safari Lodge",
  "description": "Уникальный лодж в стиле масаи в парке Масаи Мара.",
  "location": "Масаи Мара, Кения",
  "star_rating": 4,
  "images": [
    "https://firebasestorage.googleapis.com/v0/b/travel-season-54aac.appspot.com/o/hotels%2F1_1.jpg?alt=media&token=5945c967-4fa1-4823-a00f-9c4f43c27eb8",
    "https://firebasestorage.googleapis.com/v0/b/travel-season-54aac.appspot.com/o/hotels%2F1_2.jpg?alt=media&token=4be5ad5e-79b6-4676-b464-d98bde317a87",
    "https://firebasestorage.googleapis.com/v0/b/travel-season-54aac.appspot.com/o/hotels%2F1_3.jpg?alt=media&token=50701ec0-8d8c-4bbb-b6bd-f5086f8e5bfc"
  ],
  "amenities": ["бассейн", "ресторан", "бар", "наблюдение за животными", "Wi-Fi"],
  "reviews": [
    {
      "user_id": "user789",
      "rating": 5,
      "text": "Незабываемое сафари! Лодж прекрасно вписан в природу."
    }
  ]
  },
];

 List<Map<String, dynamic>> toursData = [
 
{
  "name": "Роскошь Итальянской Ривьеры",
  "description": "5-дневный отдых в Портофино с проживанием в Hotel Belmond Splendido. Насладитесь живописными видами, изысканной кухней и расслабляющей атмосферой.",
  "price": 3500,
  "start_date": 1692521600, // 20.08.2023
  "end_date": 1693126400, // 25.08.2023 
  "hotel_id": "R2sREIlUjhhxNmkK8Rmi",
  "country": "Италия",
  "image": "https://firebasestorage.googleapis.com/v0/b/travel-season-54aac.appspot.com/o/tours%2F1.jpg?alt=media&token=44ccd9b9-cbc5-4ff9-909c-c311277a816c"
},
  {
    
  "name": "Осенние краски Киото",
  "description": "10-дневный тур по Киото с проживанием в Hyatt Regency Kyoto. Погрузитесь в японскую культуру, посетите древние храмы и сады, насладитесь красотой осенней листвы.",
  "price": 2200,
  "start_date": 1701510400, // 01.10.2023
  "end_date": 1702918400, // 10.10.2023 
  "hotel_id": "eRzgfSB8t93LmavZVSaK",
  "country": "Япония",
  "image": "https://firebasestorage.googleapis.com/v0/b/travel-season-54aac.appspot.com/o/tours%2F2.jpg?alt=media&token=857b18e5-a274-49b1-92fa-1a5d85183d70" 
},



 {
    "name": "Кенийское сафари",
    "description": "7-дневное приключение в Масаи Мара.",
    "price": 1800,
    "start_date": 1694326400, // 10.09.2023
    "end_date": 1695916800, // 24.09.2023 
    "country": "Кения",
    "image": "https://firebasestorage.googleapis.com/v0/b/travel-season-54aac.appspot.com/o/tours%2F3.jpg?alt=media&token=c3548c8f-ab2d-4c95-a4ed-920e91006438"
  },
  // ... остальные туры
];

const List<Map<String, dynamic>> countriesData = [
  {"name": "Италия"},
  {"name": "Япония"},
  {"name": "Кения"},
  // ... другие страны
];


Future<void> clearHotelsData() async {
  final hotelsRef = FirebaseFirestore.instance.collection('hotels');
  final snapshot = await hotelsRef.get();
  for (final doc in snapshot.docs) {
    await doc.reference.delete();
  }
  print('Данные из коллекции "hotels" успешно удалены.');
}
Future<void> clearToursData() async {
  final toursRef = FirebaseFirestore.instance.collection('tours');
  final snapshot = await toursRef.get();
  for (final doc in snapshot.docs) {
    await doc.reference.delete();
  }
  print('Данные из коллекции "tours" успешно удалены.');
}


Future<void> clearCountriesData() async {
  final countriesRef = FirebaseFirestore.instance.collection('countries');
  final snapshot = await countriesRef.get();
  for (final doc in snapshot.docs) {
    await doc.reference.delete();
  }
  print('Данные из коллекции "countries" успешно удалены.');
}

Future<String> uploadImageToCloudinary(String imagePath) async {
  final cloudinary = CloudinaryPublic('dfdinr6zu', 'ml_default', cache: false);
  
  try {
    print('Начинаем загрузку изображения: $imagePath'); 
    CloudinaryResponse response = await cloudinary.uploadFile(
      CloudinaryFile.fromFile(imagePath),
    );
    print('Изображение успешно загружено: ${response.secureUrl}'); 
    return response.secureUrl;
  } catch (e) {
    print('Ошибка загрузки изображения: $e');
    return ''; 
  }
}



Future<void> prefillData() async {
  final firestore = FirebaseFirestore.instance;
  final hotelsRef = firestore.collection('hotels');
  final toursRef = firestore.collection('tours');
  final countriesRef = firestore.collection('countries');

 // 1. Очищаем данные в обеих коллекциях
  print("Начало очистки данных...");
  await clearHotelsData();
  await clearToursData(); 
   await clearCountriesData(); 
 

 // 2. Добавляем страны
print("Начало добавления стран...");
  final countryIds = <String, String>{}; // Используем Map для хранения ID стран
  for (final country in countriesData) {
    final docRef = await countriesRef.add(country);
    countryIds[country['name']] = docRef.id;
    print("Страна добавлена с ID: ${docRef.id}");
  }
  print("Добавление стран завершено.");


  // 3. Добавляем отели и сохраняем их ID
  print("Начало добавления отелей...");
  final hotelIds = <String>[];
  for (final hotel in hotelsData) {
    final docRef = await hotelsRef.add(hotel);
    hotelIds.add(docRef.id);
    print("Отель добавлен с ID: ${docRef.id}"); // Логирование ID добавленного отеля
  }
  print("Добавление отелей завершено.");
  // 4. Добавляем туры, используя сохраненные ID отелей и стран

 print('Начало добавления туров...');
  for (var i = 0; i < toursData.length; i++) {
    final tourData = toursData[i];
    final tour = {...tourData};
    print('Обработка тура: $tour');

    if (tour['image'] != null && tour['image'] is String) {
      String imagePath =
          'D:\\Work\\3k2s\\kusrach5\\Project\\Images\\Tours\\${tour['image']}';
      print('Загрузка изображения: $imagePath');
      String imageUrl = await uploadImageToCloudinary(imagePath);
      if (imageUrl.isNotEmpty) {
        tour['image'] = imageUrl;
        print('Изображение успешно загружено: $imageUrl');
      } else {
        print('Ошибка загрузки изображения для тура: ${tour['name']}');
      }
    }

    try {
      tour['hotel_id'] = hotelIds[i];
      tour['country'] = countryIds[tour['country']]; // Заменяем название страны на ссылку
      await toursRef.add(tour);
      print('Тур успешно добавлен.');
    } catch (e) {
      print('Ошибка при добавлении тура: $e');
    }
  }
  print('Добавление туров завершено.');
 
}


