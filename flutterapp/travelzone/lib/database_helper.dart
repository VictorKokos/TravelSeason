import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  DatabaseHelper._internal();

  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'travelzone.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Таблица для избранных туров
    await db.execute('''
        CREATE TABLE favorites (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          tourId TEXT,
          name TEXT,
          imageUrl TEXT,
          description TEXT,
          price REAL,
          startDate INTEGER,
          endDate INTEGER,
          hotelId TEXT
        )
      ''');
    // Таблица для отелей
    await db.execute('''
        CREATE TABLE hotels (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          hotelId TEXT,
          name TEXT,
          description TEXT,
          starRating INTEGER,
          location TEXT
        )
      ''');
    // Таблица для изображений отелей
    await db.execute('''
        CREATE TABLE hotel_images (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          hotelId TEXT,
          imageUrl TEXT
        )
      ''');
    // Таблица для удобств отелей
    await db.execute('''
        CREATE TABLE hotel_amenities (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          hotelId TEXT,
          amenityName TEXT
        )
      ''');
  }

  // 1. Метод для получения всех избранных туров
  Future<List<Map<String, dynamic>>> getAllFavoriteTours() async {
    Database db = await database;
    return await db.query('favorites');
  }

  // 2. Метод для получения информации об отеле, его изображений и удобств
  Future<Map<String, dynamic>> getHotelDetails(String hotelId) async {
    Database db = await database;
    // Получаем информацию об отеле
    List<Map<String, dynamic>> hotelData = await db.query(
      'hotels',
      where: 'hotelId = ?',
      whereArgs: [hotelId],
    );
    // Получаем изображения отеля
    List<Map<String, dynamic>> hotelImages = await db.query(
      'hotel_images',
      where: 'hotelId = ?',
      whereArgs: [hotelId],
    );
    // Получаем удобства отеля
    List<Map<String, dynamic>> hotelAmenities = await db.query(
      'hotel_amenities',
      where: 'hotelId = ?',
      whereArgs: [hotelId],
    );
    // Формируем результат
    Map<String, dynamic> result = {
      'hotel': hotelData.isNotEmpty ? hotelData[0] : null,
      'images': hotelImages,
      'amenities': hotelAmenities,
    };
    return result;
  }

  // 3. Метод для удаления тура из избранного и соответствующего отеля
  Future<void> deleteFavoriteTourAndHotel(String tourId) async {
    Database db = await database;
    // Получаем id отеля из таблицы избранных туров
    List<Map<String, dynamic>> tourData = await db.query(
      'favorites',
      where: 'tourId = ?',
      whereArgs: [tourId],
    );
    String? hotelId = tourData.isNotEmpty ? tourData[0]['hotelId'] : null;
    // Удаляем тур из избранного
    await db.delete(
      'favorites',
      where: 'tourId = ?',
      whereArgs: [tourId],
    );
    // Если найден id отеля, удаляем отель, его изображения и удобства
    if (hotelId != null) {
      await db.delete(
        'hotels',
        where: 'hotelId = ?',
        whereArgs: [hotelId],
      );
      await db.delete(
        'hotel_images',
        where: 'hotelId = ?',
        whereArgs: [hotelId],
      );
      await db.delete(
        'hotel_amenities',
        where: 'hotelId = ?',
        whereArgs: [hotelId],
      );
    }
  }

  // 4. Метод для добавления тура и отеля в избранное
  Future<void> addFavoriteTourAndHotel(
      String tourId, String hotelId) async {
    Database db = await database;
    // Добавляем тур в избранное
    await db.insert('favorites', {
      'tourId': tourId,
      'hotelId': hotelId,
      // ... другие поля тура, которые будут получены позже из Firestore
    });
    // Добавляем отель в таблицу hotels
    await db.insert('hotels', {
      'hotelId': hotelId,
      // ... другие поля отеля, которые будут получены позже из Firestore
    });
    // Добавляем изображения и удобства отеля (информация будет получена позже)
    // ...
  }

  // Метод для обновления информации о туре в избранном
  Future<void> update(String table, Map<String, dynamic> values,
      {String? where, List<dynamic>? whereArgs}) async {
    Database db = await database;
    await db.update(table, values, where: where, whereArgs: whereArgs);
  }

  // Метод для вставки данных в таблицу
  Future<void> insert(String table, Map<String, dynamic> values) async {
    Database db = await database;
    await db.insert(table, values);
  }
}