import 'package:flutter/material.dart';
import 'dart:async';
import 'add_custom_food.dart';
import 'recent_food_tab.dart';
import 'frequent_food_tab.dart';
import 'quick_log_page.dart';
import 'package:loginwithfitbit/services/fitbit_service.dart';

class FoodEntryPage extends StatefulWidget {
  final bool isLogOnly;
  final String? mealType;
  final bool showOnlyCustomTab;

  const FoodEntryPage({
    super.key,
    this.isLogOnly = false,
    this.mealType,
    this.showOnlyCustomTab = false,
  });
  @override
  State<FoodEntryPage> createState() => _FoodEntryPageState();
}

class _FoodEntryPageState extends State<FoodEntryPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final FitbitService fitbitService = FitbitService();
  String? _cachedAccessToken;
  List<Map<String, String>> customFoods = [];
  List<Map<String, String>> frequentFoods = [];
  List<Map<String, String>> recentFoods = [];
  List<Map<String, String>> searchResults = [];
  TextEditingController _searchController = TextEditingController();
  bool _showSearch = false;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();

    if (widget.isLogOnly && !widget.showOnlyCustomTab) {
      _tabController = TabController(length: 3, vsync: this);
    }

    _searchController.addListener(() {
      _searchFoods(_searchController.text);
    });

    _fetchCustomFoods();
    _fetchFrequentFoods();
    _fetchRecentFoods();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _fetchCustomFoods() async {
    if (_cachedAccessToken == null) {
      await fitbitService.loadAccessToken();
      _cachedAccessToken = fitbitService.accessToken;
    }
    final foods = await fitbitService.getCustomFoods();
    setState(() {
      customFoods.clear();
      customFoods.addAll(foods.map((food) {
        return {
          'name': food['name']?.toString() ?? '',
          'description': food['description']?.toString() ?? '',
          'calories': food['calories']?.toString() ?? '',
          'foodId': food['foodId']?.toString() ?? '',
          'unitId': food['unitId']?.toString() ?? '',
        };
      }).toList());

      searchResults = customFoods;
    });
  }

  void _fetchFrequentFoods() async {
    if (_cachedAccessToken == null) {
      await fitbitService.loadAccessToken();
      _cachedAccessToken = fitbitService.accessToken;
    }
    final foods = await fitbitService.getFrequentFoodLogs();
    setState(() {
      frequentFoods.clear();
      frequentFoods.addAll(foods.map((food) {
        return {
          'name': food['name']?.toString() ?? '',
          'description': food['description']?.toString() ?? '',
          'calories': food['calories']?.toString() ?? '',
          'foodId': food['foodId']?.toString() ?? '',
          'unitId': food['unit']['id']?.toString() ?? '',
        };
      }).toList());
    });
  }

  void _fetchRecentFoods() async {
    if (_cachedAccessToken == null) {
      await fitbitService.loadAccessToken();
      _cachedAccessToken = fitbitService.accessToken;
    }
    final foods = await fitbitService.getRecentFoodLogs();
    setState(() {
      recentFoods.clear();
      recentFoods.addAll(foods.map((food) {
        return {
          'name': food['name']?.toString() ?? '',
          'description': food['description']?.toString() ?? '',
          'calories': food['calories']?.toString() ?? '',
          'foodId': food['foodId']?.toString() ?? '',
          'unitId': food['unit']['id']?.toString() ?? '',
        };
      }).toList());
    });
  }

  void _searchFoods(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      if (query.isEmpty) {
        setState(() {
          searchResults = customFoods;
        });
      } else {
        if (_cachedAccessToken == null) {
          await fitbitService.loadAccessToken();
          _cachedAccessToken = fitbitService.accessToken;
        }
        final results = await fitbitService.searchFoods(query);
        setState(() {
          searchResults = results;
        });
      }
    });
  }

  Widget _buildFoodList(List<Map<String, String>> foods) {
    return ListView.builder(
      itemCount: foods.length,
      itemBuilder: (context, index) {
        final food = foods[index];
        return GestureDetector(
          onTap: () => _handleFoodTap(food),
          child: Card(
            margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
            child: ListTile(
              contentPadding: const EdgeInsets.all(10),
              title: Text(food['name'] ?? ''),
              subtitle: Text(food['description'] ?? ''),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCustomTab() {
    return Column(
      children: [
        if (_showSearch)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search food...',
                border: OutlineInputBorder(),
              ),
            ),
          ),
        if (widget.showOnlyCustomTab)
          ListTile(
            leading: const Icon(Icons.add, color: Colors.pink),
            title: const Text("ADD CUSTOM FOOD", style: TextStyle(color: Colors.pink)),
            onTap: _addCustomFood,
          ),
        Expanded(
          child: _buildFoodList(searchResults),
        ),
      ],
    );
  }

  Widget _buildFrequentTab() {
    return Column(
      children: [
        if (_showSearch)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search food...',
                border: OutlineInputBorder(),
              ),
            ),
          ),
        Expanded(
          child: _showSearch ? _buildFoodList(searchResults) : _buildFoodList(frequentFoods),
        ),
      ],
    );
  }

  Widget _buildRecentTab() {
    return Column(
      children: [
        if (_showSearch)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search food...',
                border: OutlineInputBorder(),
              ),
            ),
          ),
        Expanded(
          child: _showSearch ? _buildFoodList(searchResults) : _buildFoodList(recentFoods),
        ),
      ],
    );
  }

  void _addCustomFood() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddCustomFood(),
      ),
    );

    if (result == 'created') {
      _fetchCustomFoods();
    }
  }

  void _handleFoodTap(Map<String, dynamic> food) async {
    if (widget.isLogOnly) {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => QuickLogPage(
            mealType: widget.mealType ?? '',
            foodName: food['name'] ?? '',
            calories: (food['calories'] ?? '0').toString(),
            foodId: food['foodId'] ?? '',
            unitId: food['unitId'] ?? '304',
          ),
        ),
      );

      if (result == 'logged') {
        Navigator.pop(context, 'logged');
      }
    } else {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AddCustomFood(
            prefillName: food['name'] ?? '',
            prefillDescription: food['description'] ?? '',
            prefillCalories: (food['calories'] ?? '0').toString(),
            isSearchFood: true,
            foodId: food['foodId'] ?? '',
            unitId: food['unitId'] ?? '304',
            isQuickLog: true,
          ),
        ),
      );

      if (result == 'logged') {
        Navigator.pop(context, 'logged');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final showTabs = widget.isLogOnly && !widget.showOnlyCustomTab;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Expanded(
              child: Text(widget.mealType ?? (widget.isLogOnly ? "Select Food" : "Log Food")),
            ),
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                setState(() {
                  _showSearch = !_showSearch;
                  if (!_showSearch) {
                    _searchController.clear();
                    searchResults = customFoods;
                  }
                });
              },
            ),
          ],
        ),
        bottom: showTabs
            ? TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'FREQUENT'),
            Tab(text: 'RECENT'),
            Tab(text: 'CUSTOM'),
          ],
        )
            : null,
      ),
      body: showTabs
          ? TabBarView(
        controller: _tabController,
        children: [
          _buildFrequentTab(),
          _buildRecentTab(),
          _buildCustomTab(),
        ],
      )
          : _buildCustomTab(),
    );
  }
}
