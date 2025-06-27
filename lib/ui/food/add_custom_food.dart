import 'package:flutter/material.dart';
import 'package:loginwithfitbit/services/fitbit_service.dart';

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

  String foodName = '';
  String brand = '';
  String servingSize = '1';
  String servingUnit = 'bar';
  String calories = '0';
  String caloriesFromFat = '0';
  bool simplifiedView = false;

  @override
  void initState() {
    super.initState();
    foodName = widget.prefillName;
    brand = widget.prefillDescription;
    calories = widget.prefillCalories;
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
                    child: TextFormField(
                      initialValue: servingUnit,
                      onSaved: (value) => servingUnit = value ?? 'bar',
                    ),
                  ),
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
                        defaultFoodMeasurementUnitId: '304',
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
}