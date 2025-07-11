import 'package:flutter/material.dart';
import 'package:loginwithfitbit/ui/activities/activity_goal_page.dart';

class ActivityGoalSelection extends StatefulWidget {
  const ActivityGoalSelection({super.key});

  @override
  State<ActivityGoalSelection> createState() => _GoalSelectionState();
}

class _GoalSelectionState extends State<ActivityGoalSelection> {
  final List<String> _goals = [
    'Exercise Days',
    'Steps',
    'Hourly Activity',
    'Distance',
    'Energy Burned',
  ];
  final List<String> _hours=[
  '4',
  '5000',
  '9AM-6PM',
  '5mi',
  '1,911cal'
  ];
  final List<String> _dateType=[
    'Weekly',
    'Daily',
    'Daily',
    'Daily',
    'Daily'
  ];
  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text('Activity Goal'),
      backgroundColor: const Color.fromARGB(255, 29, 10, 99),
    ),
    body: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(12.0),
          child: Text(
            'Activity',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _goals.length,
            itemBuilder: (BuildContext context, int index) {
              final String goal = _goals[index];
              final String hour = _hours[index];
              final String dateType = _dateType[index];

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 12.0),
                child: SizedBox(
                  height: 90, // 👈 Increased height
                  child: ListTile(
                    title: Text(goal, style: const TextStyle(fontSize: 16)),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(hour, style: const TextStyle(fontSize: 14)),
                        Text(dateType, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                    onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const ActivityGoalPage()),
                            );
                    },
                  ),
                ),
              );
            },
          ),
        ),
      ],
    ),
  );
}

}