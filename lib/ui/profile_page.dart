import 'package:flutter/material.dart';
import 'package:loginwithfitbit/ui/activities/activity_selection_type.dart';
import 'package:loginwithfitbit/ui/add_entry_bottom_sheet.dart';
import '../services/fitbit_service.dart';
import 'activity_selection_page.dart';
import 'package:loginwithfitbit/ui/food/food_entry_page.dart';

class ProfilePage extends StatefulWidget {
  final FitbitService fitbitService;

  const ProfilePage({super.key, required this.fitbitService});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String _status = 'Loading profile...';
  Map<String, dynamic>? _profile;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final profile = await widget.fitbitService.getProfile();
    setState(() {
      if (profile != null) {
        _profile = profile;
        _status = 'Profile loaded';
      } else {
        _status = 'Failed to load profile';
      }
    });
  }

  Future<void> _chooseAndAddFavorite() async {
    final activities = await widget.fitbitService.getAllActivities();

    if (activities.isEmpty) {
      setState(() {
        _status = 'No activities found';
      });
      return;
    }

    final chosenActivity = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) => ActivitySelectionPage(
          fitbitService: widget.fitbitService,
        ),
      ),
    );

    if (chosenActivity != null) {
      setState(() {
        _status = '${chosenActivity['name']} added to favorites.';
      });
    }
  }

  // Method to show the custom bottom sheet
  void _showAddEntryBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Important for content that might exceed screen height
      builder: (BuildContext context) {
        return AddEntryBottomSheet(
          onActivityCardTap: () {
            // Navigate to ActivityFormPage
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) =>  ActivityListScreen(fitbitService: widget.fitbitService)),
            ).then((result) {
              // This .then() block executes when ActivityFormPage is popped
              if (result == true) {
                setState(() {
                  _status = 'Activity logged successfully!';
                });
              } else {
                setState(() {
                  _status = 'Activity logging cancelled.';
                });
              }
            });
          },
          onFoodCardTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const FoodEntryPage()),
            );
          },

          onWaterCardTap: () {
            // TODO: Implement navigation or dialog for Water entry
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Water card tapped! (Not implemented yet)')),
            );
          },
          onWeightCardTap: () {
            // TODO: Implement navigation or dialog for Weight entry
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Weight card tapped! (Not implemented yet)')),
            );
          },
          onSleepCardTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Weight card tapped! (Not implemented yet)')),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_profile != null) ...[
                Card(
                  child: ListTile(
                    title: Text(_profile!['fullName'] ?? 'No name'),
                    subtitle: Text('Age: ${_profile!['age'] ?? 'Unknown'}'),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _chooseAndAddFavorite,
                  child: const Text('Choose and Add Favorite Activity'),
                ),
              ] else ...[
                Text(_status),
              ],
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed:  _showAddEntryBottomSheet,
        tooltip: 'Add Favorite Activity',
        child: const Icon(Icons.add),
    ),
    );
  }
}
