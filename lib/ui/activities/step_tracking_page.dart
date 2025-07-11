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
  int? _initialSteps;
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
        debugPrint("📟 Raw Steps: ${event.steps}");

        if (_initialSteps == null) {
          _initialSteps = event.steps;
          debugPrint("📍 Initial Step Set: $_initialSteps");
        }

        setState(() {
          _stepCount = event.steps - _initialSteps!;
          debugPrint("✅ Displayed Steps: $_stepCount");
        });
      },
      onError: (error) {
        debugPrint('❌ Step Count Error: $error');
      },
      onDone: () => debugPrint('✅ Step Count stream closed'),
      cancelOnError: true,
    );
  }

  void _resetSteps() {
    _initialSteps = null;
    debugPrint("🔄 Step count reset.");
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
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.stop),
                  label: const Text('Stop Tracking'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[100],
                    foregroundColor: Colors.black,
                  ),
                ),
                const SizedBox(width: 20),
                ElevatedButton.icon(
                  onPressed: _resetSteps,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reset Steps'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[100],
                    foregroundColor: Colors.black,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
