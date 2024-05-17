import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:http/http.dart' as http;

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
          tourId TEXT PRIMARY KEY,
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
          hotelId TEXT PRIMARY KEY,
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

  Stream<List<Map<String, dynamic>>> getFavoriteToursStream() {
    return Stream.periodic(Duration(seconds: 1), (_) async {
      return await getAllFavoriteTours();
    }).asyncMap((event) => event);
  }

  Future<void> deleteFavorite(String tourId, String hotelId) async {
    final db = await database;

    // Удаляем тур из таблицы favorites
    await db.delete('favorites', where: 'tourId = ?', whereArgs: [tourId]);

    // Удаляем отель, изображения и удобства, если нужно
    await db.delete('hotels', where: 'hotelId = ?', whereArgs: [hotelId]);
    await db.delete('hotel_images', where: 'hotelId = ?', whereArgs: [hotelId]);
    await db.delete('hotel_amenities', where: 'hotelId = ?', whereArgs: [hotelId]);
  }

  // 1. Метод для получения всех избранных туров
  Future<List<Map<String, dynamic>>> getAllFavoriteTours() async {
    Database db = await database;
    final tours = await db.query('favorites');

    // Получаем список всех изображений отелей
    final hotelImages = await db.query('hotel_images');

    // Соединяем данные о турах и изображениях
    final combinedData = tours.map((tour) {
      final hotelId = tour['hotelId'];
      final hotelImagesForTour = hotelImages
          .where((image) => image['hotelId'] == hotelId)
          .toList();

      // Собираем полный путь к изображению
      final imagePath = hotelImagesForTour.isNotEmpty
          ? hotelImagesForTour.first['imageUrl']
          : ''; 

      return {
        ...tour,
        'imageUrl': imagePath, // Сохраняем полный путь в структуру данных тура
      };
    }).toList();

    return combinedData;
  }

  // 4. Метод для вставки изображения отеля
  Future<void> insertHotelImage(String hotelId, String imageUrl) async {
    Database db = await database;
    await db.insert('hotel_images', {
      'hotelId': hotelId,
      'imageUrl': imageUrl,
    });
  }

  // 5. Метод для вставки удобств отеля
  Future<void> insertHotelAmenities(
      String hotelId, List<dynamic> amenities) async {
    Database db = await database;
    for (final amenity in amenities) {
      await db.insert('hotel_amenities', {
        'hotelId': hotelId,
        'amenityName': amenity,
      });
    }
  }

  Future<void> addToFavorites(
      String tourId, // ID документа тура
      String hotelId, // ID документа отеля
      Map<String, dynamic> tourData,
      Map<String, dynamic> hotelData,
      List<dynamic> hotelImages) async {
    Database db = await database;


    // Проверка, есть ли уже этот тур в избранном
    final existingTour = await db.query('favorites',
        where: 'tourId = ?', whereArgs: [tourId]);

    if (existingTour.isEmpty) {
      // 1. Сохраняем тур в таблицу favorites
      await db.insert('favorites', {
        'tourId': tourId, // Используем переданный tourId
        'name': tourData['name'],
        'imageUrl': tourData['imageUrl'],
        'description': tourData['description'],
        'price': tourData['price'],
        'startDate': tourData['startDate'],
        'endDate': tourData['endDate'],
        'hotelId': hotelId, // Используем переданный hotelId
      });

      // 2. Сохраняем отель в таблицу hotels (только если его нет)
      final existingHotel = await db.query('hotels',
          where: 'hotelId = ?', whereArgs: [hotelId]);
      if (existingHotel.isEmpty) {
        await db.insert('hotels', {
          'hotelId': hotelId,
          'name': hotelData['name'],
          'description': hotelData['description'],
          'starRating': hotelData['starRating'],
          'location': hotelData['location'],
        });

        // 3. Сохраняем изображения отеля в таблицу hotel_images
        for (var imageUrl in hotelImages) {
          // Скачиваем и сохраняем изображение локально
          final imagePath = await _downloadAndSaveImage(imageUrl, hotelId);
          await db.insert('hotel_images', {
            'hotelId': hotelData['hotelId'],
            'imageUrl': imagePath,
          });
        }

        // 4. Сохраняем удобства отеля в таблицу hotel_amenities
        for (var amenity in hotelData['amenities']) {
          await db.insert('hotel_amenities', {
            'hotelId': hotelData['hotelId'],
            'amenityName': amenity,
          });
        }
      }

      // 5. Проверяем, есть ли что-то в избранном
      int? count =
          Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM favorites'));

      if (count! > 0) {
        // Избранное не пустое, можно выполнить какие-то действия
        print('В избранном есть элементы');
      } else {
        // Избранное пустое, можно выполнить какие-то другие действия
        print('Избранное пустое');
      }
    } else {
      print('Этот тур уже в избранном');
    }
  }

  // Метод для скачивания и сохранения изображений
  Future<String> _downloadAndSaveImage(String imageUrl, String hotelId) async {
    final response = await http.get(Uri.parse(imageUrl));
    final documentDirectory = await getApplicationDocumentsDirectory();
    final imageName = imageUrl.split('/').last;
    final filePath = '${documentDirectory.path}/$hotelId/$imageName';

    // Создаем папку для отеля, если она не существует
    final hotelDirectory = Directory('${documentDirectory.path}/$hotelId');
    if (!await hotelDirectory.exists()) {
      await hotelDirectory.create();
    }
print('Image downloaded: $filePath');
    final file = File(filePath);
    await file.writeAsBytes(response.bodyBytes);

    return filePath; // Возвращаем локальный путь к изображению
  }

  Future<void> clearAllTables() async {
    final db = await DatabaseHelper().database;

    await db.delete('favorites');
    await db.delete('hotels');
    await db.delete('hotel_images');
    await db.delete('hotel_amenities');

    print('Все таблицы очищены!');
  }
}