import 'package:cloud_firestore/cloud_firestore.dart';

class DbService {
  final _firestore = FirebaseFirestore.instance;

  // Добавление данных в коллекции
  Future addData(String collectionName, Map<String, dynamic> data) {
    return _firestore.collection(collectionName).add(data);
  }

  Future<void> addTour(Map<String, dynamic> tourData) async {
    try {
      await _firestore.collection('tours').add(tourData);
    } catch (e) {
      print('Error adding tour: $e');
      // Handle the error appropriately, e.g., show an error message to the user.
    }
  }

  Future<List<Map<String, dynamic>>> getTours() async {
    // Получаем ссылку на коллекцию "tours"
    final CollectionReference toursCollection = _firestore.collection('tours');
    // Получаем снимок данных из коллекции
    final QuerySnapshot snapshot = await toursCollection.get();
    // Преобразуем данные в список словарей, включая doc.id
    final List<Map<String, dynamic>> toursList = snapshot.docs.map((doc) {
      return {
        'id': doc.id, // Добавляем id к данным тура
        ...doc.data() as Map<String, dynamic>, // ... распаковывает остальные данные
      };
    }).toList();
    // Возвращаем список туров
    return toursList;
  }

  Future<List<Map<String, dynamic>>> getCountries() async {
    final CollectionReference countriesCollection =
        _firestore.collection('countries');
    final QuerySnapshot snapshot = await countriesCollection.get();
    final List<Map<String, dynamic>> countriesList = snapshot.docs.map((doc) {
      return {
        'id': doc.id,
        ...doc.data() as Map<String, dynamic>,
      };
    }).toList();
    return countriesList;
  }

  // Удаление тура и связанного с ним отеля
  Future deleteTour(String tourId) async {
    try {
      // Получаем данные тура по ID
      final DocumentSnapshot tourDoc =
          await _firestore.collection('tours').doc(tourId).get();
      if (tourDoc.exists) {
        // Извлекаем ID отеля из данных тура
        final String hotelId = tourDoc.get('hotel_id');

        // Удаляем тур
        await _firestore.collection('tours').doc(tourId).delete();
        print('Тур с ID: $tourId успешно удален.');

        // Удаляем отель, если он связан с этим туром
        if (hotelId != null) {
          await _firestore.collection('hotels').doc(hotelId).delete();
          print('Отель с ID: $hotelId успешно удален.');
        }
      } else {
        print('Тур с ID: $tourId не найден.');
      }
    } catch (e) {
      print('Ошибка при удалении тура: $e');
    }
  }

  // Получение данных тура по ID
  Future<Map<String, dynamic>?> getTourById(String tourId) async {
    try {
      final DocumentSnapshot tourDoc =
          await _firestore.collection('tours').doc(tourId).get();
      if (tourDoc.exists) {
        return tourDoc.data() as Map<String, dynamic>;
      } else {
        return null;
      }
    } catch (e) {
      print('Ошибка при получении тура: $e');
      return null;
    }
  }

  // Получение данных отеля по ID
  Future<Map<String, dynamic>?> getHotelById(String hotelId) async {
    try {
      final DocumentSnapshot hotelDoc =
          await _firestore.collection('hotels').doc(hotelId).get();
      if (hotelDoc.exists) {
        return hotelDoc.data() as Map<String, dynamic>;
      } else {
        return null;
      }
    } catch (e) {
      print('Ошибка при получении отеля: $e');
      return null;
    }
  }

  // Обновление данных тура
  Future<void> updateTour(String tourId, Map<String, dynamic> tourData) async {
    try {
      await _firestore.collection('tours').doc(tourId).update(tourData);
    } catch (e) {
      print('Ошибка при обновлении тура: $e');
    }
  }

  // Обновление данных отеля
  Future<void> updateHotel(String hotelId, Map<String, dynamic> hotelData) async {
    try {
      await _firestore.collection('hotels').doc(hotelId).update(hotelData);
    } catch (e) {
      print('Ошибка при обновлении отеля: $e');
    }
  }

    Future<void> updateAdminStatus(String userId, bool isAdmin) async {
    try {
      await _firestore.collection('users').doc(userId).update({'isAdmin': isAdmin});
    } catch (e) {
      print('Ошибка при обновлении статуса администратора: $e');
      // Обработайте ошибку, например, покажите сообщение пользователю.
    }
  }
}