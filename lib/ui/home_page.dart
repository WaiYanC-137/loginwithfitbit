import 'package:flutter/material.dart';
import 'package:app_links/app_links.dart';
import '../services/fitbit_service.dart';
import 'profile_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FitbitService _fitbitService = FitbitService();
  final AppLinks _appLinks = AppLinks();
  String _status = 'Not logged in';

  @override
  void initState() {
    super.initState();
    _appLinks.uriLinkStream.listen((uri) async {
      final code = uri.queryParameters['code'];
      if (code != null) {
        final success = await _fitbitService.handleAuthCode(code);
        setState(() {
          _status = success ? 'Logged in successfully' : 'Login failed';
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
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
                  if (user != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProfilePage(fitbitService: _fitbitService),
                      ),
                    );
                  } else {
                    setState(() {
                      _status = 'Failed to get profile';
                    });
                  }
                },
                child: const Text('Get Profile Info'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
