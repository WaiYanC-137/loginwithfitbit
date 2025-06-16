import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class FitbitService {
  static const _clientId = '23QK4J';
  static const _clientSecret = 'ea6c9f286ccd9d6c8b7a377f3e1f772d';
  static const _redirectUri = 'com.example.loginwithfitbit://fitbit/callback';

  String? accessToken;

  Uri getAuthUri() {
    return Uri.parse(
      'https://www.fitbit.com/oauth2/authorize'
          '?response_type=code'
          '&client_id=$_clientId'
          '&redirect_uri=$_redirectUri'
          '&scope=profile%20activity'
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

      // Check if the categories key exists and contains activities
      if (data['categories'] != null && data['categories'] is List) {
        List<Map<String, dynamic>> activities = [];

        // Iterate through categories and extract activities
        for (var category in data['categories']) {
          if (category['activities'] != null && category['activities'] is List) {
            activities.addAll(List<Map<String, dynamic>>.from(category['activities']));
          }
        }

        if (activities.isNotEmpty) {
          print('Fetched ${activities.length} activities');
          return activities;
        } else {
          print('No activities found in categories');
          return [];
        }
      } else {
        print('No "categories" key or not a list: $data');
        return [];
      }
    }

    print('Activities error: ${response.body}');
    return [];
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


}
