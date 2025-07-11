import 'package:flutter/material.dart';
import 'exercise_selection_page.dart'; // Make sure this file exists

class ExerciseStatsPage extends StatelessWidget {
  const ExerciseStatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    const int goalDays = 4;
    const int completedDays = 0;
    const List<String> days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Exercise'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          const Text('Week', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('This week'),
          const SizedBox(height: 16),
          Text(
            '$completedDays of $goalDays exercise days',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text("You didn't track or log any exercise"),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: days.map((d) {
              return Column(
                children: [
                  Container(
                    width: 28,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(d),
                ],
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          ToggleButtons(
            isSelected: const [true, false, false],
            onPressed: (int index) {
              // Optional: Add logic to switch modes
            },
            borderRadius: BorderRadius.circular(8),
            children: const [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text("Exercise Days"),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text("Duration"),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text("Distance"),
              ),
            ],
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.only(bottom: 20.0),
            child: ElevatedButton.icon(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  builder: (BuildContext context) {
                    return Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Add exercise',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.pop(context); // Close bottom sheet
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => const ExerciseSelectionPage()),
                                  );
                                },
                                icon: const Icon(Icons.directions_run),
                                label: const Text('Start tracking'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.teal[50],
                                  foregroundColor: Colors.black,
                                ),
                              ),
                              ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.pop(context);
                                  // TODO: Handle Log Activity
                                },
                                icon: const Icon(Icons.edit),
                                label: const Text('Log activity'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.teal[50],
                                  foregroundColor: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
              icon: const Icon(Icons.add),
              label: const Text("Add exercise"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal[100],
                foregroundColor: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
