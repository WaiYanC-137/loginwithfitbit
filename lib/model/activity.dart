class Activity {
  final int activityId;
  final int calories;
  final String description;
  final double distance;
  final int duration;
  final String name;

  Activity({
    required this.activityId,
    required this.calories,
    required this.description,
    required this.distance,
    required this.duration,
    required this.name,
  });

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      activityId: json['activityId'],
      calories: json['calories'],
      description: json['description'],
      distance: (json['distance'] as num).toDouble(),
      duration: json['duration'],
      name: json['name'],
    );
  }
}
