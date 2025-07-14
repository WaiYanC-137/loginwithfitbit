import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class WaterTrackerPage extends StatefulWidget {
  const WaterTrackerPage({super.key});

  @override
  State<WaterTrackerPage> createState() => _WaterTrackerPageState();
}

class _WaterTrackerPageState extends State<WaterTrackerPage> {
  double currentWater = 500; // ml
  final double waterGoal = 1790; // ml

  @override
  Widget build(BuildContext context) {
    double percent = (currentWater / waterGoal).clamp(0, 1);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Water Tracker"),
        backgroundColor: Colors.lightBlueAccent,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
        color: Colors.white,
        child: Column(
          children: [
            Text(
              'Monday, 4th Dec',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 20),
            CircularPercentIndicator(
              radius: 100.0,
              lineWidth: 12.0,
              percent: percent,
              animation: true,
              circularStrokeCap: CircularStrokeCap.round,
              progressColor: Colors.lightBlue,
              center: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "${(percent * 100).round()}%",
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${currentWater.toInt()} / ${waterGoal.toInt()} ml",
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              "Daily goal",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const Spacer(),
            ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text("Add Water"),
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  builder: (context) {
                    return AddWaterBottomSheet(
                      onAdd: (amount) {
                        setState(() {
                          currentWater += amount;
                          if (currentWater > waterGoal) {
                            currentWater = waterGoal;
                          }
                        });
                      },
                    );
                  },
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class AddWaterBottomSheet extends StatefulWidget {
  final Function(int) onAdd;

  const AddWaterBottomSheet({super.key, required this.onAdd});

  @override
  State<AddWaterBottomSheet> createState() => _AddWaterBottomSheetState();
}

class _AddWaterBottomSheetState extends State<AddWaterBottomSheet> {
  int _selectedAmount = 100;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "Add a new cup",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 16,
            runSpacing: 16,
            children: const [
              _CupIcon(icon: Icons.local_cafe),
              _CupIcon(icon: Icons.wine_bar),
              _CupIcon(icon: Icons.local_drink),
              _CupIcon(icon: Icons.emoji_food_beverage),
              _CupIcon(icon: Icons.bubble_chart),
              _CupIcon(icon: Icons.water_drop),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: () {
                  if (_selectedAmount > 50) {
                    setState(() => _selectedAmount -= 50);
                  }
                },
                icon: const Icon(Icons.remove_circle_outline),
              ),
              Text(
                '$_selectedAmount ml',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              IconButton(
                onPressed: () {
                  if (_selectedAmount < 1500) {
                    setState(() => _selectedAmount += 50);
                  }
                },
                icon: const Icon(Icons.add_circle_outline),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            "Water intake range: 50ml - 1500ml",
            style: TextStyle(fontSize: 12, color: Colors.redAccent),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              widget.onAdd(_selectedAmount);
              Navigator.pop(context);
            },
            child: const Text("OK"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.lightBlue,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }
}

class _CupIcon extends StatelessWidget {
  final IconData icon;
  const _CupIcon({required this.icon});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 24,
      backgroundColor: Colors.grey.shade200,
      child: Icon(icon, color: Colors.lightBlue),
    );
  }
}
