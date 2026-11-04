import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'theme/app_theme.dart';
import 'providers/app_state_provider.dart';
import 'services/notification_service.dart';
import 'screens/splash/splash_screen.dart';

final RouteObserver<ModalRoute<void>> routeObserver = RouteObserver<ModalRoute<void>>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase initialization notice: $e');
  }
  try {
    await NotificationService().init();
  } catch (e) {
    debugPrint('Notification initialization notice: $e');
  }
  runApp(const SpeedMathApp());
}

class SpeedMathApp extends StatefulWidget {
  const SpeedMathApp({super.key});

  @override
  State<SpeedMathApp> createState() => _SpeedMathAppState();
}

class _SpeedMathAppState extends State<SpeedMathApp> with WidgetsBindingObserver {
  // Track if app was actually in background (not just inactive/paused briefly)
  bool _wasInBackground = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      // App genuinely going to background: schedule hourly reminder
      _wasInBackground = true;
      NotificationService().scheduleHourlyCalculationReminder();
    } else if (state == AppLifecycleState.resumed) {
      // App returned from background: only THEN re-schedule past-due reminders
      // Do NOT post notifications here — that would fire them while app is open.
      // Dart timers and zonedSchedule handle the actual posting when app is closed.
      if (_wasInBackground) {
        _wasInBackground = false;
        // Only re-register the scheduled alarms (does NOT call show() immediately)
        NotificationService().rescheduleAllPendingMistakeAlarms();
      }
    } else if (state == AppLifecycleState.detached) {
      _wasInBackground = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppStateProvider()),
      ],
      child: Selector<AppStateProvider, bool>(
        selector: (_, state) => state.amoledBlackMode,
        builder: (context, amoledMode, _) {
          return MaterialApp(
            navigatorKey: NotificationService.navigatorKey,
            navigatorObservers: [routeObserver],
            title: 'PrepVanta',
            debugShowCheckedModeBanner: false,
            theme: amoledMode ? AppTheme.amoledTheme : AppTheme.darkTheme,
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
