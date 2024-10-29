import 'package:flutter/material.dart';
import 'screens/login.dart';
import 'screens/signup.dart';
import 'screens/home.dart';
import 'screens/camerascreen.dart';
import 'screens/timerscreen.dart';

void main() {
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
      },
    );
  }
}
