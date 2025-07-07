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
  List<Map<String, String>> _foodUnits = [];
  String? _servingUnitId;  // store the selected id (or name – your choice)
  String? _cachedAccessToken;
  late final List<int> _allowedUnitIds;
  late final Set<int> _allowedIdSet;
  late bool   _mealLocked;  


  @override
  void initState() {
    super.initState();
    _allowedUnitIds = widget.unitId
      .split(',')
      .where((s) => s.trim().isNotEmpty) // safety
      .map((s) => int.parse(s.trim()))
      .toList();

  // If you’ll do a lot of “contains” checks, keep a Set as well:
    _allowedIdSet = _allowedUnitIds.toSet();
    _fetchFoodUnit();
    _selectedMeal = widget.mealType.isNotEmpty == true
      ? widget.mealType          // e.g. 'BREAKFAST'
      : 'ANYTIME';    
        _mealLocked  = widget.mealType.isNotEmpty == true;
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
      unitId: _servingUnitId.toString() ,
      mealTypeId: _mealTypeToId(_selectedMeal).toString(),
      date: DateFormat('yyyy-MM-dd').format(_selectedDate),
    );
    return success;
  }

Widget _mealOption(String label) {
  final bool disabled = _mealLocked;   // lock all radios once preset

  return Expanded(
    child: Opacity(                     // grey‑out if locked & not selected
      opacity: disabled && label != _selectedMeal ? 0.4 : 1,
      child: IgnorePointer(             // ignore taps when locked
        ignoring: disabled,
        child: Row(
          children: [
            Radio<String>(
              value: label,
              groupValue: _selectedMeal,
              onChanged: (value) =>
                  setState(() => _selectedMeal = value!), // only runs if unlocked
            ),
            Expanded(child: Text(label, overflow: TextOverflow.ellipsis)),
          ],
        ),
      ),
    ),
  );
}
  void _fetchFoodUnit() async {
    if (_cachedAccessToken == null) {
    await _fitbitService.loadAccessToken();
    _cachedAccessToken = _fitbitService.accessToken;
  }
  final units = await _fitbitService.getFoodUnit();
  setState(() {
    _foodUnits = units
        .map((u) => {
              'id':    u['id']?.toString() ?? '',
              'name':  u['name']?.toString() ?? '',
              'plural': u['plural']?.toString() ?? '',
            })
         .where((u) =>
              u['id']!.isNotEmpty && _allowedIdSet.contains(int.parse(u['id']!))) // Filter by allowed IDs   
        .toList();
 
       // Sort the list by 'name' in ascending order
      _foodUnits.sort((a, b) => (a['name'] ?? '').compareTo(b['name'] ?? ''));
    // pick a sensible default once the list arrives
    if (_foodUnits.isNotEmpty && _servingUnitId == null) {
      _servingUnitId = _foodUnits.first['id'];
    }
  });
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
             Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _servingUnitId,
                      isExpanded: true,                    // keeps long names from ellipsising
                      decoration: const InputDecoration(
                        labelText: 'Serving unit',
                        border: OutlineInputBorder(),
                      ),

                      // ─── handle changes ────────────────────────────────────────────────
                      onChanged: (String? newValue) {
                        setState(() => _servingUnitId = newValue);
                      },
                      onSaved:   (String? value) => _servingUnitId = value,

                      // ─── build items from the list you fetched ────────────────────────
                      items: _foodUnits.map((unit) {
                        final id   = unit['id']!;
                        final name = unit['plural']?.isNotEmpty == true
                            ? unit['plural']!
                            : unit['name']!;               // show plural if you have it
                        return DropdownMenuItem<String>(
                          value: id,                       // what gets written to _servingUnitId
                          child: Text(name),
                        );
                      }).toList(),
                    ),
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
