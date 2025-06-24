import 'package:flutter/material.dart';
import 'package:loginwithfitbit/services/fitbit_service.dart';

class FoodDetailPage extends StatefulWidget {
  final Map<String, String> food;

  const FoodDetailPage({super.key, required this.food});

  @override
  State<FoodDetailPage> createState() => _FoodDetailPageState();
}

class _FoodDetailPageState extends State<FoodDetailPage> {
  final TextEditingController _amountController = TextEditingController(text: '1');
  final FitbitService fitbitService = FitbitService();

  @override
  void initState() {
    super.initState();
    fitbitService.loadAccessToken();
  }

  Future<void> _logFood() async {
    final amount = _amountController.text.trim();
    final foodId = widget.food['foodId'] ?? '';
    String unitId = widget.food['unitId'] ?? '';

    // Ensure unitId is valid (empty will show an error)
    if (unitId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('No valid unitId for this food')));
      return;
    }

    print("Logging food: foodId=$foodId, amount=$amount, unitId=$unitId");

    // List of unitIds to try
    List<String> unitIds = ['304', '226', '180', '147', '389'];

    for (String unitId in unitIds) {
      print("Trying with unitId: $unitId");
      final response = await fitbitService.logFood(foodId: foodId, amount: amount, unitId: unitId);

      if (response) {
        // If successful, show a success message and exit
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Food logged successfully with unitId $unitId')));
        Navigator.pop(context);
        return;
      } else {
        print("Failed to log food with unitId: $unitId");
      }
    }

    // If none of the unitIds work
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to log food with any of the unitIds')));
  }

  @override
  Widget build(BuildContext context) {
    final food = widget.food;

    return Scaffold(
      appBar: AppBar(title: Text(food['name'] ?? 'Food Detail')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Description: ${food['description'] ?? 'No description'}'),
            SizedBox(height: 20),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Amount (serving size)'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _logFood,
              child: Text('Add to Food Log'),
            ),
          ],
        ),
      ),
    );
  }
}
