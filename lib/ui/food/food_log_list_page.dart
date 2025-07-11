import 'package:flutter/material.dart';
import 'package:loginwithfitbit/services/fitbit_service.dart';

class FoodLogListPage extends StatefulWidget {
  const FoodLogListPage({super.key});

  @override
  State<FoodLogListPage> createState() => _FoodLogListPageState();
}

class _FoodLogListPageState extends State<FoodLogListPage> {
  final FitbitService fitbitService = FitbitService();
  List<Map<String, dynamic>> _logs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  Future<void> _loadLogs() async {
    await fitbitService.loadAccessToken();
    final logs = await fitbitService.getTodayFoodLogs();
    setState(() {
      _logs = logs;
      _isLoading = false;
    });
  }

  Future<void> _deleteLog(String logId) async {
    try {
      await fitbitService.deleteFoodLog(logId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Deleted successfully.')),
      );
      _loadLogs(); // refresh list
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Today's Food Logs"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _logs.isEmpty
          ? const Center(child: Text('No food logged today.'))
          : ListView.builder(
        itemCount: _logs.length,
        itemBuilder: (context, index) {
          final log = _logs[index];
          final logId = log['logId'].toString(); // required for delete

          return ListTile(
            title: Text(log['loggedFood']?['name'] ?? 'Unknown'),
            subtitle: Text('${log['loggedFood']?['calories'] ?? '?'} cal'),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                _deleteLog(logId);
              },
            ),
          );
        },
      ),
    );
  }
}
