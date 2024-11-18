import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationSettingsScreen extends StatefulWidget {
  @override
  _NotificationSettingsScreenState createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  bool _isNotificationEnabled = false; // 알림 상태를 저장하는 변수

  @override
  void initState() {
    super.initState();
    _loadNotificationState(); // 알림 상태 로드
  }

  // 알림 상태를 로드
  Future<void> _loadNotificationState() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isNotificationEnabled = prefs.getBool('isNotificationEnabled') ?? false;
    });
  }

  // 알림 상태를 저장
  Future<void> _saveNotificationState(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isNotificationEnabled', value);
  }

  // 알림 권한 요청 함수
  Future<void> _requestNotificationPermission() async {
    if (await Permission.notification.isDenied) {
      final status = await Permission.notification.request();
      if (status.isGranted) {
        // 권한이 허용되었을 때
        print("알림 권한이 허용되었습니다.");
        setState(() {
          _isNotificationEnabled = true;
        });
        await _saveNotificationState(true); // 상태 저장
      } else {
        // 권한이 거부되었을 때
        print("알림 권한이 거부되었습니다.");
        setState(() {
          _isNotificationEnabled = false;
        });
        await _saveNotificationState(false); // 상태 저장
      }
    } else if (await Permission.notification.isGranted) {
      // 이미 권한이 허용된 경우
      print("알림 권한이 이미 허용되었습니다.");
      setState(() {
        _isNotificationEnabled = true;
      });
      await _saveNotificationState(true); // 상태 저장
    }
  }

  // Switch 상태 변경 함수
  void _toggleNotification(bool value) {
    if (value) {
      // Switch를 켤 때 권한 요청
      _showPermissionDialog();
    } else {
      // Switch를 끌 때
      setState(() {
        _isNotificationEnabled = false;
      });
      _saveNotificationState(false); // 상태 저장
      print("알림이 비활성화되었습니다.");
    }
  }

  // 알림 권한 요청 전 다이얼로그 표시
  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('알림 권한 요청'),
          content: Text('알림 권한을 허용하시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // 다이얼로그 닫기
                setState(() {
                  _isNotificationEnabled = false;
                });
              },
              child: Text('취소', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // 다이얼로그 닫기
                _requestNotificationPermission();
              },
              child: Text('허용', style: TextStyle(color: Color(0xff6d7ccf))),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Text(
          '타이머 관리',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '타이머 알림',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '단식 타이머를 설정하고\n알림을 받아보세요',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                Switch(
                  value: _isNotificationEnabled,
                  onChanged: _toggleNotification,
                  activeColor: Color(0xff6d7ccf),
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2, // 현재 페이지 인덱스 (타이머 페이지)
        selectedItemColor: const Color(0xff6d7ccf),
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushNamed(context, '/home');
          } else if (index == 1) {
            Navigator.pushNamed(context, '/camera');
          } else if (index == 2) {
            Navigator.pushNamed(context, '/timer');
          }
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'home'),
          BottomNavigationBarItem(icon: Icon(Icons.camera_alt), label: 'camera'),
          BottomNavigationBarItem(icon: Icon(Icons.timer), label: 'timer'),
        ],
      ),
    );
  }
}
