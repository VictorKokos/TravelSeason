import 'package:cloud_firestore/cloud_firestore.dart';

class DbService {
  final _firestore = FirebaseFirestore.instance;

  // Добавление данных в коллекции
  Future<void> addData(String collectionName, Map<String, dynamic> data) {
    return _firestore.collection(collectionName).add(data);
  }

}