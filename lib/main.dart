import 'package:flutter/material.dart';
import 'screens/login.dart';
import 'screens/signup.dart';
import 'screens/home.dart';
import 'screens/camerascreen.dart';
import 'screens/timerscreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/fastingtimerscreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await checkAndNavigateToFastingTimer();
  runApp(MyApp());
}

Future<void> checkAndNavigateToFastingTimer() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  int? fastingWeekday = prefs.getInt('fastingWeekday');
  int? fastingHour = prefs.getInt('fastingHour');
  int? fastingMinute = prefs.getInt('fastingMinute');
  int? fastingDurationHours = prefs.getInt('fastingDurationHours');
  int? fastingDurationMinutes = prefs.getInt('fastingDurationMinutes');

  if (fastingWeekday != null &&
      fastingHour != null &&
      fastingMinute != null &&
      fastingDurationHours != null &&
      fastingDurationMinutes != null) {
    DateTime now = DateTime.now();
    if (now.weekday == fastingWeekday) {
      DateTime startDateTime = DateTime(
        now.year,
        now.month,
        now.day,
        fastingHour,
        fastingMinute,
      );
      Duration fastingDuration = Duration(
        hours: fastingDurationHours,
        minutes: fastingDurationMinutes,
      );
      DateTime endDateTime = startDateTime.add(fastingDuration);

      if (now.isAfter(startDateTime) && now.isBefore(endDateTime)) {
        // 타이머 화면으로 이동해야 함
        runApp(MaterialApp(
          home: FastingTimerScreen(
            startDateTime: startDateTime,
            fastingDuration: fastingDuration,
          ),
        ));
        return;
      }
    }
  }

  // 기본 앱 실행
  runApp(MyApp());
}



class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App',
      initialRoute: '/',
      routes: {
        '/': (context) => LoginScreen(),
        '/singup' : (context) => SignUpPage(),
        '/home': (context) => HomePage(), // HomeScreen 추가 후 활성화
        '/cameraScreen' : (context) => CameraScreen(),
        '/timerScreen' : (context) => TimerScreen(),
        '/fastingTimer': (context) => FastingTimerScreen(
              startDateTime: DateTime.now(),
              fastingDuration: Duration(hours: 0), // 기본값 설정
            ),
      },
    );
  }
}
