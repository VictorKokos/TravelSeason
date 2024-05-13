import 'package:cloud_firestore/cloud_firestore.dart';

class DbService {
  final _firestore = FirebaseFirestore.instance;

  // Добавление данных в коллекции
  Future<void> addData(String collectionName, Map<String, dynamic> data) {
    return _firestore.collection(collectionName).add(data);
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
    final CollectionReference countriesCollection = _firestore.collection('countries');
    final QuerySnapshot snapshot = await countriesCollection.get();
    final List<Map<String, dynamic>> countriesList = snapshot.docs.map((doc) {
      return {
        'id': doc.id,
        ...doc.data() as Map<String, dynamic>,
      };
    }).toList();
    return countriesList;
  }
}