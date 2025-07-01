import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:loginwithfitbit/services/fitbit_service.dart';

class QuickLogPage extends StatefulWidget {
  final String mealType;
  final String foodName;
  final String calories;
  final String foodId;
  final String unitId;

  const QuickLogPage({
    super.key,
    required this.mealType,
    required this.foodName,
    required this.calories,
    required this.foodId,
    required this.unitId,
  });

  @override
  State<QuickLogPage> createState() => _QuickLogPageState();
}

class _QuickLogPageState extends State<QuickLogPage> {
  String _selectedMeal = '';
  DateTime _selectedDate = DateTime.now();
  final FitbitService _fitbitService = FitbitService();

  @override
  void initState() {
    super.initState();
    _selectedMeal = widget.mealType;
    _fitbitService.loadAccessToken();
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
      default: return 7; // ANYTIME
    }
  }

  Future<bool> _logFood() async {
    final success = await _fitbitService.logFood(
      foodId: widget.foodId,
      amount: '1',
      unitId: widget.unitId,
      mealTypeId: _mealTypeToId(_selectedMeal).toString(),
      date: DateFormat('yyyy-MM-dd').format(_selectedDate),
    );

    return success;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Food')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Text(widget.foodName, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Text(widget.calories.isNotEmpty ? '${widget.calories} cal' : '', style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 10),
            const Divider(height: 20),
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
            const SizedBox(height: 20),
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
            const SizedBox(height: 30),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () async {
                      final success = await _logFood();
                      if (success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Logged, add more if needed')),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Failed to log food')),
                        );
                      }
                    },
                    child: const Text('LOG & ADD MORE'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.pink),
                    onPressed: () async {
                      final success = await _logFood();
                      if (success) {
                        Navigator.pop(context, 'logged');
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Failed to log food')),
                        );
                      }
                    },
                    child: const Text('LOG THIS'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
