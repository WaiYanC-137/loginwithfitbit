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

class _FoodEntryPageState extends State<FoodEntryPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final FitbitService fitbitService = FitbitService();
  String? _cachedAccessToken;
  List<Map<String, String>> customFoods = [];
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
          'name': food['name'] ?? '',
          'description': food['description'] ?? '',
          'calories': food['calories'] ?? '',
          'foodId': food['foodId'] ?? '',
          'unitId': food['unitId'] ?? '',
        };
      }).toList());

      searchResults = customFoods;
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
          ),
        ),
      );

      if (result == 'logged') {
        Navigator.pop(context);
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
        Navigator.pop(context);
      }
    }
  }

  Widget _buildCustomTab() {
    final displayedFoods = _searchController.text.isEmpty ? customFoods : searchResults;

    return Column(
      children: [
        if (widget.showOnlyCustomTab)
          ListTile(
            leading: const Icon(Icons.add, color: Colors.pink),
            title: const Text("ADD CUSTOM FOOD", style: TextStyle(color: Colors.pink)),
            onTap: _addCustomFood,
          ),
        Expanded(
          child: ListView.builder(
            itemCount: displayedFoods.length,
            itemBuilder: (context, index) {
              final food = displayedFoods[index];
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
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final showTabs = widget.isLogOnly && !widget.showOnlyCustomTab;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.mealType ?? (widget.isLogOnly ? "Select Food" : "Log Food")),
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
          FrequentFoodTab(onFoodTap: _handleFoodTap),
          RecentFoodTab(onFoodTap: _handleFoodTap),
          _buildCustomTab(),
        ],
      )
          : _buildCustomTab(),
    );
  }
}
