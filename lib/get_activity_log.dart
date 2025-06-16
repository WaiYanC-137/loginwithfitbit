import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// Main widget for fetching and displaying Fitbit activity logs
class GetActivityLog extends StatefulWidget {
  final String accessToken;

  // Constructor requires an accessToken to authenticate with Fitbit API
  GetActivityLog({required this.accessToken, super.key});

  @override
  _GetActivityLogState createState() => _GetActivityLogState();
}

class _GetActivityLogState extends State<GetActivityLog> {
  // Text editing controllers for user input parameters
  final TextEditingController afterDateController = TextEditingController();
  final TextEditingController sortController = TextEditingController();
  final TextEditingController offSetController = TextEditingController();
  final TextEditingController limitController = TextEditingController();

  // State variables to manage UI updates
  List<dynamic> _activities = []; // Stores the fetched activity data
  bool _isLoading = false; // Indicates if data is currently being fetched
  String? _errorMessage; // Stores error messages if API call fails

  @override
  void dispose() {
    // Dispose controllers to prevent memory leaks
    afterDateController.dispose();
    sortController.dispose();
    offSetController.dispose();
    limitController.dispose();
    super.dispose();
  }

  // Function to fetch activity log data from Fitbit API
  Future<void> fetchActivityLog() async {
    print("Fetch Activity Log..");
    // Set loading state to true and clear previous errors and activities
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _activities = []; // Clear previous data
    });

    // Construct query parameters from text controllers
    final Map<String, String> queryParameters = {
      'afterDate': afterDateController.text.isNotEmpty ? afterDateController.text : '2024-01-01', // Provide default if empty
      'sort': sortController.text.isNotEmpty ? sortController.text : 'asc', // Provide default if empty
      'offset': offSetController.text.isNotEmpty ? offSetController.text : '0', // Provide default if empty
      'limit': limitController.text.isNotEmpty ? limitController.text : '5', // Provide default if empty
    };

    // Build the URI for the Fitbit API endpoint
    final Uri uri = Uri.https(
      'api.fitbit.com',
      '/1/user/-/activities/list.json',
      queryParameters,
    );

    try {
      // Make the HTTP GET request
      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer ${widget.accessToken}',
          // 'Content-Type': 'application/x-www-form-urlencoded', // Generally not needed for GET
        },
      );

      // Check the response status code
      if (response.statusCode == 200) {
        // Parse the JSON response
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      
        // Check if the 'activities' key exists and is a list
        if (jsonResponse.containsKey('activities') && jsonResponse['activities'] is List) {
          setState(() {
            _activities = jsonResponse['activities']; // Update activities list
            _isLoading = false; // Stop loading
          });
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("✅ Get Activity Log successfully!")),
          );
        } else {
          // Handle unexpected JSON structure
          setState(() {
            _errorMessage = 'Invalid response format: Missing "activities" list.';
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("❌ Error: $_errorMessage")),
          );
        }
        print("Activity...");
        print(_activities);
      } else {
        // Handle API errors (non-200 status codes)
        setState(() {
          _errorMessage = 'Failed to load activity log: ${response.statusCode} - ${response.body}';
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("❌ Failed to Load Activity Log: ${response.body}")),
        );
      }
    } catch (e) {
      // Handle network or parsing exceptions
      setState(() {
        _errorMessage = 'An error occurred: $e';
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Error fetching data: $e")),
      );
    }
  }
  
  // Function to delete an activity by its log ID
  Future<void> deleteActivity(String activityId) async {
    setState(() {
      _isLoading = true; // Show loading indicator during deletion
      _errorMessage = null; // Clear any previous error messages
    });

    // Build the URI for the Fitbit API delete endpoint
    // This correctly constructs: https://api.fitbit.com/1/user/-/activities/{activity-id}.json
    final Uri uri = Uri.https(
      'api.fitbit.com',
      '/1/user/-/activities/$activityId.json', // The activityId is interpolated directly into the path
    );

    try {
      // Make the HTTP DELETE request
      final response = await http.delete(
        uri, // The correctly formed URI
        headers: {
          'Authorization': 'Bearer ${widget.accessToken}', // Your access token for authorization
        },
      );

      if (response.statusCode == 200) { // 204 No Content is a common success code for DELETE
        setState(() {
          // Remove the deleted activity from the list to update UI
          _activities.removeWhere((activity) => activity['logId'].toString() == activityId);
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ Activity deleted successfully!")),
        );
      } else {
        setState(() {
          _errorMessage = 'Failed to delete activity: ${response.statusCode} - ${response.body}';
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("❌ Failed to delete activity: ${response.body}")),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'An error occurred during deletion: $e';
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Error deleting data: $e")),
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fitbit Activity Log'),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Input fields for query parameters
            TextField(
              controller: afterDateController,
              decoration: const InputDecoration(
                labelText: 'After Date (YYYY-MM-DD)',
                hintText: 'e.g., 2024-01-01',
                border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
                prefixIcon: Icon(Icons.calendar_today),
              ),
              keyboardType: TextInputType.datetime,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: sortController,
              decoration: const InputDecoration(
                labelText: 'Sort (asc/desc)',
                hintText: 'e.g., asc',
                border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
                prefixIcon: Icon(Icons.sort),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: offSetController,
              decoration: const InputDecoration(
                labelText: 'Offset',
                hintText: 'e.g., 0',
                border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
                prefixIcon: Icon(Icons.numbers),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: limitController,
              decoration: const InputDecoration(
                labelText: 'Limit',
                hintText: 'e.g., 5',
                border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
                prefixIcon: Icon(Icons.format_list_numbered),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            // Button to trigger the API call
            ElevatedButton.icon(
              onPressed: fetchActivityLog,
              icon: const Icon(Icons.refresh),
              label: const Text('Get Activity Log'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 5,
              ),
            ),
            const SizedBox(height: 20),

            // Display loading indicator, error message, or activity list
            _isLoading
                ? const CircularProgressIndicator() // Show loading spinner
                : _errorMessage != null
                    ? Text(
                        _errorMessage!, // Show error message
                        style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      )
                    : _activities.isEmpty
                        ? const Text(
                            'No activities found or fetch not initiated. Enter parameters and click "Get Activity Log".',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
                          )
                        : Expanded(
                            // Display fetched activities in a ListView
                            child: ListView.builder(
                            shrinkWrap: true, // <--- IMPORTANT: Allows ListView to take only as much space as its children
                            physics: const NeverScrollableScrollPhysics(), // <--- IMPORTANT: Prevents ListView from having its own scroll, delegates to SingleChildScrollView
                              itemCount: _activities.length,
                              itemBuilder: (context, index) {
                                final activity = _activities[index];
                                final String? logId = activity['logId']?.toString(); // Get logId for deletion
                                return Card(
                                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                                  elevation: 3,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                activity['activityName'] ?? 'Unknown Activity',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 18,
                                                  color: Colors.deepPurple,
                                                ),
                                              ),
                                            ),
                                            if (logId != null) // Show delete button only if logId is available
                                              IconButton(
                                                icon: const Icon(Icons.delete, color: Colors.red),
                                                onPressed: () {
                                                  // Confirm deletion before proceeding
                                                  showDialog(
                                                    context: context,
                                                    builder: (BuildContext context) {
                                                      return AlertDialog(
                                                        title: const Text('Confirm Deletion'),
                                                        content: Text('Are you sure you want to delete "${activity['activityName'] ?? 'this activity'}"?'),
                                                        actions: <Widget>[
                                                          TextButton(
                                                            child: const Text('Cancel'),
                                                            onPressed: () {
                                                              Navigator.of(context).pop(); // Dismiss dialog
                                                            },
                                                          ),
                                                          ElevatedButton(
                                                            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                                            child: const Text('Delete', style: TextStyle(color: Colors.white)),
                                                            onPressed: () {
                                                              print("Delete.........");
                                                              Navigator.of(context).pop(); // Dismiss dialog
                                                              deleteActivity(logId); // Call delete function
                                                            },
                                                          ),
                                                        ],
                                                      );
                                                    },
                                                  );
                                                },
                                              ),
                                          ],
                                        ),
                                        const SizedBox(height: 5),
                                        Text('Type: ${activity['activityTypeId'] ?? 'N/A'}'),
                                        Text('Duration: ${activity['duration'] != null ? '${(activity['duration'] / 60000).toStringAsFixed(0)} minutes' : 'N/A'}'), // Convert ms to minutes
                                        Text('Calories Burned: ${activity['calories'] ?? 'N/A'}'),
                                        Text('Start Time: ${activity['startTime'] ?? 'N/A'}'),
                                        // You can add more fields from the activity object as needed
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
          ],
        ),
      ),
    );
  }
}

// Example of how you might use GetActivityLog in your main.dart
void main() {
  runApp(MaterialApp(
    home: GetActivityLog(accessToken: 'YOUR_FITBIT_ACCESS_TOKEN'), // Replace with your actual token
  ));
}
