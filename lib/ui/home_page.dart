// lib/ui/home_page.dart
import 'package:flutter/material.dart';
import 'package:app_links/app_links.dart';
import 'package:loginwithfitbit/create_activity_log.dart';
import 'package:loginwithfitbit/get_activity_log.dart';
import '../services/fitbit_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FitbitService _fitbitService = FitbitService();
  final AppLinks _appLinks = AppLinks();
  String _status = 'Not logged in';
  String? accessToken;

  @override
  void initState() {
    super.initState();
    _appLinks.uriLinkStream.listen((uri) async {
      final code = uri.queryParameters['code'];
      if (code != null) {
        final success = await _fitbitService.handleAuthCode(code);
        accessToken=_fitbitService.accessToken;
        setState(() {
          _status = success ? 'Logged in successfully' : 'Login failed';
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Builder(builder: (BuildContext context){
    
     return Scaffold(
      appBar: AppBar(title: const Text('Fitbit API Demo')),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_status, textAlign: TextAlign.center),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _fitbitService.login(),
                child: const Text('Login with Fitbit'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final user = await _fitbitService.getProfile();
                  setState(() {
                    _status = user != null
                        ? 'Profile: ${user['fullName']} (${user['age']} y/o)'
                        : 'Failed to get profile';
                  });
                },
                child: const Text('Get Profile Info'),
              ),
               if (accessToken != null)
                ElevatedButton(
                    onPressed: () async {
                      // Example: Fetch user profile data
                      // You'll need to create a new method in FitbitAuthService to make API calls
                      // using the stored access token.
                      print('Fetching Activity Log data...');
                          Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) =>
                              GetActivityLog(accessToken: accessToken!),
                        ),
                      );
                      // String? profileData = await _fitbitAuthService.fetchUserProfile();
                      // if (profileData != null) {
                      //   print('User Profile: $profileData');
                      // } else {
                      //   print('Failed to fetch user profile.');
                      // }
                    },
                    child: Text('Fetch Activity Log Data'),
                  ),
               if (accessToken != null)
              ElevatedButton(
                onPressed: () async {
                  final success = await _fitbitService.addFavoriteActivity(90009);
                  setState(() {
                    _status = success ? 'Added Running to Favorites' : 'Failed to add favorite';
                  });
                },
                child: const Text('Add Running to Favorites'),
              ),
              if (accessToken != null)
              ElevatedButton(
                onPressed: () async {
                  final favorites = await _fitbitService.getFavoriteActivities();
                  setState(() {
                    _status = favorites.isNotEmpty
                        ? 'Favorites: ${favorites.join(', ')}'
                        : 'No favorites found';
                  });
                },
                child: const Text('View Favorite Activities'),
              ),
            ],
          ),
        ),
      ),
              // if(_accessToken != null){}
            floatingActionButton: accessToken != null
                ? FloatingActionButton.extended(
                    onPressed: () {
                      // Use builderContext here, which is a descendant of MaterialApp's Navigator
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) =>
                              CreateActivityLog(accessToken: accessToken!),
                        ),
                      );
                    },
                    icon: Icon(Icons.add),
                    label: const Text('Create Activity Log'),
                    backgroundColor: Colors.deepOrange, // FAB color
                    tooltip: 'Create New Activity Log',
                  )
                : null,
            floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat, // Position FAB
      );
      } 
    ));
    
  }

 }
