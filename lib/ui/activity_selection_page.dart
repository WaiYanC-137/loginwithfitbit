import 'package:flutter/material.dart';
import '../services/fitbit_service.dart';

class ActivitySelectionPage extends StatefulWidget {
  final FitbitService fitbitService;

  const ActivitySelectionPage({
    super.key,
    required this.fitbitService,
  });

  @override
  State<ActivitySelectionPage> createState() => _ActivitySelectionPageState();
}

class _ActivitySelectionPageState extends State<ActivitySelectionPage> {
  List<Map<String, dynamic>> activities = [];

  @override
  void initState() {
    super.initState();
    _loadActivities();
  }

  Future<void> _loadActivities() async {
    final allActivities = await widget.fitbitService.getAllActivities();
    final favoriteIds = await widget.fitbitService.getFavoriteActivityIds();

    final updated = allActivities.map((activity) {
      final id = activity['id'];
      activity['isFavorite'] = favoriteIds.contains(id);
      return activity;
    }).toList();

    setState(() {
      activities = updated;
    });
  }

  void _toggleFavorite(BuildContext context, Map<String, dynamic> activity) async {
    final activityId = activity['id'];
    if (activityId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Activity ID is missing.')),
      );
      return;
    }

    final isFavorite = activity['isFavorite'] ?? false;
    final success = isFavorite
        ? await widget.fitbitService.removeFavoriteActivity(activityId)
        : await widget.fitbitService.addFavoriteActivity(activityId);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${activity['name']} ${isFavorite ? 'removed from' : 'added to'} favorites!',
          ),
        ),
      );

      // Refresh favorite status
      await _loadActivities();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update activity.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select Activity')),
      body: ListView.builder(
        itemCount: activities.length,
        itemBuilder: (context, index) {
          final activity = activities[index];
          final isFavorite = activity['isFavorite'] ?? false;

          return Card(
            child: ListTile(
              title: Text(activity['name'] ?? 'Unnamed Activity'),
              trailing: ElevatedButton(
                onPressed: () => _toggleFavorite(context, activity),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isFavorite ? Colors.red : Colors.blue,
                ),
                child: Text(isFavorite ? 'Remove from Favorites' : 'Add to Favorites'),
              ),
            ),
          );
        },
      ),
    );
  }
}
