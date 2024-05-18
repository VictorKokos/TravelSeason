import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:travelzone/db_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:travelzone/database_helper.dart'; // Импортируем DatabaseHelper
import 'dart:io';

class EditTourScreen extends StatefulWidget {
  final String tourId;
  final Map<String, dynamic> tourData;
  final Map<String, dynamic> hotelData;
  final List<dynamic> hotelImages;
  final List<String> amenities;
  final Function updateState; // Функция для обновления состояния родительского виджета

  const EditTourScreen({
    Key? key,
    required this.tourId,
    required this.tourData,
    required this.hotelData,
    required this.hotelImages,
    required this.amenities,
    required this.updateState,
  }) : super(key: key);

  @override
  State<EditTourScreen> createState() => _EditTourScreenState();
}

class _EditTourScreenState extends State<EditTourScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();
  final _countryController = TextEditingController();

  // Дополнительные контроллеры для данных отеля
  final _hotelNameController = TextEditingController();
  final _hotelDescriptionController = TextEditingController();
  final _hotelLocationController = TextEditingController();
  final _starRatingController = TextEditingController();
  final _amenitiesController = TextEditingController();
  final _amenitiesFocusNode = FocusNode();

  List<String> selectedAmenities = []; // Список выбранных удобств
  List<String> updatedHotelImages = []; // Список обновленных изображений
  bool isUpdatingImages = false; // Флаг для индикации обновления изображений
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.tourData['name'];
    _descriptionController.text = widget.tourData['description'];
    _priceController.text = widget.tourData['price'].toString();
    _startDateController.text = DateTime.fromMillisecondsSinceEpoch(
            widget.tourData['start_date'] * 1000)
        .toString();
    _endDateController.text = DateTime.fromMillisecondsSinceEpoch(
            widget.tourData['end_date'] * 1000)
        .toString();
    _countryController.text = widget.tourData['country'];
    // Заполняем поля данных отеля
    _hotelNameController.text = widget.hotelData['name'];
    _hotelDescriptionController.text = widget.hotelData['description'];
    _hotelLocationController.text = widget.hotelData['location'];
    _starRatingController.text = widget.hotelData['starRating'].toString();
    // Преобразуем список удобств в строку
    _amenitiesController.text = widget.amenities.join(', ');
    // Инициализируем список выбранных удобств
    selectedAmenities = widget.amenities;
  }

  // Вызываем функцию updateState родительского виджета для обновления состояния
  void _updateState() {
    widget.updateState();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    _countryController.dispose();
    // Дополнительные контроллеры для данных отеля
    _hotelNameController.dispose();
    _hotelDescriptionController.dispose();
    _hotelLocationController.dispose();
    _starRatingController.dispose();
    _amenitiesController.dispose();
    _amenitiesFocusNode.dispose();
    super.dispose();
  }

  // Функция для выбора изображения из галереи
  Future<void> _getImageFromGallery() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        updatedHotelImages.add(image.path);
        isUpdatingImages = true;
      });
    }
  }

  // Функция для выбора изображения из камеры
  Future<void> _getImageFromCamera() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() {
        updatedHotelImages.add(image.path);
        isUpdatingImages = true;
      });
    }
  }

  // Функция для загрузки изображения в Firebase Storage
  Future<String> _uploadImage(String filePath) async {
    final fileName = filePath.split('/').last;
    final storageRef = FirebaseStorage.instance.ref().child('tours/$fileName');
    await storageRef.putFile(File(filePath));
    final downloadURL = await storageRef.getDownloadURL();
    return downloadURL;
  }

  // Функция для обновления данных тура
  Future<void> _updateTour() async {
    if (_formKey.currentState!.validate()) {
      // Сохраняем изменения локально
      widget.tourData['name'] = _nameController.text;
      widget.tourData['description'] = _descriptionController.text;
      widget.tourData['price'] = double.tryParse(_priceController.text) ?? 0;
      widget.tourData['start_date'] = DateTime.parse(_startDateController.text)
          .millisecondsSinceEpoch
          .toInt() ~/ 1000;
      widget.tourData['end_date'] = DateTime.parse(_endDateController.text)
          .millisecondsSinceEpoch
          .toInt() ~/ 1000;
      widget.tourData['country'] = _countryController.text;

      // Обновляем данные отеля
      widget.hotelData['name'] = _hotelNameController.text;
      widget.hotelData['description'] = _hotelDescriptionController.text;
      widget.hotelData['location'] = _hotelLocationController.text;
      widget.hotelData['starRating'] =
          int.tryParse(_starRatingController.text) ?? 0;
      widget.hotelData['amenities'] = selectedAmenities;

      // Загружаем новые изображения в Firebase Storage
      if (updatedHotelImages.isNotEmpty) {
        for (final image in updatedHotelImages) {
          final downloadURL = await _uploadImage(image);
          widget.hotelImages.add(downloadURL);
        }
      }

      // Обновляем данные в Firestore
      final dbService = DbService();
      await dbService.updateTour(widget.tourId, widget.tourData);
  await dbService.updateHotel(widget.tourData['hotel_id'], widget.hotelData);

      // После успешного обновления переходим на предыдущий экран
      Navigator.pop(context);
    }
  }

  // Функция для добавления нового удобства
  void _addAmenity() {
    final newAmenity = _amenitiesController.text.trim();
    if (newAmenity.isNotEmpty &&
        !selectedAmenities.contains(newAmenity)) {
      setState(() {
        selectedAmenities.add(newAmenity);
        _amenitiesController.clear();
      });
    }
  }

  // Функция для удаления удобства
  void _removeAmenity(String amenity) {
    setState(() {
      selectedAmenities.remove(amenity);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Tour'),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Данные тура
                const Text(
                  'Tour Information',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Tour Name',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter tour name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                  ),
                  maxLines: 4,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter description';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _priceController,
                  decoration: const InputDecoration(
                    labelText: 'Price',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter price';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _startDateController,
                  decoration: const InputDecoration(
                    labelText: 'Start Date',
                  ),
                  readOnly: true,
                  onTap: () async {
                    final DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (pickedDate != null) {
                      setState(() {
                        _startDateController.text = pickedDate.toString();
                      });
                    }
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter start date';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _endDateController,
                  decoration: const InputDecoration(
                    labelText: 'End Date',
                  ),
                  readOnly: true,
                  onTap: () async {
                    final DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (pickedDate != null) {
                      setState(() {
                        _endDateController.text = pickedDate.toString();
                      });
                    }
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter end date';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _countryController,
                  decoration: const InputDecoration(
                    labelText: 'Country',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter country';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),

                // Данные отеля
                const Text(
                  'Hotel Information',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _hotelNameController,
                  decoration: const InputDecoration(
                    labelText: 'Hotel Name',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter hotel name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _hotelDescriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Hotel Description',
                  ),
                  maxLines: 4,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter hotel description';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _hotelLocationController,
                  decoration: const InputDecoration(
                    labelText: 'Hotel Location',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter hotel location';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _starRatingController,
                  decoration: const InputDecoration(
                    labelText: 'Star Rating',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter star rating';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // Удобства отеля
                const Text(
                  'Hotel Amenities',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                // Поле для ввода удобств
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _amenitiesController,
                        focusNode: _amenitiesFocusNode,
                        decoration: const InputDecoration(
                          labelText: 'Add Amenity',
                        ),
                        onFieldSubmitted: (value) {
                          _addAmenity();
                          _amenitiesFocusNode.requestFocus();
                        },
                      ),
                    ),
                    IconButton(
                      onPressed: _addAmenity,
                      icon: const Icon(Icons.add),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Список выбранных удобств
                Wrap(
                  spacing: 8,
                  children: selectedAmenities.map((amenity) {
                    return Chip(
                      label: Text(amenity),
                      onDeleted: () {
                        _removeAmenity(amenity);
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                // Раздел изображений отеля
                const Text(
                  'Hotel Images',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                // Кнопки для выбора изображений
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton(
                      onPressed: _getImageFromGallery,
                      child: const Text('Gallery'),
                    ),
                    ElevatedButton(
                      onPressed: _getImageFromCamera,
                      child: const Text('Camera'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Отображение выбранных изображений
                if (isUpdatingImages)
                  Wrap(
                    spacing: 8,
                    children: updatedHotelImages.map((image) {
                      return Image.file(
                        File(image),
                        height: 100,
                        width: 100,
                        fit: BoxFit.cover,
                      );
                    }).toList(),
                  ),
                const SizedBox(height: 32),
                // Кнопка для сохранения изменений
                ElevatedButton(
                  onPressed: _updateTour,
                  child: const Text('Save Changes'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}