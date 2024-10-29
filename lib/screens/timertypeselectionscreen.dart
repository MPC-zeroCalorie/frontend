// TimerTypeSelectionScreen.dart
import 'package:flutter/material.dart';
import 'fastingplanscreen.dart'; // Import FastingPlanScreen for one-time plan
import 'weeklyfastingplanscreen.dart'; // Import WeeklyFastingPlanScreen for weekly plan

class TimerTypeSelectionScreen extends StatefulWidget {
  @override
  _TimerTypeSelectionScreenState createState() => _TimerTypeSelectionScreenState();
}

class _TimerTypeSelectionScreenState extends State<TimerTypeSelectionScreen> {
  bool _isOneTimeSelected = true; // Default to one-time plan selected

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '타이머 유형을 선택해 주세요',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 24),
            GestureDetector(
              onTap: () {
                setState(() {
                  _isOneTimeSelected = true;
                });
              },
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: _isOneTimeSelected ? const Color(0xff6d7ccf) : Colors.grey[300],
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '일회용 계획',
                      style: TextStyle(
                        color: _isOneTimeSelected ? Colors.white : Colors.black,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(
                      Icons.check_box,
                      color: _isOneTimeSelected ? Colors.white : Colors.black,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            GestureDetector(
              onTap: () {
                setState(() {
                  _isOneTimeSelected = false;
                });
              },
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: !_isOneTimeSelected ? const Color(0xff6d7ccf) : Colors.grey[300],
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '요일 반복',
                      style: TextStyle(
                        color: !_isOneTimeSelected ? Colors.white : Colors.black,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(
                      Icons.refresh,
                      color: !_isOneTimeSelected ? Colors.white : Colors.black,
                    ),
                  ],
                ),
              ),
            ),
            Spacer(),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  if (_isOneTimeSelected) {
                    // Navigate to the FastingPlanScreen if one-time plan is selected
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => FastingPlanScreen()),
                    );
                  } else {
                    // Navigate to the WeeklyFastingPlanScreen if weekly plan is selected
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => WeeklyFastingPlanScreen()),
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
                  '선택 완료',
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
}
