import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:travelzone/db_service.dart';

class AddTourScreen extends StatefulWidget {
  const AddTourScreen({Key? key}) : super(key: key);

  @override
  State<AddTourScreen> createState() => _AddTourScreenState();
}

class _AddTourScreenState extends State<AddTourScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _countryController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _durationController = TextEditingController();
  final _priceController = TextEditingController();
  final _hotelNameController = TextEditingController();
  final _hotelLocationController = TextEditingController();
  final _hotelDescriptionController = TextEditingController();
  final _hotelStarRatingController = TextEditingController();
  final _hotelAmenitiesController = TextEditingController();
  final _imagePicker = ImagePicker();
  List<XFile>? _hotelImages = [];
  String? _tourImage;
  List<String> _hotelAmenities = [];

  @override
  void dispose() {
    _nameController.dispose();
    _countryController.dispose();
    _descriptionController.dispose();
    _durationController.dispose();
    _priceController.dispose();
    _hotelNameController.dispose();
    _hotelLocationController.dispose();
    _hotelDescriptionController.dispose();
    _hotelStarRatingController.dispose();
    _hotelAmenitiesController.dispose();
    super.dispose();
  }

  Future<void> _selectHotelImage() async {
    final pickedImages = await _imagePicker.pickMultiImage();
    if (pickedImages != null) {
      setState(() {
        _hotelImages = pickedImages;
      });
    }
  }

  Future<void> _selectTourImage() async {
    final pickedImage = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _tourImage = pickedImage.path;
      });
    }
  }

  Future<void> _addHotelToFirestore(String hotelId) async {
    if (_formKey.currentState!.validate()) {
      // Prepare hotel data
      final hotelData = {
        'name': _hotelNameController.text,
        'description': _hotelDescriptionController.text,
        'location': _hotelLocationController.text,
        'star_rating': int.parse(_hotelStarRatingController.text),
        'amenities': _hotelAmenities,
        'images': _hotelImages != null
            ? await Future.wait(_hotelImages!
                .map((image) => uploadImageToStorage(image.path, 'hotels')) // Изменяем на uploadImageToStorage
                .toList())
            : [],
        'reviews': [],
      };
      // Add hotel data to Firestore
      final dbService = DbService();
      await dbService.addData('hotels', hotelData);
    }
  }

  Future<void> _addTourToFirestore(String hotelId) async {
    if (_formKey.currentState!.validate()) {
      // Prepare tour data
      final tourData = {
        'name': _nameController.text,
        'country': _countryController.text,
        'description': _descriptionController.text,
        'duration': _durationController.text,
        'price': int.parse(_priceController.text),
        'image': _tourImage != null
            ? await uploadImageToStorage(_tourImage!, 'tours') // Изменяем на uploadImageToStorage
            : null,
        'hotel_id': hotelId,
        'start_date': DateTime.now().millisecondsSinceEpoch, // Add start date
        'end_date': DateTime.now()
            .add(Duration(days: int.parse(_durationController.text)))
            .millisecondsSinceEpoch, // Add end date
      };
      
      // Add tour data to Firestore
      final dbService = DbService();
      await dbService.addTour(tourData);
      // Clear the form fields after adding tour
      _nameController.clear();
      _countryController.clear();
      _descriptionController.clear();
      _durationController.clear();
      _priceController.clear();
      _hotelNameController.clear();
      _hotelLocationController.clear();
      _hotelDescriptionController.clear();
      _hotelStarRatingController.clear();
      _hotelAmenitiesController.clear();
      _hotelImages = [];
      _tourImage = null;
      _hotelAmenities = [];
      // Navigate back to the previous screen
      Navigator.pop(context);
    }
  }

  Future<String> uploadImageToStorage(String imagePath, String folder) async {
    final storageRef = FirebaseStorage.instance.ref();
    final imageFile = File(imagePath);
    final uploadTask = storageRef.child('$folder/${imageFile.path.split('/').last}').putFile(imageFile);
    final snapshot = await uploadTask.whenComplete(() => null);
    return await snapshot.ref.getDownloadURL();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Добавить тур'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hotel Section
                const Text(
                  'Информация об отеле',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _hotelNameController,
                  decoration: const InputDecoration(
                    labelText: 'Название отеля',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Пожалуйста, введите название отеля';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _hotelLocationController,
                  decoration: const InputDecoration(
                    labelText: 'Местоположение отеля',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Пожалуйста, введите местоположение отеля';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _hotelDescriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Описание отеля',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Пожалуйста, введите описание отеля';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _hotelStarRatingController,
                  decoration: const InputDecoration(
                    labelText: 'Рейтинг отеля (звезды)',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Пожалуйста, введите рейтинг отеля';
                    }
                    if (int.tryParse(value) == null ||
                        int.parse(value) < 1 ||
                        int.parse(value) > 5) {
                      return 'Рейтинг должен быть от 1 до 5 звезд';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _hotelAmenitiesController,
                  decoration: const InputDecoration(
                    labelText: 'Удобства отеля (через запятую)',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Пожалуйста, введите удобства отеля';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _selectHotelImage,
                  child: const Text('Выбрать изображения отеля'),
                ),
                if (_hotelImages != null)
                  for (var image in _hotelImages!)
                    Image.file(
                      File(image.path),
                      height: 100,
                      width: 100,
                    ),
                // Tour Section
                const SizedBox(height: 32),
                const Text(
                  'Информация о туре',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Название тура',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Пожалуйста, введите название тура';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _countryController,
                  decoration: const InputDecoration(
                    labelText: 'Страна',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Пожалуйста, введите страну';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Описание тура',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Пожалуйста, введите описание тура';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _durationController,
                  decoration: const InputDecoration(
                    labelText: 'Продолжительность (дней)',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Пожалуйста, введите продолжительность тура';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Продолжительность должна быть числом';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _priceController,
                  decoration: const InputDecoration(
                    labelText: 'Цена',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Пожалуйста, введите цену';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Цена должна быть числом';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _selectTourImage,
                  child: const Text('Выбрать изображение тура'),
                ),
                if (_tourImage != null)
                  Image.file(
                    File(_tourImage!),
                    height: 100,
                    width: 100,
                  ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () async {
                    // Add hotel to Firestore first
                    final dbService = DbService();
                    final hotelData = await dbService.addData(
                      'hotels',
                      {
                        'name': _hotelNameController.text,
                        'description': _hotelDescriptionController.text,
                        'location': _hotelLocationController.text,
                        'star_rating': int.parse(_hotelStarRatingController.text),
                        'amenities': _hotelAmenities,
                        'images': _hotelImages != null
                            ? await Future.wait(_hotelImages!
                                .map((image) => uploadImageToStorage(image.path, 'hotels'))
                                .toList())
                            : [],
                        'reviews': [],
                      },
                    );
                    final hotelId = hotelData.id;
                    // Add tour to Firestore with the hotel ID
                    await _addTourToFirestore(hotelId);
                  },
                  child: const Text('Добавить тур'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}