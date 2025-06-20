class Activity {
  final int activityTypeId;        // renamed
  final int calories;
  final String description;
  final double distance;
  final int duration;
  final String name;
  final String startTime;
  final String logId;
  final String startDate;

  Activity({
    required this.activityTypeId,
    required this.calories,
    required this.description,
    required this.distance,
    required this.duration,
    required this.name,
    required this.startTime,
    required this.logId,
    required this.startDate,
  });

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      activityTypeId: (json['activityId'] ?? 0) as int,
      calories: (json['calories'] ?? 0) as int,
      description: json['description']?.toString() ?? '',
      distance: (json['distance'] as num?)?.toDouble() ?? 0.0,
      duration: (json['duration'] ?? 0) as int,
      name: json['activityName']?.toString()            // ← Fitbit uses activityName
            ?? json['name']?.toString()
            ?? '',
      startTime: json['startTime']?.toString() ?? '00:00',
      logId: json['logId']?.toString() ?? 'no_log_id',
      startDate: json['startDate']?.toString() ?? '00:00',
    );
  }

  @override
  String toString() => 'Activity('
      'activityTypeId: $activityTypeId, name: $name, '
      'calories: $calories, duration: $duration, startTime: $startTime, '
      'logId: $logId)';
}
