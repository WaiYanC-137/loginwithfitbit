import 'package:flutter/material.dart';
import 'package:loginwithfitbit/model/activity.dart';
import 'package:loginwithfitbit/services/fitbit_service.dart';
import 'package:loginwithfitbit/ui/activities/create_activity_log.dart';

class ActivityListScreen extends StatefulWidget {
  final FitbitService fitbitService;

  const ActivityListScreen({
    super.key,
    required this.fitbitService,
  });

  @override
  State<ActivityListScreen> createState() => _ActivitySelectionPageState();
}

class _ActivitySelectionPageState extends State<ActivityListScreen> {
  late Future<List<Activity>> _recentActivitiesFuture;
  late Future<List<Activity>> _popularActivitiesFuture;
  @override
  void initState() {
    super.initState();
    _recentActivitiesFuture = widget.fitbitService.getRecentActivitiesTypes();
    _popularActivitiesFuture = widget.fitbitService.getFrequentActivitiesTypes();

  }
@override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Activities")),
      body: Column(
        children: [
          const SectionHeader("Recent Activities"),
          Expanded(child: _buildSection(_recentActivitiesFuture , recent: true)),
          const SectionHeader("Most Popular Activities"),
          Expanded(child: _buildSection(_popularActivitiesFuture, recent: false)),
        ],
      ),
    );
  }
Widget _buildSection(Future<List<Activity>> future, {required bool recent}) {
    return FutureBuilder<List<Activity>>(
      future: future,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snap.hasError) {
          return Center(child: Text("Error: ${snap.error}"));
        }
        final list = snap.data ?? [];
        if (list.isEmpty) {
          return Center(
              child: Text(recent ? "No recent activities"
                                  : "No popular activities"));
        }
        return ListView.builder(
          itemCount: list.length,
          itemBuilder: (_, i) {
            final recentActivities = list[i];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0), // Smaller margins for compact cards
              elevation: 1, // Subtle shadow
              child: ListTile( 
                onTap: () {
                                   // Print the name of the selected activity
                  print("Tapped activity: ${recentActivities.name}");

                  // Navigate to the ActivityFormPage, passing the selected activity
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CreateActivityLog(
                        fitbitService: widget.fitbitService, // Pass FitbitService
                        selectedActivity: recentActivities, // Pass the selected Activity object
                      ),
                    ),
                  ).then((result) {
                    // This block executes when ActivityFormPage is popped
                    if (result == true) {
                      // Optionally, refresh recent activities if a new one was logged
                      // setState(() {
                      //   _recentActivitiesFuture = widget.fitbitService.getRecentActivitiesTypes();
                      // });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('${recentActivities.name} logged successfully!')),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Activity logging cancelled.')),
                      );
                    }
                  });
                },         
                title: Text(recentActivities.name),
                subtitle: recent
                  ? Text(recentActivities.description.isEmpty
                        ? "No description"
                        : recentActivities.description)
                  : Text("${recentActivities.calories} cal • ${recentActivities.distance} km"),
              trailing:
                  Text("${(recentActivities.duration / 60000).toStringAsFixed(1)} min"),),

            );
          },
        );
      },
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String text;
  const SectionHeader(this.text, {super.key});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(2),
        child: Text(text,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      );
}

