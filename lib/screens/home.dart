import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'camerascreen.dart'; // CameraScreen 파일을 import
import 'timerscreen.dart';
import 'fasting_timer_service.dart';
import 'fastingtimerscreen.dart';
import 'notificationsettingsscreen.dart';

class HomePage extends StatefulWidget {
  HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.week;
  int _selectedIndex = 0; // BottomNavigationBar의 선택된 인덱스
  late FastingTimerService _fastingTimerService;
  // 저속 노화 평균 점수와 총 칼로리 섭취량 변수
  double _antiAgingScore = 0.6; // 초기값: 0.6 (60%) // 추후에 총점수 받아 변경
  int _calorieValue = 2200; // 초기 칼로리 값, 추후에 칼로리 값을 정보로 받아 변경
  int _maxCalorieValue = 2500; // 최대 칼로리 값

  @override
    void initState() {
      super.initState();
      _fastingTimerService = FastingTimerService();
    }


void _onItemTapped(int index) async {
  if (index == 1) {
    // Navigate to CameraScreen
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CameraScreen()),
    );

    if (result != null) {
      setState(() {
        _selectedIndex = result;
      });
    }
  } else if (index == 2) {
    // Navigate to TimerScreen
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TimerScreen()),
    );

    if (result != null) {
      setState(() {
        _selectedIndex = result;
      });
    }
  } else {
    setState(() {
      _selectedIndex = index;
    });
  }
}



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Top section with purple background and calendar
            Stack(
              clipBehavior: Clip.none,
              children: [
                // 배경을 캘린더 색상으로 설정
                Container(
                  width: double.infinity,
                  color: const Color(0xff6d7ccf), // 캘린더 색상
                  padding: const EdgeInsets.only(top: 40.0, bottom: 20.0),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '기록',
                              style: TextStyle(
                                fontSize: 25,
                                color: Colors.white,
                                fontFamily: 'Inter-ExtraBold',
                              ),
                            ),
                            Row(
                              children: [
                                InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => NotificationSettingsScreen(),
                                      ),
                                    );
                                  },
                                  child: Icon(Icons.notifications, color: Colors.white),
                                ),
                                SizedBox(width: 20),
                                Icon(Icons.menu, color: Colors.white),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 10), // 캘린더 위쪽 여백
                      _buildCalendar(),
                      SizedBox(height: 10), // 캘린더와 대시보드 사이의 추가 여백
                    ],
                  ),
                ),
                // 대시보드 배경 처리
                Positioned(
                  bottom: -20, // 캘린더 아래로 배치
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 40,
                    color: const Color(0xff6d7ccf), // 캘린더와 동일한 색상
                  ),
                ),
                // 대시보드의 둥근 모서리를 처리
                Positioned(
                  bottom: -20, // 둥근 모서리를 캘린더 아래로 배치
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(40),
                        topRight: Radius.circular(40),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Dashboard section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '대시보드',
                    style: TextStyle(fontSize: 20, color: Colors.black),
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('오늘', style: TextStyle(fontSize: 15)),
                      Icon(Icons.calendar_today),
                    ],
                  ),
                  SizedBox(height: 16),
                  _buildMealCard('아침'),
                  SizedBox(height: 10),
                  _buildMealCard('점심'),
                  SizedBox(height: 10),
                  _buildMealCard('저녁'),
                  SizedBox(height: 20),
                  _buildProgressBar('저속 노화 평균 점수', _antiAgingScore, trailingText: '${(_antiAgingScore * 100).ceil()}점'),
                  SizedBox(height: 10),
                  _buildProgressBar(
                    '총 칼로리 섭취량',
                    _calorieValue / _maxCalorieValue, // 현재 칼로리 값과 최대 칼로리 값의 비율
                    trailingText: '${_calorieValue}kcal',
                  ),
                  SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        // 점수와 칼로리를 업데이트하는 예제
                        setState(() {
                          _antiAgingScore = (_antiAgingScore + 0.1) % 1.0; // 예시: 0.1씩 증가
                          _calorieValue = (_calorieValue + 100) % (_maxCalorieValue + 1); // 예시: 100씩 증가, 최대 칼로리를 넘지 않도록
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff6d7ccf),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(33),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                      ),
                      child: Text(
                        '영양 상세정보',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (_fastingTimerService.isTimerRunning)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text('단식이 진행 중입니다!'),
                    SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FastingTimerScreen(
                              startDateTime: _fastingTimerService.startDateTime!,
                              fastingDuration: _fastingTimerService.fastingDuration!,
                            ),
                          ),
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
                        '타이머 보기',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: const Color(0xff6d7ccf), // 선택된 아이템 색상
        unselectedItemColor: Colors.grey, // 선택되지 않은 아이템 색상
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'home'),
          BottomNavigationBarItem(icon: Icon(Icons.camera_alt), label: 'camera'),
          BottomNavigationBarItem(icon: Icon(Icons.timer), label: 'timer'),
        ],
      ),
    );
  }

  Widget _buildCalendar() {
    return TableCalendar(
      firstDay: DateTime.utc(2020, 1, 1),
      lastDay: DateTime.utc(2030, 12, 31),
      focusedDay: _focusedDay,
      calendarFormat: _calendarFormat,
      onFormatChanged: (format) {
        if (_calendarFormat != format) {
          setState(() {
            _calendarFormat = format;
          });
        }
      },
      selectedDayPredicate: (day) {
        return isSameDay(_selectedDay, day);
      },
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          _selectedDay = selectedDay;
          _focusedDay = focusedDay;
        });
      },
      headerStyle: HeaderStyle(
        formatButtonVisible: true,
        titleCentered: true,
        titleTextStyle: TextStyle(color: Colors.white),
        leftChevronIcon: Icon(Icons.chevron_left, color: Colors.white),
        rightChevronIcon: Icon(Icons.chevron_right, color: Colors.white),
      ),
      calendarStyle: CalendarStyle(
        todayDecoration: BoxDecoration(
          color: Colors.blueAccent,
          shape: BoxShape.circle,
        ),
        selectedDecoration: BoxDecoration(
          color: Colors.deepPurpleAccent,
          shape: BoxShape.circle,
        ),
        weekendTextStyle: TextStyle(color: Colors.red),
        defaultTextStyle: TextStyle(color: Colors.white),
        outsideTextStyle: TextStyle(color: Colors.grey),
      ),
      daysOfWeekStyle: DaysOfWeekStyle(
        weekdayStyle: TextStyle(color: Colors.white),
        weekendStyle: TextStyle(color: Colors.red),
      ),
    );
  }

  Widget _buildMealCard(String meal, [String? subtitle, IconData? icon]) {
    return Container(
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: const Color(0xffbdd6f2),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            meal,
            style: TextStyle(fontSize: 16, color: Colors.black),
          ),
          if (subtitle != null)
            Row(
              children: [
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 12, color: Colors.black.withOpacity(0.6)),
                ),
                if (icon != null) SizedBox(width: 10),
                if (icon != null) Icon(icon, color: Colors.black),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(String label, double progress, {String? trailingText}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.black),
        ),
        SizedBox(height: 5),
        Stack(
          children: [
            Container(
              height: 18,
              decoration: BoxDecoration(
                color: const Color(0xffbdd6f2),
                borderRadius: BorderRadius.circular(60),
              ),
            ),
            Container(
              height: 18,
              width: MediaQuery.of(context).size.width * progress,
              decoration: BoxDecoration(
                color: const Color(0xff6d7ccf),
                borderRadius: BorderRadius.circular(60),
              ),
            ),
          ],
        ),
        if (trailingText != null)
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text(
              trailingText,
              style: TextStyle(fontSize: 10, color: Colors.black),
            ),
          ),
      ],
    );
  }
}
