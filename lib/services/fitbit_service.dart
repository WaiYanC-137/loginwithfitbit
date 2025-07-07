import 'dart:async';
import 'dart:convert';
import 'package:flutter/gestures.dart';
import 'package:http/http.dart' as http;
import 'package:loginwithfitbit/model/activity.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  List<Activity> _activities = []; // Stores the fetched activity data
  bool _isLoading = false; // Indicates if data is currently being fetched
  String? _errorMessage; // Stores error messages if API call fails

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

      // Save token
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('fitbitAccessToken', accessToken!);
      return true;
    }

    print('Auth failed: ${response.body}');
    return false;
  }


  Future<Map<String, dynamic>?> getProfile() async {
    if (accessToken == null) return null;
     print("Profile...$accessToken");

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

  //getAllActivitiesFromFitbitDatabase
  Future<List<Activity>> getAllActivitiesTypes() async {
  if (accessToken == null) return [];
  try{
  final response = await http.get(
    Uri.parse('https://api.fitbit.com/1/activities.json'),
    headers: {
      'Authorization': 'Bearer $accessToken',
    },
  );
  
   if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      final List categories = jsonResponse['categories'];

      final List<Activity> allActivities = categories
          .expand((category) => category['activities'] as List)
          .map((activityJson) => Activity.fromJson(activityJson))
          .toList();

      return allActivities;
    } else {
      // Explicitly throw exception for non-200 responses
      throw Exception('Server error: ${response.statusCode}');
    }
  } catch (e) {
    // Catch and rethrow the error to be handled in the UI
    throw Exception('Failed to fetch activities: $e');
  }
 }

  Future<List<Map<String, dynamic>>> getRecentFoodLogs() async {
    if (accessToken == null) return [];

    final response = await http.get(
      Uri.parse('https://api.fitbit.com/1/user/-/foods/log/recent.json'),
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data);
    }

    print('Recent foods error: ${response.body}');
    return [];
  }

  
  Future<List<Map<String, dynamic>>> getFrequentFoodLogs() async {
    if (accessToken == null) return [];

    final response = await http.get(
      Uri.parse('https://api.fitbit.com/1/user/-/foods/log/frequent.json'),
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data);
    }

    print('Frequent foods error: ${response.body}');
    return [];
  }
  Future<Activity> createActivityLog({
    required String activityId,
    required String manualCalories,
    required String startTime,        // HH:mm format
    required String durationMillis,   // e.g. 600000
    required String date,             // yyyy-MM-dd
    required String distance,
  }) async {   

    print("Create Activity Log...");
    print("Token:$accessToken");
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
      },
    );
    
  if (response.statusCode == 201 || response.statusCode == 200) {
    // Decode the entire response body into a Map
    final Map<String, dynamic> responseBodyMap = jsonDecode(response.body);
    print("Response Body Map:+$responseBodyMap");
    final Map<String, dynamic> activityLogData =
    responseBodyMap['activityLog'] as Map<String, dynamic>;
    final Activity activity = Activity.fromJson(activityLogData);
      return activity; // Parse the nested map into an Activity object
    } else {
      throw Exception('API response missing "activityLog" key or it\'s not a Map: ${response.body}');
  }
  
 }

  Future<List<Activity>> fetchActivityLog(
    String afterDate,
    String sort,
    String offset,
    String limit,
  ) async {
    // Construct query parameters
    final Map<String, String> queryParameters = {
      'afterDate': afterDate,
      'sort': sort,
      'offset': offset,
      'limit': limit,
    };
    // Build the URI for the Fitbit API endpoint
    final Uri uri = Uri.https(
      'api.fitbit.com',
      '/1/user/-/activities/list.json',
      queryParameters,
    );
    try {
      // Make the HTTP GET request
      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $accessToken', // Use the token
        },
      );
      // Check the response status code
      if (response.statusCode == 200) {
        // Parse the JSON response
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        // Check if the 'activities' key exists and is a list
        if (jsonResponse.containsKey('activities') && jsonResponse['activities'] is List) {
          _activities = (jsonResponse['activities'] as List)
              .map<Activity>((json) => Activity.fromJson(json))
              .toList();
          return _activities; // Success: Return the parsed list of activities
        } else {
          // Handle unexpected JSON structure (e.g., 'activities' key is missing or not a list)
          print('Error: API response missing "activities" key or it\'s not a List: ${response.body}');
          return []; // Return empty list for malformed JSON response
        }
      } else {
        // Handle non-200 status codes (e.g., 401 Unauthorized, 404 Not Found)
        print('Error fetching activity log. Status code: ${response.statusCode}, Body: ${response.body}');
        return []; // Return empty list for non-200 HTTP responses
      }
    } catch (e) {
      // Handle network or parsing exceptions (e.g., no internet, invalid JSON, etc.)
      print('Exception while fetching activity log: $e');
      return []; // Return empty list on any exception
    }
  }  
// SharedPreferences Key
  static const String _customFoodIdsKey = 'custom_food_ids';

  /// Save foodId to SharedPreferences
  Future<void> _saveCustomFoodId(int foodId) async {
    final prefs = await SharedPreferences.getInstance();
    final ids = prefs.getStringList(_customFoodIdsKey) ?? [];
    if (!ids.contains(foodId.toString())) {
      ids.add(foodId.toString());
      await prefs.setStringList(_customFoodIdsKey, ids);
    }
  }

  /// Load all saved foodIds from SharedPreferences
  Future<List<int>> _loadCustomFoodIds() async {
    final prefs = await SharedPreferences.getInstance();
    final ids = prefs.getStringList(_customFoodIdsKey) ?? [];
    return ids.map((e) => int.tryParse(e) ?? -1).where((id) => id != -1).toList();
  }

  /// Create custom food and store its foodId
  Future<bool> createCustomFood({
    required String name,
    required String description,
    required String calories,
    String defaultServingSize = '1',
    String defaultFoodMeasurementUnitId = '304',
    String formType = 'DRY',
  }) async {
    if (accessToken == null) {
      print('Access token is null!');
      return false;
    }

    final response = await http.post(
      Uri.parse('https://api.fitbit.com/1/user/-/foods.json'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Accept': 'application/json',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'name': name,
        'defaultFoodMeasurementUnitId': defaultFoodMeasurementUnitId,
        'defaultServingSize': defaultServingSize,
        'calories': calories,
        'formType': formType,
        'description': description,
      },
    );

    print('Create food response: ${response.statusCode} - ${response.body}');

    if (response.statusCode == 201 || response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final foodId = data['food']['foodId'];
      print('New food ID: $foodId');

      if (foodId != null) {
        await _saveCustomFoodId(foodId);
      }
      return true;
    }

    return false;
  }



  /// Fetch custom foods using stored foodIds
  Future<List<Map<String, String>>> getCustomFoods() async {
  if (accessToken == null) return [];

  final ids   = await _loadCustomFoodIds();
  final foods = <Map<String, String>>[];        // 👈 list that we’ll return

  for (final id in ids) {
    final response = await http.get(
      Uri.parse('https://api.fitbit.com/1/foods/$id.json'),
      headers: {'Authorization': 'Bearer $accessToken'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['food'];

      // Collect all unitIds from servings
      final unitIds = (data['servings'] as List<dynamic>? ?? [])
          .map((s) => (s['unitId'] ?? '').toString())
          .join(',');

      foods.add({
        'name'       : data['name']        ?? 'Unknown',
        'description': data['brand']       ?? '',
        'foodId'     : (data['foodId'] ?? '').toString(),
        'calories'   : (data['calories'] ?? '').toString(), // add if you need it
        'unitId'     : unitIds,
      });
    } else {
      print('Failed to fetch foodId $id: ${response.body}');
    }
  }

  return foods;                                   // 👈 don’t forget this
}

    Future<List<Map<String, String>>> getFoodUnit() async {
    if (accessToken == null) return [];
    List<Map<String, String>> foodUnit = [];
      final response = await http.get(
        Uri.parse('https://api.fitbit.com/1/foods/units.json'),
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        for (var food in data) {
           foodUnit.add({
          'id': food['id']?.toString() ?? '',
          'name': food['name'] ?? 'Unknow',
          'plural': food['plural'] ?? '',
        });
         
        }
        
      } else {
        print("Failed to fetch foodId ${response.body}");
      }
      print(foodUnit);
    return foodUnit;
  }

  // Token persistence
  Future<void> loadAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    accessToken = prefs.getString('fitbitAccessToken');
  }

  Future<List<Map<String, String>>> searchFoods(String query) async {
    if (accessToken == null) return [];

    final response = await http.get(
      Uri.parse('https://api.fitbit.com/1/foods/search.json?query=$query'),
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);

      if (data.containsKey('foods') && data['foods'] is List) {
        List<Map<String, String>> foods = [];

        for (var food in data['foods']) {
          final foodId = food['foodId']?.toString() ?? '';
          final unitId = food['unitId']?.toString() ?? '';  // Capture unitId here

          // If no unitId, assign a default one
          final finalUnitId = unitId.isEmpty ? '304' : unitId;

          foods.add({
            'foodId': foodId,
            'name': food['name'] ?? 'Unknown',
            'description': food['description'] ?? '',
            'unitId': finalUnitId,  // Add unitId (default if missing)
          });
        }

        print("Search Results: $foods");  // Debug output to show unitId for each food
        return foods;
      } else {
        print('No "foods" key found in response');
        return [];
      }
    }

    print('Search foods error: ${response.body}');
    return [];
  }

  Future<bool> logFood({
    required String foodId,
    required String amount,
    required String unitId,
    required String mealTypeId, // Add this parameter
    required String date,       // Add this parameter
  }) async {
    if (accessToken == null) return false;
    final response = await http.post(
      Uri.parse('https://api.fitbit.com/1/user/-/foods/log.json'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'foodId': foodId,
        'mealTypeId': mealTypeId, // Send the mealTypeId parameter
        'amount': amount,
        'unitId': unitId,
        'date': date,
      },
    );

    return response.statusCode == 201 || response.statusCode == 200;
  }
  //get Food Unit


  Future<bool> createFoodGoal(int calories) async {
    if (accessToken == null) return false;

    final url = Uri.parse('https://api.fitbit.com/1/user/-/foods/log/goal.json');

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'calories': calories.toString(),
      },
    );

    print("Goal Response: ${response.statusCode} - ${response.body}");
    return response.statusCode == 200;
  }
  Future<int?> getFoodGoal() async {
    if (accessToken == null) return null;

    final response = await http.get(
      Uri.parse('https://api.fitbit.com/1/user/-/foods/log/goal.json'),
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final calories = data['goals']?['calories'];
      if (calories != null) {
        return calories is int ? calories : int.tryParse(calories.toString());
      }
    }

    print('Failed to fetch food goal: ${response.body}');
    return null;
  }


}
