import 'package:flutter/material.dart';
import '../services/fitbit_service.dart';

class ActivitySelectionPage extends StatefulWidget {
  final List<Map<String, dynamic>> activities;
  final FitbitService fitbitService;

  const ActivitySelectionPage({
    super.key,
    required this.activities,
    required this.fitbitService,
  });

  @override
  State<ActivitySelectionPage> createState() => _ActivitySelectionPageState();
}

class _ActivitySelectionPageState extends State<ActivitySelectionPage> {
  // Function to toggle the favorite status of an activity
  void _toggleFavorite(BuildContext context, Map<String, dynamic> activity) async {
    // Check if activityId is null
    final activityId = activity['activityId'];
    if (activityId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Activity ID is missing.')),
      );
      return;
    }

    final isFavorite = activity['isFavorite'] ?? false;
    final success = isFavorite
        ? await widget.fitbitService.removeFavoriteActivity(activityId)  // Add this method to remove from favorites
        : await widget.fitbitService.addFavoriteActivity(activityId);  // Add to favorites

    // Show feedback via a snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? '${activity['name']} ${isFavorite ? 'removed from' : 'added to'} favorites!'
              : 'Failed to update activity.',
        ),
      ),
    );

    // Update the activity's favorite status
    if (success) {
      setState(() {
        activity['isFavorite'] = !isFavorite;  // Toggle the favorite status
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select Activity')),
      body: ListView.builder(
        itemCount: widget.activities.length,
        itemBuilder: (context, index) {
          final activity = widget.activities[index];
          // Print the activity to check the structure
          print(activity); // Debugging
          // Default to 'false' if 'isFavorite' is not defined for an activity
          final isFavorite = activity['isFavorite'] ?? false;

          return Card(
            child: ListTile(
              title: Text(activity['name'] ?? 'Unnamed Activity'),
              trailing: ElevatedButton(
                onPressed: () => _toggleFavorite(context, activity),
                child: Text(isFavorite ? 'Remove from Favorites' : 'Add to Favorites'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isFavorite ? Colors.red : Colors.blue,  // Correct property for button color
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
