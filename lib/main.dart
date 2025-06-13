import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:app_links/app_links.dart';

void main() => runApp(MyApp());

const clientId = '23QK4J';
const clientSecret = 'ea6c9f286ccd9d6c8b7a377f3e1f772d';
const redirectUri = 'com.example.loginwithfitbit://fitbit/callback';

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _appLinks = AppLinks();
  String? _accessToken;
  String? _statusMessage = 'Not logged in';

  @override
  void initState() {
    super.initState();
    _listenForDeepLinks();
  }

  void _listenForDeepLinks() {
    _appLinks.uriLinkStream.listen((uri) {
      final code = uri.queryParameters['code'];
      if (code != null) {
        _exchangeCodeForToken(code);
      }
    });
  }

  Future<void> _loginWithFitbit() async {
    final authUri = Uri.parse(
      'https://www.fitbit.com/oauth2/authorize'
          '?response_type=code'
          '&client_id=$clientId'
          '&redirect_uri=$redirectUri'
          '&scope=profile'
          '&expires_in=604800',
    );
    if (await canLaunchUrl(authUri)) {
      await launchUrl(authUri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _exchangeCodeForToken(String code) async {
    final basicAuth = base64Encode(utf8.encode('$clientId:$clientSecret'));

    final response = await http.post(
      Uri.parse('https://api.fitbit.com/oauth2/token'),
      headers: {
        'Authorization': 'Basic $basicAuth',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'client_id': clientId,
        'grant_type': 'authorization_code',
        'redirect_uri': redirectUri,
        'code': code,
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        _accessToken = data['access_token'];
        _statusMessage = 'Logged in successfully';
      });
      print('Access Token: $_accessToken');
    } else {
      setState(() => _statusMessage = 'Login failed');
      print('Token exchange failed: ${response.body}');
    }
  }

  Future<void> _getProfile() async {
    if (_accessToken == null) return;

    final response = await http.get(
      Uri.parse('https://api.fitbit.com/1/user/-/profile.json'),
      headers: {
        'Authorization': 'Bearer $_accessToken',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final user = data['user'];
      setState(() {
        _statusMessage = 'Profile: ${user['fullName']} (${user['age']} y/o)';
      });
      print('User profile: $user');
    } else {
      setState(() => _statusMessage = 'Failed to get profile');
      print('Profile error: ${response.body}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('Fitbit Profile')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_statusMessage ?? ''),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _loginWithFitbit,
                child: Text('Login with Fitbit'),
              ),
              if (_accessToken != null)
                ElevatedButton(
                  onPressed: _getProfile,
                  child: Text('Get Profile Info'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
