import 'package:flutter/material.dart';
import 'package:loginwithfitbit/services/fitbit_service.dart';
import 'package:intl/intl.dart';

class FoodDetailPage extends StatefulWidget {
  final Map<String, String> food;

  const FoodDetailPage({super.key, required this.food});

  @override
  State<FoodDetailPage> createState() => _FoodDetailPageState();
}

class _FoodDetailPageState extends State<FoodDetailPage> {
  final TextEditingController _amountController = TextEditingController(text: '1');
  final FitbitService fitbitService = FitbitService();
  String _selectedMeal = 'ANYTIME'; // Default meal type
  DateTime _selectedDate = DateTime.now(); // Default date is the current date

  @override
  void initState() {
    super.initState();
    fitbitService.loadAccessToken();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  int _mealTypeToId(String meal) {
    switch (meal.toUpperCase()) {
      case 'BREAKFAST': return 1;
      case 'MORNING SNACK': return 2;
      case 'LUNCH': return 3;
      case 'AFTERNOON SNACK': return 4;
      case 'DINNER': return 5;
      case 'EVENING SNACK': return 6;
      default: return 7; // Default to ANYTIME
    }
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

    final success = await fitbitService.logFood(
      foodId: foodId,
      amount: amount,
      unitId: unitId,
      mealTypeId: _mealTypeToId(_selectedMeal).toString(), // Convert mealType to mealTypeId
      date: DateFormat('yyyy-MM-dd').format(_selectedDate), // Pass the selected date
    );

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Food logged successfully')));
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to log food')));
    }
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
            const Text('Meal & Snacks Time', style: TextStyle(fontSize: 16)),
            Wrap(
              runSpacing: 8,
              spacing: 8,
              children: [
                _mealOption('ANYTIME'),
                _mealOption('MORNING SNACK'),
                _mealOption('BREAKFAST'),
                _mealOption('AFTERNOON SNACK'),
                _mealOption('LUNCH'),
                _mealOption('EVENING SNACK'),
                _mealOption('DINNER'),
              ],
            ),
            SizedBox(height: 20),
            Row(
              children: [
                const Text('Day', style: TextStyle(fontSize: 16)),
                const Spacer(),
                Text(DateFormat('MMM d, yyyy').format(_selectedDate)),
                IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: _pickDate,
                ),
              ],
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: _logFood,
              child: Text('Add to Food Log'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _mealOption(String label) {
    return Expanded(
      child: Row(
        children: [
          Radio<String>(
            value: label,
            groupValue: _selectedMeal,
            onChanged: (value) => setState(() => _selectedMeal = value!),
          ),
          Expanded(child: Text(label, overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }
}
