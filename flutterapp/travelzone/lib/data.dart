import 'package:cloud_firestore/cloud_firestore.dart';
const List<Map<String, dynamic>> hotelsData = [
{
  "name": "Hotel Belmond Splendido",
  "description": "Роскошный 5-звездочный отель в Портофино с потрясающим видом на море.",
  "location": "Портофино, Италия",
  "star_rating": 5,
  "images": [
    "https://example.com/splendido_1.jpg",
    "https://example.com/splendido_2.jpg"
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
    "https://example.com/hyatt_kyoto_1.jpg",
    "https://example.com/hyatt_kyoto_2.jpg"
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
    "https://example.com/mara_lodge_1.jpg",
    "https://example.com/mara_lodge_2.jpg"
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
  "image": "https://example.com/italian_riviera.jpg"
},
  {
    
  "name": "Осенние краски Киото",
  "description": "10-дневный тур по Киото с проживанием в Hyatt Regency Kyoto. Погрузитесь в японскую культуру, посетите древние храмы и сады, насладитесь красотой осенней листвы.",
  "price": 2200,
  "start_date": 1701510400, // 01.10.2023
  "end_date": 1702918400, // 10.10.2023 
  "hotel_id": "eRzgfSB8t93LmavZVSaK",
  "country": "Япония",
  "image": "https://example.com/kyoto_fall.jpg" 
},



 {
    "name": "Кенийское сафари",
    "description": "7-дневное приключение в Масаи Мара.",
    "price": 1800,
    "start_date": 1694326400, // 10.09.2023
    "end_date": 1695916800, // 24.09.2023 
    "country": "Кения",
    "image": "https://example.com/kenya_safari.jpg"
  },
  // ... остальные туры
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
Future<void> prefillData() async {
  final firestore = FirebaseFirestore.instance;
  final hotelsRef = firestore.collection('hotels');
  final toursRef = firestore.collection('tours');

 // 1. Очищаем данные в обеих коллекциях
  print("Начало очистки данных...");
  await clearHotelsData();
  print("Очистка коллекции 'hotels' завершена.");
  await clearToursData(); 
  print("Очистка коллекции 'tours' завершена.");

  // 2. Добавляем отели и сохраняем их ID
  print("Начало добавления отелей...");
  final hotelIds = <String>[];
  for (final hotel in hotelsData) {
    final docRef = await hotelsRef.add(hotel);
    hotelIds.add(docRef.id);
    print("Отель добавлен с ID: ${docRef.id}"); // Логирование ID добавленного отеля
  }
  print("Добавление отелей завершено.");
  // 3. Добавляем туры, используя сохраненные ID отелей
 // 3. Добавляем туры, используя сохраненные ID отелей
  print('Начало добавления туров...');
  for (var i = 0; i < toursData.length; i++) {
 final tourData = toursData[i];
  final tour = {...tourData}; // Создаем копию объекта тура 
    print('Обработка тура: $tour');  // Добавьте логирование для проверки данных тура
    try {
      tour['hotel_id'] = hotelIds[i];// Связываем тур с соответствующим отелем
      await toursRef.add(tour);
      print('Тур успешно добавлен.'); 
    } catch (e) {
      print('Ошибка при добавлении тура: $e');
    }
  }
  print('Добавление туров завершено.');
}

// Функция для очистки данных из коллекции "tours"
