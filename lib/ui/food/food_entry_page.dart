import 'package:flutter/material.dart';
import 'add_custom_food.dart';
import 'recent_food_tab.dart';
import 'frequent_food_tab.dart';
import 'package:loginwithfitbit/services/fitbit_service.dart';

class FoodEntryPage extends StatefulWidget {
  const FoodEntryPage({super.key});

  @override
  State<FoodEntryPage> createState() => _FoodEntryPageState();
}

class _FoodEntryPageState extends State<FoodEntryPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final FitbitService fitbitService = FitbitService();
  List<Map<String, String>> customFoods = [];
  List<Map<String, String>> searchResults = [];
  TextEditingController _searchController = TextEditingController();
  bool _showSearch = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _fetchCustomFoods();
    _searchController.addListener(() {
      if (_searchController.text.isEmpty) {
        setState(() {
          searchResults = customFoods;
        });
      }
    });
  }

  void _fetchCustomFoods() async {
    await fitbitService.loadAccessToken();
    final foods = await fitbitService.getCustomFoods();

    setState(() {
      customFoods.clear();
      customFoods.addAll(foods);
      searchResults = customFoods;
    });
  }

  void _searchFoods(String query) async {
    if (query.isEmpty) {
      setState(() {
        searchResults = customFoods;
      });
    } else {
      await fitbitService.loadAccessToken();
      final results = await fitbitService.searchFoods(query);
      setState(() {
        searchResults = results;
      });
    }
  }

  void _addCustomFood() async {
    final newFood = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddCustomFood(),
      ),
    );

    if (newFood != null && newFood is Map<String, String>) {
      await fitbitService.loadAccessToken();

      bool success = await fitbitService.createCustomFood(
        name: newFood['name'] ?? '',
        description: newFood['description'] ?? '',
        calories: newFood['calories'] ?? '0',
      );

      if (success) {
        print('Custom food created on Fitbit');
        _fetchCustomFoods();
      } else {
        print('Failed to create custom food on Fitbit');
      }
    }
  }

  void _addFoodFromSearch(Map<String, String> food) async {
    final newFood = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddCustomFood(
          prefillName: food['name'] ?? '',
          prefillDescription: food['description'] ?? '',
          prefillCalories: food['calories'] ?? '0',
          isSearchFood: true,  // Indicate that it's a search food
        ),
      ),
    );

    if (newFood != null && newFood is Map<String, String>) {
      await fitbitService.loadAccessToken();

      bool success = await fitbitService.logFood(
        foodId: food['foodId'] ?? '',
        amount: '1',
        unitId: food['unitId'] ?? '304',
      );

      if (success) {
        print('Food logged successfully');
        Navigator.pop(context);  // Close the page after successful logging
      } else {
        print('Failed to log food');
      }
    }
  }

  Widget _buildCustomTab() {
    final List<Map<String, String>> displayedFoods =
    _searchController.text.isEmpty ? customFoods : searchResults;

    return Column(
      children: [
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
                onTap: () => _addFoodFromSearch(food),
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
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Log Food"),
            if (_showSearch)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: TextField(
                    controller: _searchController,
                    onChanged: _searchFoods,
                    autofocus: true,
                    decoration: const InputDecoration(
                      hintText: 'Search...',
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                ),
              )
            else
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: () {
                  setState(() {
                    _showSearch = true;
                  });
                },
              ),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'FREQUENT'),
            Tab(text: 'RECENT'),
            Tab(text: 'CUSTOM'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          const FrequentFoodTab(),
          const RecentFoodTab(),
          _buildCustomTab(),
        ],
      ),
    );
  }
}
