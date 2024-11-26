import 'dart:io';
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
        // 네이티브에서 전달된 데이터 파싱
        final Map<String, dynamic> foodInfo = Map<String, dynamic>.from(call.arguments);

        // UI 업데이트
        _showFoodInfo(foodInfo);
      }
    });
  }

  // UI에 데이터를 표시하는 함수
  void _showFoodInfo(Map<String, dynamic> foodInfo) {
    showDialog(
      context: context,
      builder: (context) {
        final nutritionInfo = foodInfo['nutritionInfo'] as Map<String, dynamic>;
        final foodName = foodInfo['foodName'];
        final imagePath = foodInfo['imagePath'];

        return AlertDialog(
          title: Text('인식 결과'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('음식 이름: $foodName'),
              Text('영양 정보:'),
              ...nutritionInfo.entries.map((entry) {
                return Text('${entry.key}: ${entry.value}');
              }),
              SizedBox(height: 16),
              imagePath != null && imagePath.isNotEmpty
                  ? Image.file(File(imagePath)) // 네이티브에서 전달받은 이미지 표시
                  : Text('이미지가 없습니다.'),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App',
      initialRoute: '/', // 초기 라우트 설정
      routes: {
        '/': (context) => LoginScreen(), // 로그인 화면을 첫 번째 화면으로 설정
        '/signup': (context) => SignUpPage(),
        '/home': (context) => HomePage(),
        '/cameraScreen': (context) {
          final Map<String, String> arguments = ModalRoute.of(context)?.settings.arguments as Map<String, String>? ?? {};
          return CameraScreen();
        },
        '/timerScreen': (context) => TimerScreen(),
      },
    );
  }
}