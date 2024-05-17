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
  List<String> _suggestedCountries = [];
  Stream<QuerySnapshot>? _filteredToursStream;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _filteredToursStream = FirebaseFirestore.instance.collection('tours').snapshots();
  }

  void _filterTours() {
    Query<Map<String, dynamic>> query = FirebaseFirestore.instance.collection('tours');

    // Фильтруем по стране, если введена
    if (_countrySearch.isNotEmpty) {
      query = query.where('country', isEqualTo: _countrySearch);
    }

    // Фильтруем по цене
    query = query
        .where('price', isGreaterThanOrEqualTo: _priceRange.start)
        .where('price', isLessThanOrEqualTo: _priceRange.end);

    setState(() {
      _filteredToursStream = query.snapshots();
    });
  }

  Future<void> _searchCountries(String query) async {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      final countries = await _dbService.getCountries();
      final suggestedCountries = countries
          .where((country) =>
              (country['name'] as String)
                  .toLowerCase()
                  .contains(query.toLowerCase()))
          .map((country) => country['name'] as String)
          .toList();
      setState(() {
        _suggestedCountries = suggestedCountries;
      });
    });
  }

  // Функция для сброса фильтров
  void _resetFilters() {
    setState(() {
      _countrySearch = "";
      _priceRange = const RangeValues(0, 10000);
      _suggestedCountries = [];
      _filteredToursStream = FirebaseFirestore.instance.collection('tours').snapshots();
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

                  // Кнопка сброса фильтров
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _resetFilters,
                    child: const Text('Сбросить фильтры'),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),

            // Отображение результатов поиска
            if (_filteredToursStream != null)
              StreamBuilder<QuerySnapshot>(
                stream: _filteredToursStream,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text('Ошибка: ${snapshot.error}'));
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final tours = snapshot.data!.docs;
                  return ListView.builder(
                    itemCount: tours.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      final tour = tours[index].data() as Map<String, dynamic>;
                      return TourItem(tourId: tours[index].id);
                    },
                  );
                },
              )
            else
              const Center(child: Text('Туров не найдено')),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}