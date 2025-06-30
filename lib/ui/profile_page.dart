// profile_page.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:loginwithfitbit/model/activity.dart';
import 'package:loginwithfitbit/ui/activities/activity_selection_type.dart';
import 'package:loginwithfitbit/ui/add_entry_bottom_sheet.dart';
import '../services/fitbit_service.dart';
import 'activity_selection_page.dart';
import 'package:loginwithfitbit/ui/food/food_entry_page.dart';

class ProfilePage extends StatefulWidget {
  final FitbitService fitbitService;

  const ProfilePage({super.key, required this.fitbitService});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String _status = 'Loading profile...';
  Map<String, dynamic>? _profile;
  List<Activity> _activities = [];

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
    final weekDates = List.generate(7, (i) => beginningOfThisWeek.add(Duration(days: i)));

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
                      color: isToday ? const Color.fromARGB(255, 50, 27, 226) : Colors.white,
                      shape: RoundedRectangleBorder(
                        side: BorderSide(
                          color: isBeforeToday ? const Color.fromARGB(255, 94, 236, 175) : Colors.transparent,
                          width: 1.5,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: DayChip(date: date, isToday: isToday),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              ..._mealCards,
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddEntryBottomSheet,
        tooltip: 'Add Favorite Activity',
        child: const Icon(Icons.add),
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
                    );
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
