// fastingtimerscreen.dart

import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'dart:async';
import 'home.dart';
import 'camerascreen.dart';
import 'timerscreen.dart';
import 'fasting_timer_service.dart';

class FastingTimerScreen extends StatefulWidget {
  final DateTime startDateTime;
  final Duration fastingDuration;

  FastingTimerScreen({
    required this.startDateTime,
    required this.fastingDuration,
  });

  @override
  _FastingTimerScreenState createState() => _FastingTimerScreenState();
}

class _FastingTimerScreenState extends State<FastingTimerScreen> {
  late FastingTimerService _fastingTimerService;
  StreamSubscription<Duration>? _subscription;
  Duration _remainingDuration = Duration.zero;
  bool _isTimerRunning = true;

  @override
  void initState() {
    super.initState();
    _fastingTimerService = FastingTimerService();

    if (!_fastingTimerService.isTimerRunning) {
      // 타이머가 시작되지 않았다면 시작
      _fastingTimerService.startTimer(widget.startDateTime, widget.fastingDuration);
    }

    _remainingDuration = _fastingTimerService.remainingDuration ?? Duration.zero;
    _isTimerRunning = _fastingTimerService.isTimerRunning;

    // 타이머의 남은 시간을 수신하기 위해 구독
    _subscription = _fastingTimerService.remainingTimeStream.listen((duration) {
      setState(() {
        _remainingDuration = duration;
        if (_remainingDuration == Duration.zero) {
          _isTimerRunning = false;
        }
      });
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String hours = twoDigits(duration.inHours);
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$hours:$minutes:$seconds";
  }

  void _showEndFastingConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('단식 종료'),
          content: Text(
            '지금 단식을 종료하시면\n오늘의 단식은 실패 처리됩니다\n종료하시겠습니까?',
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // 다이얼로그 닫기
              },
              child: Text('취소', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // 다이얼로그 닫기
                _endFasting(); // 단식 종료 처리
              },
              child: Text('확인', style: TextStyle(color: Color(0xff6d7ccf))),
            ),
          ],
        );
      },
    );
  }

  void _endFasting() {
    _fastingTimerService.stopTimer();
    setState(() {
      _isTimerRunning = false;
      _remainingDuration = Duration.zero;
    });
  }

  String _getFormattedStartAndEndTime() {
    DateTime endDateTime = widget.startDateTime.add(widget.fastingDuration);
    return '${_formatDateTime(widget.startDateTime)} ~ ${_formatDateTime(endDateTime)}\n${widget.fastingDuration.inHours}시간 ${widget.fastingDuration.inMinutes.remainder(60)}분';
  }

  String _formatDateTime(DateTime dateTime) {
    String period = dateTime.hour >= 12 ? '오후' : '오전';
    int hour = dateTime.hour % 12 == 0 ? 12 : dateTime.hour % 12;
    String minute = dateTime.minute.toString().padLeft(2, '0');
    String second = dateTime.second.toString().padLeft(2, '0');
    return '${_getDayOfWeek(dateTime.weekday)} $period $hour:$minute:$second';
  }

  String _getDayOfWeek(int weekday) {
    const days = ['월', '화', '수', '목', '금', '토', '일'];
    return days[weekday - 1];
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text('단식', style: TextStyle(color: Colors.black)),
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _isTimerRunning ? '지금은 단식 시간!' : '단식이 종료되었습니다',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 24),
              CircularPercentIndicator(
                radius: screenWidth * 0.2,
                lineWidth: 15.0,
                percent: (_remainingDuration.inSeconds /
                        widget.fastingDuration.inSeconds)
                    .clamp(0.0, 1.0),
                center: Text(
                  _formatDuration(_remainingDuration),
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                backgroundColor: Colors.grey[300]!,
                progressColor: Color(0xff6d7ccf),
                circularStrokeCap: CircularStrokeCap.round,
              ),
              SizedBox(height: 24),
              Text(
                '${_getFormattedStartAndEndTime()}',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.black),
              ),
              SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isTimerRunning ? _showEndFastingConfirmation : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff6d7ccf),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(33),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                ),
                child: Text(
                  '단식 종료',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2, // 현재 페이지 인덱스 (타이머 페이지)
        selectedItemColor: const Color(0xff6d7ccf),
        unselectedItemColor: Colors.grey,
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
          } else if (index == 2) {
            // 타이머 화면으로 이동
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => TimerScreen()),
            );
          }
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.camera_alt), label: 'camera'),
          BottomNavigationBarItem(icon: Icon(Icons.timer), label: 'timer'),
        ],
      ),
    );
  }
}
