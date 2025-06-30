import 'package:flutter/material.dart';
import 'package:loginwithfitbit/services/fitbit_service.dart';

class FrequentFoodTab extends StatefulWidget {
  final Function(Map<String, dynamic>) onFoodTap;

  const FrequentFoodTab({super.key, required this.onFoodTap});

  @override
  State<FrequentFoodTab> createState() => _FrequentFoodTabState();
}

class _FrequentFoodTabState extends State<FrequentFoodTab> {
  final FitbitService fitbitService = FitbitService();
  List<Map<String, dynamic>> foods = [];

  @override
  void initState() {
    super.initState();
    _fetchFrequentFoods();
  }

  Future<void> _fetchFrequentFoods() async {
    await fitbitService.loadAccessToken();
    final data = await fitbitService.getFrequentFoodLogs();
    setState(() {
      foods = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: foods.length,
      itemBuilder: (context, index) {
        final food = foods[index];
        return ListTile(
          title: Text(food['name'] ?? 'No Name'),
          subtitle: Text('${food['calories'] ?? 0} kcal'),
          onTap: () => widget.onFoodTap(food),
        );
      },
    );
  }
}
