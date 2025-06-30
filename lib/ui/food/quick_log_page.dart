import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class QuickLogPage extends StatefulWidget {
  final String mealType;
  final String foodName;
  final String calories;

  const QuickLogPage({
    super.key,
    required this.mealType,
    required this.foodName,
    required this.calories,
  });

  @override
  State<QuickLogPage> createState() => _QuickLogPageState();
}

class _QuickLogPageState extends State<QuickLogPage> {
  String _selectedMeal = '';
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _selectedMeal = widget.mealType;
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

  Widget _mealOption(String label) {
    return Expanded(
      child: Row(
        children: [
          Radio<String>(
            value: label,
            groupValue: _selectedMeal,
            onChanged: (value) {
              setState(() {
                _selectedMeal = value!;
              });
            },
          ),
          Expanded(child: Text(label, overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add food')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Text(widget.foodName, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Text(widget.calories.isNotEmpty ? '${widget.calories} cal' : '', style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 10),
            Row(
              children: const [
                Text('NUTRITION FACTS', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                Spacer(),
                Text('EDIT CUSTOM FOOD', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
              ],
            ),
            const Divider(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Serving size 1'),
                Text('${widget.calories} cal'),
              ],
            ),
            const SizedBox(height: 20),
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
                    onPressed: () {
                      Navigator.pop(context, 'logged');
                    },
                    child: const Text('LOG & ADD MORE'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.pink),
                    onPressed: () {
                      Navigator.pop(context, 'logged');
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
