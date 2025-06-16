import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CreateActivityLog extends StatefulWidget {

final String accessToken;
CreateActivityLog({required this.accessToken,super.key});

  @override
  _CreateActivityLogState createState() => _CreateActivityLogState();
}


class _CreateActivityLogState extends State<CreateActivityLog> {
  final TextEditingController activityController = TextEditingController();
  final TextEditingController manualCaloriesController = TextEditingController();
  final TextEditingController startTimeController = TextEditingController();
  final TextEditingController durationsController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController distanceController = TextEditingController();
  final TextEditingController distanceUnitController = TextEditingController();

  Future<void> updateProfile() async {
    print("Create Activity Log...");
  final response = await http.post(
      Uri.parse('https://api.fitbit.com/1/user/-/activities.json'),
      headers: {
        'Authorization': 'Bearer ${widget.accessToken}',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'activityId': activityController.text,
        'manualCalories': manualCaloriesController.text,
        'startTime':startTimeController.text,
        'durationMillis':durationsController.text,
        'date':dateController.text,
        'distance':distanceController.text,
        'distanceUnit':distanceUnitController.text
      },
    );
    print("Token......");
    print(widget.accessToken);
    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("✅ Activity Create successfully!")));
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("❌ Failed to update: ${response.body}")));
      print("########");
      print(response.body);

    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Activity Log '),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: activityController,
              decoration: InputDecoration(labelText: 'ActivityID'),
            ),
            TextField(
              controller: manualCaloriesController,
              decoration: InputDecoration(labelText: 'Manual Calories'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: startTimeController,
              decoration: InputDecoration(labelText: 'Start Time'),
            ),
            TextField(
              controller: durationsController,
              decoration: InputDecoration(labelText: 'Duration Millis'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: dateController,
              decoration: InputDecoration(labelText: 'Date'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: distanceController,
              decoration: InputDecoration(labelText: 'Distance'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: distanceUnitController,
              decoration: InputDecoration(labelText: 'Distance Unit'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: updateProfile,
              child: Text('Create Activity Log'),
            ),
          ],
        ),
      ),
    );
  }
}
