import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'dart:async';

class FastingTimerScreen extends StatefulWidget {
  final DateTime startDate;
  final TimeOfDay startTime;
  final Duration fastingDuration;

  FastingTimerScreen({
    required this.startDate,
    required this.startTime,
    required this.fastingDuration,
  });

  @override
  _FastingTimerScreenState createState() => _FastingTimerScreenState();
}

class _FastingTimerScreenState extends State<FastingTimerScreen> {
  late Duration _remainingDuration;
  late Timer _timer;
  bool _isTimerRunning = true;

  @override
  void initState() {
    super.initState();
    _initializeTimer();
    _startTimer();
  }

  void _initializeTimer() {
    DateTime startDateTime = DateTime(
      widget.startDate.year,
      widget.startDate.month,
      widget.startDate.day,
      widget.startTime.hour,
      widget.startTime.minute,
    );
    DateTime endDateTime = startDateTime.add(widget.fastingDuration);
    _remainingDuration = endDateTime.difference(DateTime.now());
    if (_remainingDuration.isNegative) {
      _remainingDuration = Duration.zero;
      _isTimerRunning = false;
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_remainingDuration.inSeconds > 0) {
        setState(() {
          _remainingDuration -= Duration(seconds: 1);
        });
      } else {
        _timer.cancel();
        setState(() {
          _isTimerRunning = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String hours = twoDigits(duration.inHours);
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$hours:$minutes:$seconds";
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
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '지금은 단식 시간!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 24),
              CircularPercentIndicator(
                radius: screenWidth * 0.15, // Adjusted size for better visibility
                lineWidth: 15.0, // Thicker line for better appearance
                percent: _remainingDuration.inSeconds / widget.fastingDuration.inSeconds,
                center: Text(
                  _formatDuration(_remainingDuration),
                  style: TextStyle(
                    fontSize: 28, // Larger font size
                    fontWeight: FontWeight.bold,
                  ),
                ),
                backgroundColor: Colors.grey[300]!,
                progressColor: Color(0xff6d7ccf),
                circularStrokeCap: CircularStrokeCap.round, // Rounded end caps for aesthetics
              ),
              SizedBox(height: 24),
              Text(
                '${_getFormattedStartAndEndTime()}',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.black),
              ),
              SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isTimerRunning ? () => _endFasting() : null,
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

  void _endFasting() {
    setState(() {
      _timer.cancel();
      _isTimerRunning = false;
    });
  }

  String _getFormattedStartAndEndTime() {
    DateTime startDateTime = DateTime(
      widget.startDate.year,
      widget.startDate.month,
      widget.startDate.day,
      widget.startTime.hour,
      widget.startTime.minute,
    );
    DateTime endDateTime = startDateTime.add(widget.fastingDuration);
    return '${_formatDateTime(startDateTime)} ~ ${_formatDateTime(endDateTime)}\n${widget.fastingDuration.inHours}시간 ${widget.fastingDuration.inMinutes}분';
  }

  String _formatDateTime(DateTime dateTime) {
    String period = dateTime.hour >= 12 ? '오후' : '오전';
    int hour = dateTime.hour > 12 ? dateTime.hour - 12 : dateTime.hour;
    hour = hour == 0 ? 12 : hour;
    return '${_getDayOfWeek(dateTime.weekday)} ${period} $hour:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _getDayOfWeek(int weekday) {
    const days = ['월', '화', '수', '목', '금', '토', '일'];
    return days[weekday - 1];
  }
}
