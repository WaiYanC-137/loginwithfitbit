import 'package:flutter/material.dart';

class AddEntryBottomSheet extends StatelessWidget {
  final VoidCallback onActivityCardTap;
  final VoidCallback onFoodCardTap;
  final VoidCallback onWaterCardTap;
  final VoidCallback onWeightCardTap;
  final VoidCallback onSleepCardTap;

  const AddEntryBottomSheet({
    super.key,
    required this.onActivityCardTap,
    required this.onFoodCardTap,
    required this.onWaterCardTap,
    required this.onWeightCardTap,
    required this.onSleepCardTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // Reduced the height. Using a fixed height or a fraction of screen height
      // can control the overall space for the cards.
      // Adjust this value as needed.
      height: 380, // Example fixed height. You can also use MediaQuery for responsive height.
      padding: const EdgeInsets.all(16.0),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Manually Log',
                style: TextStyle(
                  fontSize: 20, // Slightly reduced font size for title
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16), // Reduced space
          Expanded( // Use Expanded when the parent has a fixed height
            child: GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 3, // Changed to 3 columns for more compact display
              crossAxisSpacing: 12.0, // Adjusted spacing
              mainAxisSpacing: 12.0, // Adjusted spacing
              // childAspectRatio: 0.8, // Optional: Adjust aspect ratio if you want different card shapes
              children: [
                _buildEntryCard(
                  context,
                  icon: Icons.directions_run,
                  title: 'Activity',
                  color: Colors.blue.shade100,
                  onTap: onActivityCardTap,
                ),
                _buildEntryCard(
                  context,
                  icon: Icons.restaurant,
                  title: 'Food',
                  color: Colors.green.shade100,
                  onTap: onFoodCardTap,
                ),
                _buildEntryCard(
                  context,
                  icon: Icons.water_drop,
                  title: 'Water',
                  color: Colors.lightBlue.shade100,
                  onTap: onWaterCardTap,
                ),
                _buildEntryCard(
                  context,
                  icon: Icons.monitor_weight,
                  title: 'Weight',
                  color: Colors.purple.shade100,
                  onTap: onWeightCardTap,
                ),
                _buildEntryCard(
                  context,
                  icon: Icons.bedtime,
                  title: 'Sleep',
                  color: Colors.indigo.shade100,
                  onTap: onSleepCardTap,
                ),
                 // You can add more cards here if needed
              ],
            ),
          ),
          const SizedBox(height: 5), // Smaller padding at the bottom
        ],
      ),
    );
  }

  Widget _buildEntryCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      color: color,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.pop(context);
          onTap();
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(8.0), // Reduced padding inside the card
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 32, color: Colors.grey.shade800), // Reduced icon size
              const SizedBox(height: 8), // Reduced space
              Text(
                title,
                textAlign: TextAlign.center, // Center text for potentially shorter cards
                style: TextStyle(
                  fontSize: 14, // Reduced font size
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}