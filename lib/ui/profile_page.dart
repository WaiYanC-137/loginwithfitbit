import 'package:flutter/material.dart';
import '../services/fitbit_service.dart';
import 'activity_selection_page.dart';

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
          activities: activities,
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
    );
  }
}
