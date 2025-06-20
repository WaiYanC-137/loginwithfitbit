import 'package:flutter/material.dart';
import 'add_custom_food.dart';
import 'package:loginwithfitbit/services/fitbit_service.dart';

class FoodEntryPage extends StatefulWidget {
  const FoodEntryPage({super.key});

  @override
  State<FoodEntryPage> createState() => _FoodEntryPageState();
}

class _FoodEntryPageState extends State<FoodEntryPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<Map<String, String>> customFoods = [];
  final FitbitService fitbitService = FitbitService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _fetchCustomFoods(); // Load when screen initializes
  }

  void _fetchCustomFoods() async {
    await fitbitService.loadAccessToken(); // Load saved token first
    final foods = await fitbitService.getCustomFoods();
    print('Fetched custom foods: $foods');
    setState(() {
      customFoods.clear();
      customFoods.addAll(foods);
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

  Widget _buildCustomTab() {
    return ListView(
      children: [
        ListTile(
          leading: const Icon(Icons.add, color: Colors.pink),
          title: const Text("ADD CUSTOM FOOD", style: TextStyle(color: Colors.pink)),
          onTap: _addCustomFood,
        ),
        ...customFoods.map((food) => ListTile(
          title: Text(food['name'] ?? ''),
          subtitle: Text(food['description'] ?? ''),
        )),
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
          Container(), // TODO: Implement Frequent
          Container(), // TODO: Implement Recent
          _buildCustomTab(),
        ],
      ),
    );
  }
}
