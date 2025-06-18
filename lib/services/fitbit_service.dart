import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:loginwithfitbit/model/activity.dart';
import 'package:url_launcher/url_launcher.dart';

class FitbitService {
  static const _clientId = '23QK4J';
  static const _clientSecret = 'ea6c9f286ccd9d6c8b7a377f3e1f772d';
  static const _redirectUri = 'com.example.loginwithfitbit://fitbit/callback';
  static const List<String> scopes = [
    'activity',
    'heartrate',
    'nutrition',
    'profile',
    'sleep',
    'weight'
  ];

  String? accessToken;
  final String encodedScopes = scopes.join('%20');

  Uri getAuthUri() {
    return Uri.parse(
      'https://www.fitbit.com/oauth2/authorize'
          '?response_type=code'
          '&client_id=$_clientId'
          '&redirect_uri=$_redirectUri'
          '&scope=$encodedScopes'
          '&expires_in=604800',
    );
  }

  Future<void> login() async {
    final uri = getAuthUri();
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<bool> handleAuthCode(String code) async {
    final basicAuth = base64Encode(utf8.encode('$_clientId:$_clientSecret'));
    final response = await http.post(
      Uri.parse('https://api.fitbit.com/oauth2/token'),
      headers: {
        'Authorization': 'Basic $basicAuth',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'client_id': _clientId,
        'grant_type': 'authorization_code',
        'redirect_uri': _redirectUri,
        'code': code,
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      accessToken = data['access_token'];
      print("Token Access");
      print(accessToken);
      return true;
    }

    print('Auth failed: ${response.body}');
    return false;
  }

  Future<Map<String, dynamic>?> getProfile() async {
    if (accessToken == null) return null;

    final response = await http.get(
      Uri.parse('https://api.fitbit.com/1/user/-/profile.json'),
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['user'];
    }

    print('Profile error: ${response.body}');
    return null;
  }

  Future<List<Map<String, dynamic>>> getAllActivities() async {
    if (accessToken == null) return [];

    final response = await http.get(
      Uri.parse('https://api.fitbit.com/1/activities.json'),
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      List<Map<String, dynamic>> activities = [];

      if (data['categories'] != null && data['categories'] is List) {
        for (var category in data['categories']) {
          if (category['activities'] != null && category['activities'] is List) {
            activities.addAll(List<Map<String, dynamic>>.from(category['activities']));
          }
        }
      }

      print('Fetched ${activities.length} activities');
      return activities;
    }

    print('Activities error: ${response.body}');
    return [];
  }

  Future<List<int>> getFavoriteActivityIds() async {
    if (accessToken == null) return [];

    final response = await http.get(
      Uri.parse('https://api.fitbit.com/1/user/-/activities/favorite.json'),
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);

      print("Favorite raw data: $data");

      return data.map<int>((item) {
        final id = item['activityId'];
        if (id is int) return id;
        if (id is String) return int.tryParse(id) ?? -1;
        return -1;
      }).where((id) => id != -1).toList();
    }

    print('Favorite activities error: ${response.body}');
    return [];
  }

  Future<bool> addFavoriteActivity(int activityId) async {
    if (accessToken == null) return false;

    final response = await http.post(
      Uri.parse('https://api.fitbit.com/1/user/-/activities/favorite/$activityId.json'),
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );

    return response.statusCode == 204 || response.statusCode == 201;
  }

  Future<bool> removeFavoriteActivity(int activityId) async {
    if (accessToken == null) return false;

    final response = await http.delete(
      Uri.parse('https://api.fitbit.com/1/user/-/activities/favorite/$activityId.json'),
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );

    return response.statusCode == 204 || response.statusCode == 201;
  }

  Future<bool> toggleFavoriteActivity(int activityId, bool isFavorite) async {
    return isFavorite
        ? await removeFavoriteActivity(activityId)
        : await addFavoriteActivity(activityId);
  }
  //Get Recent Activity Types Api
  Future<List<Activity>> getRecentActivitiesTypes() async {
    if (accessToken == null) return [];
    final response = await http.get(
      Uri.parse('https://api.fitbit.com/1/user/-/activities/recent.json'),
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((item) => Activity.fromJson(item)).toList();
    }
    print('Activities error: ${response.body}');
   return [];
  }

  //Get Frequent Activity Api
  Future<List<Activity>> getFrequentActivitiesTypes() async {
  if (accessToken == null) return [];
  final response = await http.get(
    Uri.parse('https://api.fitbit.com/1/user/-/activities/frequent.json'),
    headers: {
      'Authorization': 'Bearer $accessToken',
    },
  );
  if (response.statusCode == 200) {
    final List<dynamic> data = jsonDecode(response.body);
    return data.map((item) => Activity.fromJson(item)).toList();
  }
  print('Activities error: ${response.body}');
  return [];
}

Future<List<Activity>> createActivityLog({
    required String activityId,
    required String manualCalories,
    required String startTime,        // HH:mm format
    required String durationMillis,   // e.g. 600000
    required String date,             // yyyy-MM-dd
    required String distance,
    required String distanceUnit,     // "Kilometer" / "Mile"
  }) async {   
    
    print("Create Activity Log...");
  final response = await http.post(
      Uri.parse('https://api.fitbit.com/1/user/-/activities.json'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'activityId': activityId,
        'manualCalories': manualCalories,
        'startTime':startTime,
        'durationMillis':durationMillis,
        'date':date,
        'distance':distance,
        'distanceUnit':distanceUnit
      },
    );
    if (response.statusCode == 201 || response.statusCode == 200) {
      return jsonDecode(response.body) as Future<List<Activity>>;
    }

    throw Exception(
        'Failed (${response.statusCode}): ${response.body}');
  
  }


}
