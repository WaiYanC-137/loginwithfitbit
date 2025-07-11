import 'package:flutter/material.dart';
import 'package:loginwithfitbit/services/fitbit_service.dart';
import 'package:loginwithfitbit/ui/profile_page.dart'; // Adjust this import according to your file structure

class ActivityGoalPage extends StatefulWidget {
  const ActivityGoalPage({super.key});

  @override
  State<ActivityGoalPage> createState() => _ActivityGoalPageState();
}

class _ActivityGoalPageState extends State<ActivityGoalPage> {
  int _calories = 4; // Default calorie value
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.text = _calories.toString();
  }

  Future<void> _setActivityGoal() async {
    final fitbitService = FitbitService();
    await fitbitService.loadAccessToken();

    final response = await fitbitService.createFoodGoal(_calories);

    if (response) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Food goal set successfully')),
      );
      // Pop the current page (ActivityGoalPage) and push ProfilePage to reload it
      Navigator.pop(context);  // Pop the ActivityGoalPage
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ProfilePage(fitbitService: fitbitService)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to set food goal')),
      );
    }
  }

  void _increment() {
    setState(() {
      _calories += 1;
      _controller.text = _calories.toString();
    });
  }

  void _decrement() {
    setState(() {
      if (_calories > 0) _calories -= 1;
      _controller.text = _calories.toString();
    });
  }

  void _onTextChanged(String value) {
    final parsed = int.tryParse(value);
    if (parsed != null && parsed >= 0) {
      setState(() {
        _calories = parsed;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Activity Goal'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 48),
            GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Edit Calories'),
                    content: TextField(
                      controller: _controller,
                      keyboardType: TextInputType.number,
                      onChanged: _onTextChanged,
                      decoration: const InputDecoration(hintText: 'Enter calories'),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(ctx);
                        },
                        child: const Text('Done'),
                      ),
                    ],
                  ),
                );
              },
              child: Text(
                _calories.toString(),
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'day per day',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.shade200,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    minimumSize: const Size(60, 50),
                  ),
                  onPressed: _decrement,
                  child: const Text('-', style: TextStyle(fontSize: 24)),
                ),
                const SizedBox(width: 24),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.shade200,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    minimumSize: const Size(60, 50),
                  ),
                  onPressed: _increment,
                  child: const Text('+', style: TextStyle(fontSize: 24)),
                ),
              ],
            ),
            const Spacer(), // 👈 This pushes the button to the bottom
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF007A5F),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                ),
                onPressed: _setActivityGoal,
                child: const Text('Set goal', style: TextStyle(fontSize: 18)),
              ),
            ),
            const SizedBox(height: 24), // Optional bottom padding
          ],
        ),
      ),
    );
  }
}
