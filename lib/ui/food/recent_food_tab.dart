import 'package:flutter/material.dart';

import '../../services/fitbit_service.dart';


class RecentFoodTab extends StatelessWidget {
  final FitbitService fitbitService;

  const RecentFoodTab({super.key, required this.fitbitService});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: fitbitService.getRecentFoodLogs(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No recent foods'));
        }

        final foods = snapshot.data!;
        return ListView.builder(
          itemCount: foods.length,
          itemBuilder: (context, index) {
            final food = foods[index];
            return ListTile(
              title: Text(food['loggedFood']['name']),
              subtitle: Text('${food['loggedFood']['calories']} kcal'),
            );
          },
        );
      },
    );
  }
}
