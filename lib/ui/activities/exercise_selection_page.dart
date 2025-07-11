import 'package:flutter/material.dart';
import 'step_tracking_page.dart';

class ExerciseSelectionPage extends StatelessWidget {
  const ExerciseSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<String> exerciseOptions = [
      'Running',
      'Cycling',
      'Swimming',
      'Walking',
      'Yoga',
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Start Tracking'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // 🗺️ Placeholder instead of Google Map
          Expanded(
            child: Container(
              color: Colors.grey[300],
              alignment: Alignment.center,
              child: const Text(
                '🗺️ Map Placeholder\n(Add Google API key later)',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Select Exercise Type',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 60,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: exerciseOptions.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                return ElevatedButton(
                  onPressed: () {
                    String selected = exerciseOptions[index];

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('$selected selected')),
                    );

                    if (selected == 'Walking') {
                      Navigator.pop(context); // Close this page
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const StepTrackingPage(),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal[100],
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(exerciseOptions[index]),
                );
              },
            ),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context); // Default fallback
              },
              icon: const Icon(Icons.check_circle_outline),
              label: const Text('Start Session'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
