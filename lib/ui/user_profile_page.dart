import 'package:flutter/material.dart';
import 'package:loginwithfitbit/services/fitbit_service.dart';
import 'package:loginwithfitbit/ui/food/food_goal_page.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  Map<String, dynamic>? _profile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final fitbitService = FitbitService();
    await fitbitService.loadAccessToken();
    final profile = await fitbitService.getProfile();

    setState(() {
      _profile = profile;
      _isLoading = false;
    });
  }

  int _calculateAge(String dateOfBirthStr) {
    try {
      final dob = DateTime.parse(dateOfBirthStr);
      final now = DateTime.now();
      int age = now.year - dob.year;
      if (now.month < dob.month || (now.month == dob.month && now.day < dob.day)) {
        age--;
      }
      return age;
    } catch (e) {
      return 0;
    }
  }

  Widget _buildGoalCard(String title, String subtitle, IconData icon) {
    return GestureDetector(
      onTap: () {
        if (title == 'Food') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const FoodGoalPage()),
          );
        }
      },
      child: Container(
        width: 120,
        height: 120,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 28, color: Colors.black54),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 14)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final name = _profile?['fullName'] ?? 'Unknown';
    final dob = _profile?['dateOfBirth'] ?? '';
    final age = dob.isNotEmpty ? _calculateAge(dob).toString() : '--';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Text('Age $age', style: const TextStyle(fontSize: 16, color: Colors.grey)),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {},
                  child: const Text('Edit profile', style: TextStyle(fontSize: 16, color: Color(0xFF007AFF))),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFFF5F8FF),
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Goals', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 140,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          _buildGoalCard('Activity', '5 goals', Icons.directions_run),
                          _buildGoalCard('Food', '2 goals', Icons.fastfood),
                          _buildGoalCard('Water', '1 goal', Icons.local_drink),
                          _buildGoalCard('Weight', '1 goal', Icons.monitor_weight),
                          _buildGoalCard('Sleep', '1 goal', Icons.nightlight_round),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
