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
  String? _selectedSnackType; // Stores the selected sub-snack type


  @override
  void initState() {
    super.initState();
    print("Quick Log State....");
    print(widget.unitId);
    _allowedUnitIds = widget.unitId
      .split(',')
      .where((s) => s.trim().isNotEmpty) // safety
      .map((s) => int.parse(s.trim()))
      .toList();
  print(_allowedUnitIds);
  // If you’ll do a lot of “contains” checks, keep a Set as well:
    _allowedIdSet = _allowedUnitIds.toSet();
    _fetchFoodUnit();
    _selectedMeal = widget.mealType.isNotEmpty == true
      ? widget.mealType         // e.g. 'BREAKFAST'
      : 'ANYTIME';    
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

  // Helper method for main meal types (BREAKFAST, LUNCH, DINNER, SNACK)
  Widget _mealOption(String label) {
    String selectedMealType=_selectedMeal.toUpperCase(); // Removed `isMainMeal` as it's not used internally now
    return SizedBox(
      height: 50, // Fixed height for each radio row
      child: Opacity(
        opacity: label == selectedMealType ? 1 : 0.4,
        child: IgnorePointer(
          ignoring: label != selectedMealType,
          child: Row(
            children: [
              Radio<String>(
                value: label,
                groupValue: selectedMealType,
                onChanged: (value) {
                  setState(() {
                    selectedMealType = value!;
                    if (value == 'SNACK') {
                      _selectedSnackType = 'MORNING SNACK'; // Set default when SNACK is chosen
                    } else {
                      _selectedSnackType = null; // Clear snack type if not SNACK
                    }
                  });
                },
              ),
              Expanded( // Expanded works fine INSIDE a Row with bounded width
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // New helper method for snack sub-types (MORNING SNACK, AFTERNOON SNACK, EVENING SNACK)
  Widget _buildSubSnackRadioRow(String label) {
    return SizedBox(
      height: 50, // Fixed height for each snack radio row
          child: Row(
            children: [
              Radio<String>(
                value: label,
                groupValue: _selectedSnackType,
                onChanged: (value) {
                  setState(() {
                    _selectedSnackType = value!;
                  });
                },
              ),
              Expanded( // Expanded works fine INSIDE a Row with bounded width
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
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
             Column(
              children: [
                // Main meal types - each returns a SizedBox with fixed height
                _mealOption('BREAKFAST'),
                _mealOption('LUNCH'),
                _mealOption('DINNER'),
              // Conditional rendering for Snack sub-types
              if (_selectedMeal.toUpperCase() == 'SNACK')
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start, // Align sub-snack radio buttons
                            children: [
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0), // Add padding for text
                                child: Text('Snack', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)), // Display 'Snack' as text
                              ),
                              _buildSubSnackRadioRow('MORNING SNACK'),
                              _buildSubSnackRadioRow('AFTERNOON SNACK'),
                              _buildSubSnackRadioRow('EVENING SNACK'),
                            ],
                          )
                        else
                          // If _selectedMeal is NOT 'SNACK', show the 'SNACK' radio option
                          _mealOption('SNACK'),
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
                          const SnackBar(content: Text('Logged is successful...')),
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
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Logged, add more if needed')));
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
