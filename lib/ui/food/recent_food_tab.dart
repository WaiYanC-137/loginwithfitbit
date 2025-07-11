import 'package:flutter/material.dart';
import 'package:loginwithfitbit/services/fitbit_service.dart';

class RecentFoodTab extends StatefulWidget {
  final Function(Map<String, dynamic>) onFoodTap;

  const RecentFoodTab({Key? key, required this.onFoodTap}) : super(key: key);

  @override
  _RecentFoodTabState createState() => _RecentFoodTabState();
}

class _RecentFoodTabState extends State<RecentFoodTab> {
  final FitbitService fitbitService = FitbitService();
  List<Map<String, dynamic>> foods = [];

  @override
  void initState() {
    super.initState();
    _fetchRecentFoods();
  }

  Future<void> _fetchRecentFoods() async {
    await fitbitService.loadAccessToken();
    final data = await fitbitService.getRecentFoodLogs();
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
