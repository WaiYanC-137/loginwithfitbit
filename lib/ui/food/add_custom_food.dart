import 'package:flutter/material.dart';

class AddCustomFood extends StatefulWidget {
  const AddCustomFood({super.key});

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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create food')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
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
                      initialValue: '1',
                      keyboardType: TextInputType.number,
                      onSaved: (value) => servingSize = value ?? '1',
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      initialValue: 'bar',
                      onSaved: (value) => servingUnit = value ?? 'bar',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
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
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    Navigator.pop(context, {
                      'name': foodName,
                      'description': '$brand, $servingSize $servingUnit',
                      'calories': calories,
                    });
                  }
                },
                child: const Text('SAVE CUSTOM FOOD'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
