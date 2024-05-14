import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:travelzone/db_service.dart';
import '../widgets/tour_item.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final DbService _dbService = DbService();
  RangeValues _priceRange = const RangeValues(0, 10000);
  String _countrySearch = "";
  List<String> _suggestedCountries = []; // Список предлагаемых стран
  List<Map<String, dynamic>> _filteredTours = [];
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _loadTours();
  }

  Future<void> _loadTours() async {
    final tours = await _dbService.getTours();
    setState(() {
      _filteredTours = tours;
    });
  }

  void _filterTours() async {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      final tours = await _dbService.getTours();
      setState(() {
        _filteredTours = tours.where((tour) {
          // Проверяем соответствие цене
          final priceMatch =
              tour['price'] >= _priceRange.start && tour['price'] <= _priceRange.end;

          // Проверяем соответствие стране (если поиск по стране активен)
          final countryMatch = _countrySearch.isEmpty ||
              tour['country'].toLowerCase().contains(_countrySearch.toLowerCase());

          return priceMatch && countryMatch;
        }).toList();
      });
    });
  }

  // Функция для поиска стран по введенному тексту
  Future<void> _searchCountries(String query) async {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      // Получение списка стран из базы данных
      final countries = await _dbService.getCountries(); // Предполагается, что DbService имеет метод getCountries()

      // Фильтрация стран по запросу
      final suggestedCountries = countries
      .where((country) => 
          (country['name'] as String).toLowerCase().contains(query.toLowerCase())
      )
      .toList();
  setState(() {
      _suggestedCountries = suggestedCountries.cast<String>();
  });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Поиск Туров'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Поиск по стране
                  TextField(
                    onChanged: (text) {
                      setState(() {
                        _countrySearch = text;
                      });
                      _searchCountries(text);
                      _filterTours();
                    },
                    decoration: InputDecoration(
                      labelText: 'Страна',
                      suffixIcon: _countrySearch.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                setState(() {
                                  _countrySearch = '';
                                  _suggestedCountries = [];
                                });
                                _filterTours();
                              },
                            )
                          : null,
                    ),
                  ),
                  // Список предлагаемых стран
                  if (_suggestedCountries.isNotEmpty)
                    ListView.builder(
                      shrinkWrap: true,
                      itemCount: _suggestedCountries.length,
                      itemBuilder: (context, index) {
                        final country = _suggestedCountries[index];
                        return ListTile(
                          title: Text(country),
                          onTap: () {
                            setState(() {
                              _countrySearch = country;
                              _suggestedCountries = [];
                            });
                            _filterTours();
                          },
                        );
                      },
                    ),

                  // Заголовок для поиска по цене
                  const SizedBox(height: 16),
                  const Text(
                    'Поиск по цене',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Ползунок для выбора диапазона цен
                  RangeSlider(
                    values: _priceRange,
                    min: 0,
                    max: 10000,
                    divisions: 100,
                    labels: RangeLabels(
                      _priceRange.start.round().toString(),
                      _priceRange.end.round().toString(),
                    ),
                    onChanged: (newRange) {
                      setState(() {
                        _priceRange = newRange;
                      });
                      _filterTours();
                    },
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),

            // Отображение результатов поиска
            if (_filteredTours.isNotEmpty)
              ..._filteredTours.map((tour) => TourItem(tourId: tour['id']))
            else
              const Center(child: Text('Туров не найдено')),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _debounce?.cancel(); // Отмена таймера при уничтожении виджета
    super.dispose();
  }
}