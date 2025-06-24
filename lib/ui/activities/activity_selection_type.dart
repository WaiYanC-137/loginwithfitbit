import 'dart:async';

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
  late List<Activity> _getAllActivityType;
  List<Activity> _filteredActivities = [];
  bool _isSearching = false;


  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _recentActivitiesFuture = widget.fitbitService.getRecentActivitiesTypes();
    _popularActivitiesFuture = widget.fitbitService.getFrequentActivitiesTypes();
    _searchController.addListener(_onSearchChanged);
  }

  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() async{
    _isSearching=true;
    _getAllActivityType=await widget.fitbitService.getAllActivitiesTypes();
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredActivities = _getAllActivityType
          .where((activity) => activity.name.toLowerCase().contains(query))
          .toList();
    });
  }
  
@override
  Widget build(BuildContext context) {
    return Scaffold(
       appBar: AppBar(
        title: TextField(
          controller: _searchController,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Search Activity...',
            hintStyle: TextStyle(color: Colors.white70),
            border: InputBorder.none,
            icon: Icon(Icons.search, color: Colors.white),
          ),
        ),
        backgroundColor: Colors.deepPurple,
      ),
    body: _isSearching ? _buildFilteredList() : _buildDefaultSections(),
    );
  }

 Widget _buildDefaultSections() {
    return Column(
      children: [
        const SectionHeader('Recent Activities'),
        Expanded(child: _buildSection(_recentActivitiesFuture , recent: true)),
        const SectionHeader('Most Popular Activities'),
      Expanded(child: _buildSection(_popularActivitiesFuture, recent: false)),

      ],
    );
  }

  Widget _buildFilteredList() {
    if (_filteredActivities.isEmpty) {
      return const Center(child: Text('No activities match your search'));
    }
    return ListView.builder(
  itemCount: _filteredActivities.length,
  itemBuilder: (_, i) {
    final activity = _filteredActivities[i];
    return Card(
      margin: const EdgeInsets.all(8),
      child: ListTile(
        onTap: () {
                    // Navigate to the ActivityFormPage, passing the selected activity
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CreateActivityLog(
                          fitbitService: widget.fitbitService, // Pass FitbitService
                          selectedActivity:activity, // Pass the selected Activity object
                        ),
                      ),
                    );
                  },   
        title: Text(activity.name),
             ),
    );
  },
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
            final activities = list[i];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0), // Smaller margins for compact cards
              elevation: 1, // Subtle shadow
              child: ListTile( 
                  onTap: () {
                    // Navigate to the ActivityFormPage, passing the selected activity
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CreateActivityLog(
                          fitbitService: widget.fitbitService, // Pass FitbitService
                          selectedActivity: activities, // Pass the selected Activity object
                        ),
                      ),
                    );
                  },         
                title: Text(activities.name),
                subtitle: recent
                  ? Text(activities.description.isEmpty
                        ? "No description"
                        : activities.description)
                  : Text("${activities.calories} cal • ${activities.distance} km"),
              trailing:
                  Text("${(activities.duration / 60000).toStringAsFixed(1)} min"),),

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

