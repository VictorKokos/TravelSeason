import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
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
  // ... (может быть добавлена переменная для изображения)

  @override
  void dispose() {
    _nameController.dispose();
    _countryController.dispose();
    _descriptionController.dispose();
    _durationController.dispose();
    _priceController.dispose();
    // ... (освобождение ресурсов для изображения)
    super.dispose();
  }

  Future<void> _addTour() async {
    if (_formKey.currentState!.validate()) {
      final dbService = DbService();

      // Создание данных для нового тура
      final tourData = {
        'name': _nameController.text,
        'country': _countryController.text,
        'description': _descriptionController.text,
        'duration': _durationController.text,
        'price': int.parse(_priceController.text),
        // ... (добавление изображения)
      };

      await dbService.addTour(tourData);

      // Переход на предыдущий экран
      Navigator.pop(context);
    }
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
          child: Column(
            children: [
              // Поля ввода для данных тура
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
              // ... (другие поля ввода)
              ElevatedButton(
                onPressed: _addTour,
                child: const Text('Добавить'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}