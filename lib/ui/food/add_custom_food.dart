import 'package:flutter/material.dart';
import 'package:loginwithfitbit/services/fitbit_service.dart';
import 'package:intl/intl.dart';

class AddCustomFood extends StatefulWidget {
  final String prefillName;
  final String prefillDescription;
  final String prefillCalories;
  final bool isSearchFood;
  final bool isQuickLog;
  final String foodId;
  final String unitId;

  const AddCustomFood({
    super.key,
    this.prefillName = '',
    this.prefillDescription = '',
    this.prefillCalories = '0',
    this.isSearchFood = false,
    this.isQuickLog = false,
    this.foodId = '',
    this.unitId = '',
  });

  @override
  State<AddCustomFood> createState() => _AddCustomFoodState();
}

class _AddCustomFoodState extends State<AddCustomFood> {
  final _formKey = GlobalKey<FormState>();
  final FitbitService fitbitService = FitbitService(); 
  List<Map<String, String>> _foodUnits = [];
  String? _servingUnitId;  // store the selected id (or name – your choice)
  String foodName = '';
  String brand = '';
  String servingSize = '1';
  String servingUnit = 'bar';
  String calories = '0';
  String caloriesFromFat = '0';
  bool simplifiedView = false;
  String _selectedMeal = 'ANYTIME'; // Default meal type
  DateTime _selectedDate = DateTime.now(); // Default date is the current date
  String? _cachedAccessToken;
   // Define the list of desired unit IDs
  final List<String> _allowedUnitIds = [
    '17', '27', '29', '43', '69', '88', '91', '128', '147', '170', '389',
    '179', '180', '189', '204', '513', '209', '226', '228', '251', '256',
    '279', '301', '304', '311', '319', '339', '400', '364'
  ];


  @override
  void initState() {
    super.initState();
    foodName = widget.prefillName;
    brand = widget.prefillDescription;
    calories = widget.prefillCalories;
    _fetchFoodUnit();
  }

void _fetchFoodUnit() async {
  print("Fetch Food Unit");
    if (_cachedAccessToken == null) {
    await fitbitService.loadAccessToken();
    _cachedAccessToken = fitbitService.accessToken;
  }
  final units = await fitbitService.getFoodUnit();
  setState(() {
    _foodUnits = units
        .map((u) => {
              'id':    u['id']?.toString() ?? '',
              'name':  u['name']?.toString() ?? '',
              'plural': u['plural']?.toString() ?? '',
            })
         .where((u) =>
              u['id']!.isNotEmpty && _allowedUnitIds.contains(u['id'])) // Filter by allowed IDs   
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
      appBar: AppBar(title: const Text('Food Entry')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                initialValue: foodName,
                decoration: const InputDecoration(labelText: 'Food name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a food name';
                  }
                  return null;
                },
                onSaved: (value) => foodName = value ?? '',
              ),
              TextFormField(
                initialValue: brand,
                decoration: const InputDecoration(labelText: 'Brand'),
                onSaved: (value) => brand = value ?? '',
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text("Serving size"),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      initialValue: servingSize,
                      keyboardType: TextInputType.number,
                      onSaved: (value) => servingSize = value ?? '1',
                    ),
                  ),
                  const SizedBox(width: 16),
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
                  )
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: calories,
                decoration: const InputDecoration(labelText: 'Calories'),
                keyboardType: TextInputType.number,
                onSaved: (value) => calories = value ?? '0',
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Calories from fat'),
                keyboardType: TextInputType.number,
                onSaved: (value) => caloriesFromFat = value ?? '0',
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text("Simplified View"),
                value: simplifiedView,
                onChanged: (value) {
                  setState(() {
                    simplifiedView = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink,
                  foregroundColor: Colors.white,
                ),
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    if (widget.isQuickLog && widget.foodId.isNotEmpty && widget.unitId.isNotEmpty) {
                      final fitbitService = FitbitService();
                      await fitbitService.loadAccessToken();

                      final success = await fitbitService.logFood(
                        foodId: widget.foodId,
                        amount: servingSize,
                        unitId: widget.unitId,
                        mealTypeId: _mealTypeToId(_selectedMeal).toString(),
                        date: DateFormat('yyyy-MM-dd').format(_selectedDate),
                      );

                      if (success) {
                        Navigator.pop(context, 'logged');
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Failed to log food')),
                        );
                      }
                    } else {
                      final fitbitService = FitbitService();
                      await fitbitService.loadAccessToken();

                      final success = await fitbitService.createCustomFood(
                        name: foodName,
                        description: '$brand, $servingSize $servingUnit',
                        calories: calories,
                        defaultServingSize: servingSize,
                        defaultFoodMeasurementUnitId:_servingUnitId.toString(),
                        formType: 'DRY',
                      );

                      if (success) {
                        Navigator.pop(context, 'created');
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Failed to create custom food')),
                        );
                      }
                    }
                  }
                },
                child: Text(
                  widget.isQuickLog
                      ? 'Log Food'
                      : widget.isSearchFood
                      ? 'Add Search Food'
                      : 'Save & Create Custom Food',
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
}
