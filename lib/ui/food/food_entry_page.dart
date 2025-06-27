import 'package:flutter/material.dart';
import 'add_custom_food.dart';
import 'recent_food_tab.dart';
import 'frequent_food_tab.dart';
import 'package:loginwithfitbit/services/fitbit_service.dart';

class FoodEntryPage extends StatefulWidget {
  final bool isLogOnly;

  const FoodEntryPage({super.key, this.isLogOnly = false});

  @override
  State<FoodEntryPage> createState() => _FoodEntryPageState();
}

class _FoodEntryPageState extends State<FoodEntryPage> with SingleTickerProviderStateMixin {
  TabController? _tabController;
  final FitbitService fitbitService = FitbitService();
  List<Map<String, String>> customFoods = [];
  List<Map<String, String>> searchResults = [];
  TextEditingController _searchController = TextEditingController();
  bool _showSearch = false;

  @override
  void initState() {
    super.initState();
    if (!widget.isLogOnly) {
      _tabController = TabController(length: 3, vsync: this);
      _searchController.addListener(() {
        if (_searchController.text.isEmpty) {
          setState(() {
            searchResults = customFoods;
          });
        }
      });
    }
    _fetchCustomFoods();
  }

  void _fetchCustomFoods() async {
    await fitbitService.loadAccessToken();
    final foods = await fitbitService.getCustomFoods();

    setState(() {
      customFoods.clear();
      customFoods.addAll(foods.map((food) {
        return {
          'name': food['name'] ?? '',
          'description': food['description'] ?? '',
        };
      }).toList());

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

  void _addFoodFromSearch(Map<String, String> food) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddCustomFood(
          prefillName: food['name'] ?? '',
          prefillDescription: food['description'] ?? '',
          prefillCalories: food['calories'] ?? '0',
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

  Widget _buildCustomTab() {
    final displayedFoods = _searchController.text.isEmpty ? customFoods : searchResults;

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
        title: widget.isLogOnly
            ? const Text("Custom Food")
            : Row(
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
        bottom: widget.isLogOnly
            ? null
            : TabBar(
          controller: _tabController!,
          tabs: const [
            Tab(text: 'FREQUENT'),
            Tab(text: 'RECENT'),
            Tab(text: 'CUSTOM'),
          ],
        ),
      ),
      body: widget.isLogOnly
          ? _buildCustomTab()
          : TabBarView(
        controller: _tabController!,
        children: [
          const FrequentFoodTab(),
          const RecentFoodTab(),
          _buildCustomTab(),
        ],
      ),
    );
  }
}
