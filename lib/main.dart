import 'package:flutter/material.dart';
import 'platform_channel.dart';
import 'package:flutter/services.dart';
import 'screens/login.dart';
import 'screens/signup.dart';
import 'screens/home.dart';
import 'screens/camerascreen.dart';
import 'screens/timerscreen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();

    // 네이티브에서 결과를 받기 위한 MethodChannel 설정
    const MethodChannel('my_sdk_channel').setMethodCallHandler((call) async {
      if (call.method == "onFoodRecognized") {
        final foodInfo = call.arguments as String;
        _showFoodInfo(foodInfo);
      }
    });
  }

  // 여러 음식 정보를 다루도록 _showFoodInfo 함수 수정
  void _showFoodInfo(String foodInfo) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Text('인식된 음식 및 영양 정보:\n$foodInfo'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App',
      initialRoute: '/',  // 초기 라우트 설정
      routes: {
        '/': (context) => LoginScreen(),  // 로그인 화면을 첫 번째 화면으로 설정
        '/signup': (context) => SignUpPage(),
        '/home': (context) => HomePage(),
        // CameraScreen으로 갈 때 'mealType'을 인자로 전달하도록 수정
        '/cameraScreen': (context) {
          final Map<String, String> arguments = ModalRoute.of(context)?.settings.arguments as Map<String, String> ?? {};
          return CameraScreen(mealType: arguments['mealType'] ?? 'Unknown');
        },
        '/timerScreen': (context) => TimerScreen(),
      },
    );
  }
}
