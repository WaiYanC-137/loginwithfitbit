// profile_page.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:loginwithfitbit/model/activity.dart';
import 'package:loginwithfitbit/ui/activities/activity_selection_type.dart';
import 'package:loginwithfitbit/ui/add_entry_bottom_sheet.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../services/fitbit_service.dart';
import 'package:loginwithfitbit/ui/food/food_log_list_page.dart';
import 'package:loginwithfitbit/ui/activities/exercise_stats_page.dart';
import 'package:loginwithfitbit/ui/water/water_tracker_page.dart';

import 'dart:math' as math;
import 'package:loginwithfitbit/ui/user_profile_page.dart';


import 'package:loginwithfitbit/ui/food/food_entry_page.dart';

class ProfilePage extends StatefulWidget {
  final FitbitService fitbitService;

  const ProfilePage({super.key, required this.fitbitService});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int _selectedIndex = 0;
  int? calorieGoal;
  int consumedCalories = 0;
  final int completedDays = 0;
  final int goalDays = 4;
  final List<String> days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  void _onItemTapped(int index) {
    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const UserProfilePage()),
      );
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  String _status = 'Loading profile...';
  Map<String, dynamic>? _profile;
  List<Activity> _activities = []; // Stores the fetched activity data
  int completed=0;
  int total=0;
  final List<Map<String, dynamic>> healthData = [
    {
      'title': 'Food',
      'value': '0 cal',
      'subText': 'Today · 1,841 cal below target',
      'percent': 0.2,
      'icon': Icons.local_dining,
      'iconColor': Colors.blue,
    },
    {
      'title': 'Sleep',
      'value': '6.2 hrs',
      'subText': 'Today · 1.8 hrs below target',
      'percent': 0.7,
      'icon': Icons.bedtime,
      'iconColor': Colors.deepPurple,
    },
    {
      'title': 'Water',
      'value': '500 ml',
      'subText': 'Today · 1.5 L below target',
      'percent': 0.35,
      'icon': Icons.water_drop,
      'iconColor': Colors.lightBlue,
    },
  ];


  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      print("🔄 Loading profile...");

      // Fetch user profile and food goal
      final profile = await widget.fitbitService.getProfile();
      final foodGoal = await widget.fitbitService.getFoodGoal();

      // ✅ Use correct API to get today's consumed calories
      final totalCalories = await widget.fitbitService.getTodayCaloriesConsumed();

      // Update state
      setState(() {
        _profile = profile;
        _status = profile != null ? 'Profile loaded' : 'Failed to load profile';

        calorieGoal = foodGoal ?? 0;
        consumedCalories = totalCalories;

        // Update healthData[0]
        healthData[0]['value'] = '$consumedCalories cal';

        if (calorieGoal! > 0) {
          final percent = (consumedCalories / calorieGoal!).clamp(0, 1);
          final remaining = calorieGoal! - consumedCalories;

          healthData[0]['percent'] = percent;
          healthData[0]['subText'] = remaining > 0
              ? 'Today · $remaining cal remaining'
              : 'Goal achieved! ✅';

          print('✅ Consumed: $consumedCalories cal');
          print('🎯 Goal: $calorieGoal cal');
          print('🟡 Remaining: $remaining cal');
        } else {
          healthData[0]['subText'] = 'Goal not set';
          print('⚠️ Food goal not set.');
        }
      });
    } catch (e) {
      setState(() {
        _status = '❌ Error loading profile: $e';
      });
      print('❌ Exception: $e');
    }
  }
  Future<List<Activity>> _fetchActivityLog() async {
    DateTime now = DateTime.now();
    String onlyDate = DateFormat('yyyy-MM-dd').format(now);
    _activities = await widget.fitbitService.fetchActivityLog(onlyDate, "asc", "0", "10");
    return _activities;
  }

  void _showAddEntryBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return AddEntryBottomSheet(
          onActivityCardTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ActivityListScreen(fitbitService: widget.fitbitService),
              ),
            ).then((result) {
              if (result == true) {
                setState(() => _status = 'Activity logged successfully!');
              } else {
                setState(() => _status = 'Activity logging cancelled.');
              }
            });
          },
          onFoodCardTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const FoodEntryPage(
                  isLogOnly: true,
                  showOnlyCustomTab: true,
                ),
              ),
            );
          },
          onWaterCardTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Water card tapped! (Not implemented yet)')),
            );
          },
          onWeightCardTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Weight card tapped! (Not implemented yet)')),
            );
          },
          onSleepCardTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Sleep card tapped! (Not implemented yet)')),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final beginningOfThisWeek = now.subtract(Duration(days: now.weekday - 1));
    final weekDates =List.generate(7, (i) => beginningOfThisWeek.add(Duration(days: i)));
    final double percent = (total == 0) ? 0 : completed / total;

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Dashboard'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Container(
        color: const Color(0xFFF5F8FF),
        child: ColoredBox(
          color: Colors.white,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(0, 10, 0, 24),
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(10, 0, 0, 10),
                child: Row(
                  children: [
                    Text.rich(
                      TextSpan(
                        children: [
                          const TextSpan(
                            text: 'Today, ',
                            style: TextStyle(color: Color(0xFF6759FF), fontWeight: FontWeight.w600, fontSize: 16),
                          ),
                          TextSpan(
                            text: DateFormat('d MMM yyyy').format(now),
                            style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w600, fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 120,
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(10, 10, 0, 0),
                  scrollDirection: Axis.horizontal,
                  itemCount: weekDates.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final date = weekDates[index];
                    final isToday = DateUtils.dateOnly(date) == DateUtils.dateOnly(now);
                    final bool isBeforeToday = date.isBefore(DateTime(now.year, now.month, now.day));

                  return Card(
                    elevation: 2,
                    color: isToday ?const Color.fromARGB(255, 50, 27, 226) : Colors.white,
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        color: isBeforeToday ?const Color.fromARGB(255, 94, 236, 175) : Colors.transparent,                    // <-- border here
                        width: 1.5,                              // thickness in logical pixels
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(                       // breathing room for the chip
                      padding: const EdgeInsets.all(4),
                      child: DayChip(date: date, isToday: isToday),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            //add Card View Like Food
            Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.grey[100],
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ExerciseStatsPage()),
            );
          },
          child: Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            color: Colors.grey[100],
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Exercise days', style: TextStyle(fontSize: 16)),
                  const SizedBox(height: 8),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: '$completedDays',
                          style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black),
                        ),
                        TextSpan(
                          text: ' of $goalDays',
                          style: const TextStyle(fontSize: 32, color: Colors.black),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text('This week', style: TextStyle(color: Colors.grey[700])),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: days.map((day) {
                      return Column(
                        children: [
                          Container(
                            width: 28,
                            height: 48,
                            decoration: BoxDecoration(
                              color: Colors.teal[100],
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            day,
                            style: TextStyle(
                              fontWeight: day == 'F' ? FontWeight.bold : FontWeight.normal,
                            ),
                          )
                        ],
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),

          ),
        ),
            const SizedBox(height: 16),
            ..._mealCards,
            const SizedBox(height: 16),
              // ✅ View Food Logs Button


              //add Card View Like Food
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: healthData.length,
                itemBuilder: (context, index) {
                  final item = healthData[index];
                  return GestureDetector(
                    onTap: () {
                      if (item['title'] == 'Food') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const FoodLogListPage()),
                        );
                      } else if (item['title'] == 'Water') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => WaterTrackerPage()),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('${item['title']} tapped! (Not implemented yet)')),
                        );
                      }
                    }
                    ,
                    child: HealthCard(
                      title: item['title'],
                      value: item['value'],
                      subText: item['subText'],
                      percent: item['percent'],
                      icon: item['icon'],
                      iconColor: item['iconColor'],
                    ),
                  );

                },
              ),




          ],
        ),

        ) // subtle bluish background

      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddEntryBottomSheet,
        tooltip: 'Add Favorite Activity',
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),

    );
  }

  List<Widget> get _mealCards {
    final meals = [
      ('Breakfast', 'Recommended 483-717 kcal'),
      ('Lunch', 'Recommended 516-870 kcal'),
      ('Snack', 'Recommended 203-370 kcal'),
      ('Dinner', 'Recommended 500-810 kcal'),
    ];

    return List.generate(meals.length, (i) {
      final (title, subtitle) = meals[i];
      final imgPath = 'assets/images/food${i + 1}.jpg';
      return Padding(
        padding: const EdgeInsets.fromLTRB(15, 5, 15, 5),
        child: MealCard(
          title: title,
          subtitle: subtitle,
          imageUrl: imgPath,
          imageOnRight: i.isEven,
        ),
      );
    });
  }
}

class DayChip extends StatelessWidget {
  const DayChip({required this.date, required this.isToday, super.key});

  final DateTime date;
  final bool isToday;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Padding(padding: EdgeInsets.only(top: 10.0)),
        Text(
          DateFormat('E').format(date).toUpperCase(),
          style: const TextStyle(fontSize: 18, color: Colors.grey),
        ),
        const SizedBox(height: 6),
        const Spacer(),
        Container(
          width: 45,
          height: 45,
          margin: const EdgeInsets.only(bottom: 5),
          decoration: BoxDecoration(
            color: isToday ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(22.5),
          ),
          alignment: Alignment.center,
          child: Padding(
            padding: const EdgeInsets.only(top: 1.0),
            child: Text(
              '${date.day}',
              style: TextStyle(
                color: isToday ? const Color.fromARGB(255, 56, 34, 223) : Colors.black,
                fontWeight: FontWeight.w600,
                fontSize: 18,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class MealCard extends StatelessWidget {
  const MealCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.imageOnRight,
  });

  final String title;
  final String subtitle;
  final String imageUrl;
  final bool imageOnRight;

  @override
  Widget build(BuildContext context) {
    const double cardHeight = 130;
    const double imageSize = 130;
    const double imageWidth = 180;

    final BorderRadius imgRadius = imageOnRight
        ? const BorderRadius.only(bottomLeft: Radius.circular(60), topRight: Radius.circular(60), bottomRight: Radius.circular(20))
        : const BorderRadius.only(topRight: Radius.circular(60));

    final imageWidget = Positioned(
      right: imageOnRight ? -imageSize / 2 : null,
      left: imageOnRight ? null : -imageSize / 2,
      child: ClipRRect(
        borderRadius: imgRadius,
        child: Image.asset(
          imageUrl,
          width: imageWidth,
          height: imageSize,
          fit: BoxFit.cover,
        ),
      ),
    );

    final content = Container(
      height: cardHeight,
      margin: const EdgeInsets.symmetric(horizontal: 10),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(offset: Offset(0, 4), blurRadius: 12, color: Colors.black12),
        ],
      ),
      child: Row(
        mainAxisAlignment: imageOnRight ? MainAxisAlignment.start : MainAxisAlignment.end,
        children: [
          SizedBox(
            width: 180,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text(subtitle, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                const Spacer(),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FoodEntryPage(
                          isLogOnly: true,
                          mealType: title,
                        ),
                      ),
                    ).then((result) {
                      if (result == 'logged') {
                        final state = context.findAncestorStateOfType<_ProfilePageState>();
                        state?._loadProfile();
                      }
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6C63FF),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(60, 32),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('+ Add'),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    return SizedBox(
      height: cardHeight,
      child: Stack(
        children: [content, imageWidget],
      ),
    );
  }
}


class HealthCard extends StatelessWidget {
  final String title;
  final String value;
  final String subText;
  final double percent;
  final IconData icon;
  final Color iconColor;

  const HealthCard({
    super.key,
    required this.title,
    required this.value,
    required this.subText,
    required this.percent,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            blurRadius: 8,
            offset: Offset(0, 4),
            color: Colors.black12,
          ),
        ],
      ),
      child: Row(
        children: [
          // Left side
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(fontSize: 14, color: Colors.black54)),
                const SizedBox(height: 4),
                Text(value,
                    style: const TextStyle(
                        fontSize: 26, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(subText,
                    style: const TextStyle(fontSize: 13, color: Colors.grey)),
              ],
            ),
          ),
          // Right side: Ring with icon
          ThreeQuarterArc(
            percent: percent,
            color: iconColor,
            icon: icon,
          ),

        ],
      ),
    );
  }
}
class ThreeQuarterArc extends StatelessWidget {
  final double percent;
  final Color color;
  final IconData icon;

  const ThreeQuarterArc({
    super.key,
    required this.percent,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _ArcPainter(percent: percent, color: color),
      child: SizedBox(
        width: 70,
        height: 70,
        child: Center(
          child: Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  blurRadius: 4,
                  offset: Offset(0, 1),
                  color: Colors.black12,
                ),
              ],
            ),
            child: Icon(icon, size: 24, color: color),
          ),
        ),
      ),
    );
  }
}

class _ArcPainter extends CustomPainter {
  final double percent;
  final Color color;

  _ArcPainter({required this.percent, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final strokeWidth = 6.0;
    final radius = size.width / 2;

    final startAngle = 5 * math.pi / 6; // 150°
    final sweepAngle = 4 * math.pi / 3 * percent; // 240°

    final paintBg = Paint()
      ..color = const Color(0xFFE5E5E5)
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final paintFg = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
      startAngle,
      4 * math.pi / 3, // full background arc (240°)
      false,
      paintBg,
    );

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
      startAngle,
      sweepAngle,
      false,
      paintFg,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
