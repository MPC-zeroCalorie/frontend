import 'dart:convert';
import 'mealdetailscreen.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'camerascreen.dart'; // CameraScreen 파일 import
import 'timerscreen.dart'; // TimerScreen 파일 import
import 'dart:io'; // 이미지 파일을 사용하기 위해 추가
import 'package:shared_preferences/shared_preferences.dart'; // SharedPreferences import 추가
import 'package:http/http.dart' as http; // HTTP 요청을 위해 추가

class HomePage extends StatefulWidget {
  HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.week;
  int _selectedIndex = 0;
  String? _userToken;
  double _antiAgingScore = 0.0; // 저속 노화 평균 점수 초기값
  int _calorieValue = 0; // 총 칼로리 섭취량 초기값
  int _maxCalorieValue = 2500; // 최대 칼로리 섭취량 (변경 없음)
  final String _calculateDailyScoreUrl = 'https://calculatedailyscore-4zs2rshoda-uc.a.run.app'; // API URL

  // 각 식사별 데이터를 저장할 변수
  Map<String, Map<String, dynamic>> _mealData = {
    '아침': {'image': null, 'food': '등록된 음식 없음'},
    '점심': {'image': null, 'food': '등록된 음식 없음'},
    '저녁': {'image': null, 'food': '등록된 음식 없음'},
  };
  @override
  void initState() {
    super.initState();
    _loadUserToken();
  }
  Future<void> _loadUserToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _userToken = prefs.getString('token');
      print("Loaded user token: $_userToken");
    });
  }
Future<void> _calculateDailySlowAgingScore() async {
  String date = DateTime.now().toIso8601String().split('T')[0];

  if (_userToken == null || _userToken!.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('로그인이 필요합니다.')),
    );
    return;
  }

  try {
    final response = await http.post(
      Uri.parse(_calculateDailyScoreUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_userToken',
      },
      body: jsonEncode({'date': date}),
    );

    print("Daily score response status: ${response.statusCode}");
    print("Daily score response body: ${response.body}");

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      setState(() {
        _antiAgingScore = (responseBody['dailySlowAgingScore'] as num).toDouble() / 100.0;
      });
    } else {
      final responseBody = jsonDecode(response.body);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('일간 점수 계산 오류: ${responseBody['message']}')),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('네트워크 오류 발생: $e')),
    );
  }
}

  void _onItemTapped(int index) async {
    if (index == 1) {
      // CameraScreen으로 이동
        final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CameraScreen(),
        ),
    );
    if (result != null && result is Map<String, dynamic>) {
      String mealType = result['mealType'] ?? '아침'; // 기본값 설정
      setState(() {
        _mealData[mealType] = {
          'image': result['imagePath'] != null ? File(result['imagePath']) : null,
          'food': result['food'] ?? '등록된 음식 없음',
        };
        // 칼로리 값 누적
        int energy = (result['energy'] as num?)?.toInt() ?? 0;
        _calorieValue += energy;
      });
      // 일간 저속 노화 점수 계산 API 호출
      await _calculateDailySlowAgingScore();
      }
    } else if (index == 2) {
      // TimerScreen으로 이동
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TimerScreen(),
        ),
      );
    }

    setState(() {
      _selectedIndex = index;
    });
  }

  // CameraScreen으로 이동하여 데이터를 받아오는 함수
Future<void> _navigateToCamera(String mealType) async {
  final result = await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => CameraScreen(),
    ),
  );

  if (result != null && result is Map<String, dynamic>) {
    String returnedMealType = result['mealType'] ?? mealType; // 반환된 mealType 사용
    setState(() {
      _mealData[returnedMealType] = {
        'image': result['imagePath'] != null ? File(result['imagePath']) : null,
        'nutritionInfo': result['nutritionInfo'] ?? {},
        'antiAgingScore': result['antiAgingScore'] ?? 0.0,
        'food': result['food'] ?? '등록된 음식 없음',
      };
      // 칼로리 값 누적
      int energy = (result['energy'] as num?)?.toInt() ?? 0;
      _calorieValue += energy;
    });
    // 일간 저속 노화 점수 계산 API 호출
    await _calculateDailySlowAgingScore();
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: double.infinity,
                  color: const Color(0xff6d7ccf),
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
                                Icon(Icons.notifications, color: Colors.white),
                                SizedBox(width: 20),
                                Icon(Icons.menu, color: Colors.white),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 10),
                      _buildCalendar(),
                      SizedBox(height: 10),
                    ],
                  ),
                ),
                Positioned(
                  bottom: -20,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 40,
                    color: const Color(0xff6d7ccf),
                  ),
                ),
                Positioned(
                  bottom: -20,
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
                    _calorieValue / _maxCalorieValue,
                    trailingText: '${_calorieValue}kcal',
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

Widget _buildMealCard(String mealType) {
  final mealData = _mealData[mealType];

  return GestureDetector(
    onTap: () {
      if (mealData != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MealDetailScreen(
              mealType: mealType,
              image: mealData['image'],
              nutritionInfo: mealData['nutritionInfo'],
              antiAgingScore: mealData['antiAgingScore'],
            ),
          ),
        );
      }
    },
    child: Container(
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: const Color(0xffbdd6f2),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  mealType,
                  style: TextStyle(fontSize: 16, color: Colors.black),
                ),
                SizedBox(height: 8),
                Text(
                  mealData?['food'] ?? '등록된 음식 없음',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (mealData?['image'] != null)
            Image.file(
              mealData!['image'],
              width: 60,
              height: 60,
              fit: BoxFit.cover,
            ),
        ],
      ),
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
