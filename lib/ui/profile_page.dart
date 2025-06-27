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
  final Future<Activity>? activities; // Made nullable as it's not always required

  const ProfilePage({
    super.key, // Always pass key to super
    required this.fitbitService,
  }) : activities = null; // Initialize 'activities' to null for this constructor
  
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String _status = 'Loading profile...';
  Map<String, dynamic>? _profile;
  List<Activity> _activities = []; // Stores the fetched activity data

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
      _activities = await widget.fitbitService.fetchActivityLog(onlyDate,"asc","0","10");
    return _activities;
  }

  Future<void> _chooseAndAddFavorite() async {
    final activities = await widget.fitbitService.getAllActivities();

    if (activities.isEmpty) {
      setState(() {
        _status = 'No activities found';
      });
      return;
    }

    final chosenActivity = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) => ActivitySelectionPage(
          fitbitService: widget.fitbitService,
        ),
      ),
    );

    if (chosenActivity != null) {
      setState(() {
        _status = '${chosenActivity['name']} added to favorites.';
      });
    }
  }

  // Method to show the custom bottom sheet
  void _showAddEntryBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Important for content that might exceed screen height
      builder: (BuildContext context) {
        return AddEntryBottomSheet(
          onActivityCardTap: () {
            // Navigate to ActivityFormPage
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) =>  ActivityListScreen(fitbitService: widget.fitbitService)),
            ).then((result) {
              // This .then() block executes when ActivityFormPage is popped
              if (result == true) {
                setState(() {
                  _status = 'Activity logged successfully!';
                });
              } else {
                setState(() {
                  _status = 'Activity logging cancelled.';
                });
              }
            });
          },
          onFoodCardTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const FoodEntryPage(isLogOnly: true)),
            );
          },


          onWaterCardTap: () {
            // TODO: Implement navigation or dialog for Water entry
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Water card tapped! (Not implemented yet)')),
            );
          },
          onWeightCardTap: () {
            // TODO: Implement navigation or dialog for Weight entry
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Weight card tapped! (Not implemented yet)')),
            );
          },
          onSleepCardTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Weight card tapped! (Not implemented yet)')),
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
    final weekDates =
        List.generate(7, (i) => beginningOfThisWeek.add(Duration(days: i)));

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
        child:ColoredBox(color: Colors.white,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(0, 10, 0, 24),
          children: [
            /// DATE ROW (“Today, 6 Nov 2021  ˅”)
            Container(
              padding: const EdgeInsets.fromLTRB(10, 0, 0, 10),
              child:Row(
              children: [
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: 'Today, ',
                      style: TextStyle(
                        color: Color(0xFF6759FF), // Purple color for "Today,"
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    TextSpan(
                      text: DateFormat('d MMM yyyy').format(now),
                      style: TextStyle(
                        color: Colors.black, // Black color for the date
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              )
              ],
              ),
            ),
            /// HORIZONTAL WEEK-DAY CHIPS
            SizedBox( 
               // give the horizontal list a fixed height
              height: 120,            // adjust to suit your UI
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(10, 10, 0, 0),
                scrollDirection: Axis.horizontal,
                itemCount: weekDates.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final date = weekDates[index];
                  final isToday = DateUtils.dateOnly(date) == DateUtils.dateOnly(now);
                  final bool isBeforeToday = date.isBefore(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day));


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
            ..._mealCards,
          ],
        ),
        
        ) // subtle bluish background
        
      ),
      floatingActionButton: FloatingActionButton(
        onPressed:  _showAddEntryBottomSheet,
        tooltip: 'Add Favorite Activity',
        child: const Icon(Icons.add),
    ),
    );
  }
 /// Dummy data for the cards
  List<Widget> get _mealCards {
    final meals = [
      ('Breakfast', 'Recommended 483-717 kcal'),
      ('Lunch', 'Recommended 516-870 kcal'),
      ('Snack', 'Recommended 203-370 kcal'),
      ('Dinner', 'Recommended 500-810 kcal'),
    ];

    return List.generate(meals.length, (i) {
      final (title, subtitle) = meals[i];
      final imgPath = 'assets/images/food${i + 1}.jpg'; // food1.png to food4.png
      return Padding(
        padding: const EdgeInsets.fromLTRB(15,5,15,5),
        child: MealCard(
          title: title,
          subtitle: subtitle,
          imageUrl: imgPath,
          imageOnRight: i.isEven, // even = right, odd = left

        ),
      );
    });
  }
}

/// ──────────────────────── INDIVIDUAL DAY CHIP ────────────────────────
class DayChip extends StatelessWidget {
  const DayChip({required this.date, required this.isToday, super.key});

  final DateTime date;
  final bool isToday;

  @override
  Widget build(BuildContext context) {
    final purple = Theme.of(context).primaryColor;
    return Column(
      children: [
        Padding(padding: const EdgeInsets.only(top: 10.0)),
        Text(
          DateFormat('E').format(date).toUpperCase(), // MON, TUE …
          style: const TextStyle(fontSize: 18,color: Colors.grey),
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
            border: Border.all(
              color: Colors.transparent,
              width: 2,
            ),
          ),
          alignment: Alignment.center,
          child:Padding(padding: const EdgeInsets.only(top: 1.0),child: Text(
            '${date.day}',
            style: TextStyle(
              color: isToday ? const Color.fromARGB(255, 56, 34, 223) : Colors.black,
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
          ),
          )
          
        ),
      ],
    );
  }
}

/// ─────────────────────────── MEAL CARD ───────────────────────────────
/// a few deterministic pic ids so the images stay stable
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
    const double imageWidth=180;

    // decide which corner to round
final BorderRadius imgRadius = imageOnRight
    // image is on the right  → round its bottom-left corner
    ? const BorderRadius.only(bottomLeft: Radius.circular(60),topRight:Radius.circular(60),bottomRight: Radius.circular(20) )
    // image is on the left   → round its top-left corner
    : const BorderRadius.only(topRight: Radius.circular(60));

final imageWidget = Positioned(
  right: imageOnRight ? -imageSize / 2 : null,
  left: imageOnRight ? null : -imageSize / 2,
  child: ClipRRect(
    borderRadius: imgRadius,          // 👈  selective corner radius
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
          BoxShadow(
            offset: Offset(0, 4),
            blurRadius: 12,
            color: Colors.black12,
          )
        ],
      ),
      child: Row(
        mainAxisAlignment:
            imageOnRight ? MainAxisAlignment.start : MainAxisAlignment.end,
        children: [
          SizedBox(
            width: 180,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6C63FF),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(60, 32),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
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
      children: [
        content,
        imageWidget,
      ],
    ),
  );


  }

}
