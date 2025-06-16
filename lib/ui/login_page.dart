import 'package:flutter/material.dart';
import 'package:app_links/app_links.dart';
import '../services/fitbit_service.dart';
import 'profile_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FitbitService _fitbitService = FitbitService();
  final AppLinks _appLinks = AppLinks();
  String _status = '';

  // Controllers for text fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _appLinks.uriLinkStream.listen((uri) async {
      final code = uri.queryParameters['code'];
      if (code != null) {
        final success = await _fitbitService.handleAuthCode(code);
        if (success && mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => ProfilePage(fitbitService: _fitbitService),
            ),
          );
        } else {
          setState(() => _status = 'Login failed');
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Name TextField
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                const SizedBox(height: 10),

                // Password TextField
                TextField(
                  controller: _passwordController,
                  decoration: const InputDecoration(labelText: 'Password'),
                  obscureText: true,
                ),
                const SizedBox(height: 20),

                // Login with Google Button (does nothing)
                ElevatedButton(
                  onPressed: () {
                    // Placeholder for UI only
                  },
                  child: const Text('Login with Google'),
                ),
                const SizedBox(height: 10),

                // Login with Fitbit Button (works)
                ElevatedButton(
                  onPressed: () => _fitbitService.login(),
                  child: const Text('Login with Fitbit'),
                ),
                const SizedBox(height: 20),

                // Display status message
                Text(_status, style: const TextStyle(color: Colors.red)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
