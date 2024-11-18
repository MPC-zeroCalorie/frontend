import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'fastingtimerscreen.dart'; // FastingTimerScreen을 import
import 'TimerTypeSelectionScreen.dart'; // TimerTypeSelectionScreen 파일을 import
import 'home.dart'; // 실제 HomeScreen의 경로로 변경하세요
import 'camerascreen.dart'; // 실제 CameraScreen의 경로로 변경하세요
import 'fasting_timer_service.dart'; // 추가된 부분

class TimerScreen extends StatefulWidget {
  @override
  _TimerScreenState createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  // 단식 계획 저장 변수
  List<Map<String, dynamic>> _fastingPlans = [];

  late FastingTimerService _fastingTimerService; // 추가된 부분

  @override
  void initState() {
    super.initState();
    _fastingTimerService = FastingTimerService();

    // 프레임이 그려진 후에 타이머 상태 확인 및 화면 전환
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndStartFastingTimer();
    });
  }

  Future<void> _loadFastingPlans() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // 저장된 단식 계획 불러오기
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
      setState(() {
        _fastingPlans = [
          {
            'weekday': fastingWeekday,
            'hour': fastingHour,
            'minute': fastingMinute,
            'durationHours': fastingDurationHours,
            'durationMinutes': fastingDurationMinutes,
          },
        ];
      });
    }
  }

  Future<void> _checkAndStartFastingTimer() async {
    if (_fastingTimerService.isTimerRunning) {
      // 이미 타이머가 실행 중이면 FastingTimerScreen으로 이동
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => FastingTimerScreen(
            startDateTime: _fastingTimerService.startDateTime!,
            fastingDuration: _fastingTimerService.fastingDuration!,
          ),
        ),
      );
    } else {
      await _loadFastingPlans();
    }
  }

  String _getDayOfWeek(int weekday) {
    const days = ['월', '화', '수', '목', '금', '토', '일'];
    return days[weekday - 1];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // 배경색 변경
      body: _fastingTimerService.isTimerRunning
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 40),
                  Text(
                    '단식',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '나만의 단식 시간을 설정해보세요',
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 32),
                  Container(
                    width: double.infinity,
                    // 내용에 따라 높이가 조절되도록 합니다.
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(15),
                    ),
                    padding: const EdgeInsets.all(16.0),
                    child: _fastingPlans.isNotEmpty
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '설정한 타이머',
                                style: TextStyle(fontSize: 14, color: Colors.black),
                              ),
                              SizedBox(height: 16),
                              ListView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: _fastingPlans.length,
                                itemBuilder: (context, index) {
                                  final plan = _fastingPlans[index];
                                  return ListTile(
                                    title: Text(
                                      '매주 ${_getDayOfWeek(plan['weekday'])}요일 ${plan['hour'].toString().padLeft(2, '0')}:${plan['minute'].toString().padLeft(2, '0')} 시작',
                                      style: TextStyle(fontSize: 16),
                                    ),
                                    subtitle: Text(
                                      '${plan['durationHours']}시간 ${plan['durationMinutes']}분 동안 단식',
                                    ),
                                    trailing: IconButton(
                                      icon: Icon(Icons.delete),
                                      onPressed: () {
                                        // 단식 계획 삭제
                                        _deleteFastingPlan();
                                      },
                                    ),
                                    onTap: () {
                                      // 단식 타이머 시작
                                      DateTime now = DateTime.now();
                                      DateTime startDateTime = DateTime(
                                        now.year,
                                        now.month,
                                        now.day,
                                        plan['hour'],
                                        plan['minute'],
                                      );
                                      Duration fastingDuration = Duration(
                                        hours: plan['durationHours'],
                                        minutes: plan['durationMinutes'],
                                      );

                                      // 타이머 시작
                                      _fastingTimerService.startTimer(startDateTime, fastingDuration);

                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => FastingTimerScreen(
                                            startDateTime: startDateTime,
                                            fastingDuration: fastingDuration,
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                            ],
                          )
                        : Center(
                            child: Text(
                              '설정된 단식 타이머가 없습니다.\n아래 버튼을 눌러 단식 타이머를 만들어보세요.',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 16, color: Colors.black54),
                            ),
                          ),
                  ),
                  Spacer(),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => TimerTypeSelectionScreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff6d7ccf),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(33),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                      ),
                      child: Text(
                        '+ 단식 타이머 만들기',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ),
                  SizedBox(height: 32),
                ],
              ),
            ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2,
        onTap: (index) {
          if (index == 0) {
            // 홈 화면으로 이동
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
            );
          } else if (index == 1) {
            // 카메라 화면으로 이동
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => CameraScreen()),
            );
          }
        },
        selectedItemColor: const Color(0xff6d7ccf),
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'home'),
          BottomNavigationBarItem(icon: Icon(Icons.camera_alt), label: 'camera'),
          BottomNavigationBarItem(icon: Icon(Icons.timer), label: 'timer'),
        ],
      ),
    );
  }

  // 단식 계획 삭제 함수
  void _deleteFastingPlan() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('fastingWeekday');
    await prefs.remove('fastingHour');
    await prefs.remove('fastingMinute');
    await prefs.remove('fastingDurationHours');
    await prefs.remove('fastingDurationMinutes');

    setState(() {
      _fastingPlans.clear();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('단식 계획이 삭제되었습니다.')),
    );
  }
}
