import 'package:flutter/material.dart';
import 'add_custom_food.dart';
import 'recent_food_tab.dart';
import 'frequent_food_tab.dart';
import 'package:loginwithfitbit/services/fitbit_service.dart';
import 'food_detail_page.dart';

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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _fetchCustomFoods(); // Load when screen initializes
  }

  void _fetchCustomFoods() async {
    await fitbitService.loadAccessToken();
    final foods = await fitbitService.searchFoods("");

    final seenNames = <String>{};
    final uniqueFoods = foods.where((food) {
      final name = food['name'] ?? '';
      if (seenNames.contains(name)) {
        return false;
      } else {
        seenNames.add(name);
        return true;
      }
    }).toList();

    setState(() {
      customFoods.clear();
      customFoods.addAll(uniqueFoods);
      searchResults = customFoods;
    });
  }


  void _searchFoods(String query) async {
    await fitbitService.loadAccessToken();  // Ensure access token is loaded before searching
    final foods = await fitbitService.searchFoods(query);  // Perform search

    // Filter to keep only unique food names
    final seenNames = <String>{};
    final uniqueFoods = foods.where((food) {
      final name = food['name'] ?? '';
      if (seenNames.contains(name)) {
        return false;
      } else {
        seenNames.add(name);
        return true;
      }
    }).toList();

    setState(() {
      searchResults = uniqueFoods;  // Update UI with unique results
    });
  }

  void _addCustomFood() async {
    final newFood = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddCustomFood(),
      ),
    );

    if (newFood != null && newFood is Map<String, String>) {
      await fitbitService.loadAccessToken(); // Load saved token again before creating

      bool success = await fitbitService.createCustomFood(
        name: newFood['name'] ?? '',
        description: newFood['description'] ?? '',
        calories: newFood['calories'] ?? '0',

      );

      if (success) {
        print('Custom food created on Fitbit');
      } else {
        print('Failed to create custom food on Fitbit');
      }

      _fetchCustomFoods(); // Refresh list after adding
    }
  }

  // Show Food Details when clicked
  void _showFoodDetails(Map<String, String> food) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FoodDetailPage(food: food),
      ),
    );
  }

  Widget _buildCustomTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: _searchController,
            onChanged: _searchFoods,
            decoration: InputDecoration(
              hintText: 'Search food...',
              border: OutlineInputBorder(),
              prefixIcon: const Icon(Icons.search),
            ),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.add, color: Colors.pink),
          title: const Text("ADD CUSTOM FOOD", style: TextStyle(color: Colors.pink)),
          onTap: _addCustomFood,
        ),
        Expanded(
          child: ListView.builder(
            itemCount: searchResults.length,
            itemBuilder: (context, index) {
              final food = searchResults[index];
              return GestureDetector(
                onTap: () => _showFoodDetails(food),
                child: Card(
                  margin: EdgeInsets.symmetric(vertical: 4, horizontal: 10),
                  child: ListTile(
                    contentPadding: EdgeInsets.all(10),
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
        title: const Text("Log Food"),
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
