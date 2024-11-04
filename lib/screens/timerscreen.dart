import 'package:flutter/material.dart';
import 'package:mpczerocalorie/screens/home.dart';
import 'TimerTypeSelectionScreen.dart'; // TimerTypeSelectionScreen 파일을 import
import 'home.dart'; // Replace with the actual import path for HomeScreen
import 'CameraScreen.dart'; // Replace with the actual import path for CameraScreen

class TimerScreen extends StatefulWidget {
  @override
  _TimerScreenState createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 255, 255, 255),
      body: Padding(
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
              height: 250,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(15),
              ),
              padding: const EdgeInsets.all(16.0),
              child: Align(
                alignment: Alignment.topLeft,
                child: Text(
                  '설정한 타이머',
                  style: TextStyle(fontSize: 14, color: Colors.black),
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
            // Navigate to HomeScreen
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
            );
          } else if (index == 1) {
            // Navigate to CameraScreen
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
}
