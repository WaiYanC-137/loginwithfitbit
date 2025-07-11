import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import for date and time formatting
import 'package:loginwithfitbit/model/activity.dart'; // Ensure this path is correct
import 'package:loginwithfitbit/services/fitbit_service.dart';
import 'package:loginwithfitbit/ui/profile_page.dart';

class CreateActivityLog extends StatefulWidget {
  final FitbitService fitbitService;
  final Activity? selectedActivity; // Nullable as it might not always be pre-selected

  const CreateActivityLog({
    super.key,
    required this.fitbitService,
    this.selectedActivity,
  });

  @override
  _CreateActivityLogState createState() => _CreateActivityLogState();
}

class _CreateActivityLogState extends State<CreateActivityLog> {
  // Use late final for controllers and initialize in initState for better control
  late final TextEditingController _activityNameController;
  late final TextEditingController _manualCaloriesController;
  late final TextEditingController _startTimeController;
  late final TextEditingController _durationMillisController;
  late final TextEditingController _dateController;
  late final TextEditingController _distanceController;
  late Future<Activity> _createActivitiesLog;
  // Track loading state
  bool _isLoading = false;
  // Use DateTime objects to store selected date and time for easier manipulation
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  @override
  void initState() {
    super.initState();

    // Initialize controllers with initial values, especially if editing an existing log
    _activityNameController = TextEditingController(text: widget.selectedActivity!.name);
    _manualCaloriesController = TextEditingController(text: widget.selectedActivity!.calories.toString()); // Start empty for new log
    _durationMillisController = TextEditingController(text: widget.selectedActivity!.duration.toString());
    _distanceController = TextEditingController(text: widget.selectedActivity!.distance.toString());

    // Initialize date and time controllers with current values or default
    _selectedDate = DateTime.now();
    _dateController = TextEditingController(text: DateFormat('yyyy-MM-dd').format(_selectedDate!));

    _selectedTime = TimeOfDay.now();
    _startTimeController = TextEditingController(text: DateFormat('HH:mm').format(DateTime(2023, 1, 1, _selectedTime!.hour, _selectedTime!.minute))); // Dummy date for TimeOfDay
  }

  @override
  void dispose() {
    _activityNameController.dispose();
    _manualCaloriesController.dispose();
    _startTimeController.dispose();
    _durationMillisController.dispose();
    _dateController.dispose();
    _distanceController.dispose();
    super.dispose();
  }

  // --- Date Picker ---
  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)), // Allow selecting a year into the future
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = DateFormat('yyyy-MM-dd').format(_selectedDate!);
      });
    }
  }

  // --- Time Picker ---
  Future<void> _pickTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
        // Format TimeOfDay to HH:mm string
        _startTimeController.text = DateFormat('HH:mm').format(DateTime(2023, 1, 1, _selectedTime!.hour, _selectedTime!.minute));
      });
    }
  }


  Future<List?> _createAndLogActivity() async {
    // Basic validation
    if (widget.selectedActivity?.activityTypeId == null || _manualCaloriesController.text.isEmpty ||
        _startTimeController.text.isEmpty || _durationMillisController.text.isEmpty ||
        _dateController.text.isEmpty || _distanceController.text.isEmpty ) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all required fields.'),
          backgroundColor: Colors.red,
        ),
      );
      return null ;
    }

    setState(() {
      _isLoading = true; // Show loading indicator
    });
    try {
      // Await the API call (this is VERY important!)
      final createdActivity = await widget.fitbitService.createActivityLog(
        activityId: widget.selectedActivity!.activityTypeId.toString(),
        manualCalories: _manualCaloriesController.text,
        startTime: _startTimeController.text,
        durationMillis: _durationMillisController.text,
        date: _dateController.text,
        distance: _distanceController.text
      );

      // Handle null (or failed creation)
      if (createdActivity == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to create activity log. Please try again.'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
        return[];
      }

      // ✅ Success: show success snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Activity log created successfully!'),
          backgroundColor: Color.fromARGB(255, 24, 158, 67),
          duration: Duration(seconds: 2),
        ),
      );

      _clearFields(); // Clear form

      // ✅ Navigate to ProfilePage
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ProfilePage(
            fitbitService: widget.fitbitService,
          ),
        ),
      );
    } catch (e) {
      // ❌ Handle and show error
      String errorMessage = 'Something went wrong.';
      
      if (e is SocketException) {
        errorMessage = 'No internet connection.';
      } else if (e is FormatException) {
        errorMessage = 'Invalid response format from server.';
      } else if (e is HttpException) {
        errorMessage = 'Server error: ${e.message}';
      } else {
        errorMessage = e.toString(); // fallback
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $errorMessage'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );

      print('Error creating activity log: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _clearFields() {
    // Keep activityName if it was pre-selected, otherwise clear
    if (widget.selectedActivity == null) {
      _activityNameController.clear();
    }
    _manualCaloriesController.clear();
    _durationMillisController.clear();
    _distanceController.clear();
    // Reset date/time to current
    _selectedDate = DateTime.now();
    _dateController.text = DateFormat('yyyy-MM-dd').format(_selectedDate!);
    _selectedTime = TimeOfDay.now();
    _startTimeController.text = DateFormat('HH:mm').format(DateTime(2023, 1, 1, _selectedTime!.hour, _selectedTime!.minute));
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Activity Log'),
        backgroundColor: Colors.deepPurple, // A nice AppBar color
        foregroundColor: Colors.white, // Text color for AppBar title
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator()) // Show loading spinner
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20.0), // Increased padding
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch, // Stretch children horizontally
                children: [
                  const SizedBox(height: 10),
                  // Activity Name (read-only if selected, otherwise allow input)
                  TextField(
                    controller: _activityNameController,
                    readOnly: widget.selectedActivity != null, // Make read-only if activity is selected
                    decoration: InputDecoration(
                      labelText: 'Activity Name',
                      hintText: 'e.g., Running, Cycling',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      prefixIcon: const Icon(Icons.fitness_center),
                    ),
                  ),
                  const SizedBox(height: 15),

                  // Manual Calories
                  TextField(
                    controller: _manualCaloriesController,
                    decoration: InputDecoration(
                      labelText: 'Energy Burned Calories (kcal)',
                      hintText: 'e.g., 500',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      prefixIcon: const Icon(Icons.local_fire_department),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 15),

                  // Start Time (using DatePicker)
                  TextField(
                    controller: _startTimeController,
                    readOnly: true, // Make it read-only as we use a picker
                    onTap: _pickTime, // Open time picker on tap
                    decoration: InputDecoration(
                      labelText: 'Start Time (HH:mm)',
                      hintText: 'Select time',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      prefixIcon: const Icon(Icons.access_time),
                      suffixIcon: const Icon(Icons.calendar_today), // Calendar icon for picker
                    ),
                  ),
                  const SizedBox(height: 15),

                  // Duration Millis
                  TextField(
                    controller: _durationMillisController,
                    decoration: InputDecoration(
                      labelText: 'Duration (milliseconds)',
                      hintText: 'e.g., 3600000 (for 1 hour)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      prefixIcon: const Icon(Icons.timer),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 15),

                  // Date (using DatePicker)
                  TextField(
                    controller: _dateController,
                    readOnly: true, // Make it read-only as we use a picker
                    onTap: _pickDate, // Open date picker on tap
                    decoration: InputDecoration(
                      labelText: 'Date (YYYY-MM-DD)',
                      hintText: 'Select date',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      prefixIcon: const Icon(Icons.calendar_month),
                      suffixIcon: const Icon(Icons.calendar_today), // Calendar icon for picker
                    ),
                  ),
                  const SizedBox(height: 15),

                  // Distance
                  TextField(
                    controller: _distanceController,
                    decoration: InputDecoration(
                      labelText: 'Distance',
                      hintText: 'e.g., 5.0',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      prefixIcon: const Icon(Icons.directions_run),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 15),
                  // ElevatedButton
                  ElevatedButton.icon(
                    onPressed: _createAndLogActivity,
                    icon: const Icon(Icons.add_task),
                    label: const Text('Create Activity Log'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple, // Button color
                      foregroundColor: Colors.white, // Text color
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}