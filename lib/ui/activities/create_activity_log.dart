import 'package:flutter/material.dart';
import 'package:loginwithfitbit/model/activity.dart';
import 'package:loginwithfitbit/services/fitbit_service.dart';

class CreateActivityLog extends StatefulWidget {
  
  final FitbitService fitbitService;
  final Activity? selectedActivity;
  const CreateActivityLog({
    super.key,
    required this.fitbitService,
    this.selectedActivity,
  });

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
  late Future<List<Activity>> _createActivitiesLog;


  @override
  void initState() {
    super.initState();

  }

  Future<List<Activity>> _insertActivitiesLog() async {
   return _createActivitiesLog = widget.fitbitService.createActivityLog(activityId: activityController.text, manualCalories: manualCaloriesController.text, startTime: startTimeController.text, durationMillis: durationsController.text, date: dateController.text, distance: distanceController.text, distanceUnit: distanceUnitController.text) as Future<List<Activity>>;
   
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
              controller: TextEditingController(text: widget.selectedActivity?.name),
              decoration: InputDecoration(labelText: 'ActivityName'),
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
              onPressed: _insertActivitiesLog,
              child: Text('Create Activity Log'),
            ),
          ],
        ),
      ),
    );
  }
}
