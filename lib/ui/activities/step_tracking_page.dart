import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pedometer/pedometer.dart';

class StepTrackingPage extends StatefulWidget {
  const StepTrackingPage({super.key});

  @override
  State<StepTrackingPage> createState() => _StepTrackingPageState();
}

class _StepTrackingPageState extends State<StepTrackingPage> {
  int _stepCount = 0;
  late Stream<StepCount> _stepCountStream;

  @override
  void initState() {
    super.initState();
    _requestPermissionAndInit();
  }

  Future<void> _requestPermissionAndInit() async {
    var status = await Permission.activityRecognition.status;
    if (!status.isGranted) {
      status = await Permission.activityRecognition.request();
    }

    if (status.isGranted) {
      _initPedometer();
    } else {
      debugPrint('❌ Activity recognition permission not granted');
    }
  }

  void _initPedometer() {
    _stepCountStream = Pedometer.stepCountStream;

    _stepCountStream.listen(
          (StepCount event) {
        debugPrint("🦶 Steps updated: ${event.steps}");
        setState(() {
          _stepCount = event.steps;
        });
      },
      onError: (error) {
        debugPrint('❌ Step Count Error: $error');
      },
      onDone: () => debugPrint('✅ Step Count stream closed'),
      cancelOnError: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Walking Tracker')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.directions_walk, size: 100, color: Colors.teal),
            const SizedBox(height: 20),
            Text(
              'Steps taken:',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Text(
              '$_stepCount',
              style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.stop),
              label: const Text('Stop Tracking'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[100],
                foregroundColor: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
