import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:shared_preferences/shared_preferences.dart';
import 'fastingtimerscreen.dart';
import 'timerscreen.dart';

// 필요한 경우, FastingTimerScreen을 임포트하세요.
// import 'fastingtimerscreen.dart';

class WeeklyFastingPlanScreen extends StatefulWidget {
  @override
  _WeeklyFastingPlanScreenState createState() =>
      _WeeklyFastingPlanScreenState();
}

class _WeeklyFastingPlanScreenState extends State<WeeklyFastingPlanScreen> {
  DateTime? _repeatDay;
  TimeOfDay? _startTime;
  Duration? _fastingDuration;

  // 알림 플러그인 초기화
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    // Timezone 초기화
    tz.initializeTimeZones();
    var initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onDidReceiveNotificationResponse,
    );
  }

  // 알림 클릭 시 호출되는 함수
  void _onDidReceiveNotificationResponse(NotificationResponse response) async {
    if (response.payload != null) {
      // 저장된 단식 계획 불러오기 및 타이머 화면으로 이동
      await navigateToFastingTimerScreen();
    }
  }

  Future<void> navigateToFastingTimerScreen() async {
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

      // 타이머 화면으로 이동
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FastingTimerScreen(
            startDateTime: startDateTime,
            fastingDuration: fastingDuration,
          ),
        ),
      );
    } else {
      // 단식 계획이 없을 경우 처리
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('저장된 단식 계획이 없습니다.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('요일별 단식 계획', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      backgroundColor: Color.fromARGB(255, 255, 255, 255),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('요일 별 단식 계획을 설정해 주세요',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 24),
            _buildDateField('반복 요일', _repeatDay),
            SizedBox(height: 16),
            _buildTimeField('시작 시간', _startTime),
            SizedBox(height: 16),
            _buildDurationField('단식 유지 시간', _fastingDuration),
            SizedBox(height: 24),
            Center(
              child: Text(
                _repeatDay != null && _startTime != null && _fastingDuration != null
                    ? '매주 ${_getDayOfWeek(_repeatDay!.weekday)}요일마다 ${_startTime!.format(context)}에 시작하여 ${_fastingDuration!.inHours}시간 ${_fastingDuration!.inMinutes % 60}분 동안 단식합니다.'
                    : '반복 요일, 시작 시간 및 단식 유지 시간을 선택하세요.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.black),
              ),
            ),
            Spacer(),
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  if (_repeatDay != null &&
                      _startTime != null &&
                      _fastingDuration != null) {
                    // 단식 등록 기능 구현
                    await _scheduleWeeklyNotification();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('단식 계획이 등록되었습니다.')),
                    );
                    // TimerScreen으로 이동
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => TimerScreen()),
                      (route) => false,
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('모든 정보를 입력하세요')),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff6d7ccf),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(33),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                ),
                child: Text(
                  '단식 등록',
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

  Widget _buildDateField(String label, DateTime? selectedDate) {
    return GestureDetector(
      onTap: () async {
        DateTime now = DateTime.now();
        DateTime firstDate = now.subtract(Duration(days: now.weekday - 1));
        DateTime lastDate = now.add(Duration(days: 7 - now.weekday));

        DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: now,
          firstDate: firstDate,
          lastDate: lastDate,
          helpText: '요일을 선택하세요',
          selectableDayPredicate: (DateTime day) {
            return true;
          },
        );
        if (pickedDate != null) {
          setState(() {
            _repeatDay = pickedDate;
          });
        }
      },
      child: _buildTextField(
        label,
        selectedDate != null ? '${_getDayOfWeek(selectedDate.weekday)}요일' : '요일을 선택하세요',
      ),
    );
  }

  Widget _buildTimeField(String label, TimeOfDay? selectedTime) {
    return GestureDetector(
      onTap: () async {
        TimeOfDay? pickedTime = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.now(),
        );
        if (pickedTime != null) {
          setState(() {
            _startTime = pickedTime;
          });
        }
      },
      child: _buildTextField(
        label,
        selectedTime != null ? selectedTime.format(context) : '시간을 선택하세요',
      ),
    );
  }

  Widget _buildDurationField(String label, Duration? duration) {
    return GestureDetector(
      onTap: () {
        _showDurationPicker();
      },
      child: _buildTextField(
        label,
        duration != null
            ? '${duration.inHours}시간 ${duration.inMinutes % 60}분'
            : '유지 시간을 선택하세요',
      ),
    );
  }

  Widget _buildTextField(String label, String text) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(15),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 16, color: Colors.black54),
        textAlign: TextAlign.center,
      ),
    );
  }

  String _getDayOfWeek(int weekday) {
    const days = ['월', '화', '수', '목', '금', '토', '일'];
    return days[weekday - 1];
  }

  void _showDurationPicker() {
    int hours = _fastingDuration?.inHours ?? 0;
    int minutes = _fastingDuration?.inMinutes.remainder(60) ?? 0;
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              height: 250,
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(
                    '단식 유지 시간 선택',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      NumberPicker(
                        initialValue: hours,
                        minValue: 0,
                        maxValue: 23,
                        onChanged: (value) {
                          setModalState(() {
                            hours = value;
                          });
                        },
                      ),
                      Text('시간'),
                      SizedBox(width: 16),
                      NumberPicker(
                        initialValue: minutes,
                        minValue: 0,
                        maxValue: 59,
                        onChanged: (value) {
                          setModalState(() {
                            minutes = value;
                          });
                        },
                      ),
                      Text('분'),
                    ],
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _fastingDuration = Duration(hours: hours, minutes: minutes);
                      });
                      Navigator.pop(context);
                    },
                    child: Text('확인'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

   Future<void> _scheduleWeeklyNotification() async {
    // 선택한 요일과 시간을 기반으로 다음 알림 시간을 계산
    final now = DateTime.now();
    int selectedWeekday = _repeatDay!.weekday; // 월요일: 1, 일요일: 7
    int daysDifference = (selectedWeekday - now.weekday) % 7;
    if (daysDifference == 0 && now.isAfter(_getNextOccurrenceTime())) {
      daysDifference = 7;
    }

    DateTime nextNotificationDate = _getNextOccurrenceTime().add(
      Duration(days: daysDifference),
    );

    // 알림 스케줄링
    await flutterLocalNotificationsPlugin.zonedSchedule(
      0, // 알림 ID
      '단식 시간입니다!',
      '지금부터 단식이 시작됩니다.',
      tz.TZDateTime.from(nextNotificationDate, tz.local),
      NotificationDetails(
        android: AndroidNotificationDetails(
          'fasting_channel',
          '단식 알림',
          channelDescription: '단식 시작을 알리는 알림입니다.',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      payload: 'fasting_timer',
    );

    // 단식 계획 저장
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('fastingWeekday', _repeatDay!.weekday);
    await prefs.setInt('fastingHour', _startTime!.hour);
    await prefs.setInt('fastingMinute', _startTime!.minute);
    await prefs.setInt('fastingDurationHours', _fastingDuration!.inHours);
    await prefs.setInt(
        'fastingDurationMinutes', _fastingDuration!.inMinutes.remainder(60));
  }

  DateTime _getNextOccurrenceTime() {
    return DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
      _startTime!.hour,
      _startTime!.minute,
    );
  }
}

// NumberPicker 위젯
class NumberPicker extends StatelessWidget {
  final int initialValue;
  final int minValue;
  final int maxValue;
  final ValueChanged<int> onChanged;

  NumberPicker({
    required this.initialValue,
    required this.minValue,
    required this.maxValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButton<int>(
      value: initialValue,
      items: List.generate(maxValue - minValue + 1, (index) {
        int value = minValue + index;
        return DropdownMenuItem<int>(
          value: value,
          child: Text(value.toString()),
        );
      }),
      onChanged: (value) {
        if (value != null) {
          onChanged(value);
        }
      },
    );
  }
}
