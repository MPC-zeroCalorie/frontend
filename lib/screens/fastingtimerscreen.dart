import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'dart:async';

class FastingTimerScreen extends StatefulWidget {
  final DateTime startDateTime; // The start time of the fasting session
  final Duration fastingDuration; // Total fasting duration

  FastingTimerScreen({
    required this.startDateTime,
    required this.fastingDuration,
  });

  @override
  _FastingTimerScreenState createState() => _FastingTimerScreenState();
}

class _FastingTimerScreenState extends State<FastingTimerScreen> {
  late Duration _remainingDuration; // Remaining time for the fasting session
  late Timer _timer; // Timer for countdown
  bool _isTimerRunning = true; // Indicates if the timer is active

  @override
  void initState() {
    super.initState();
    _initializeTimer(); // Initialize the countdown duration
    _startTimer(); // Start the timer
  }

  void _initializeTimer() {
    // Calculate end time based on startDateTime and fastingDuration
    DateTime endDateTime = widget.startDateTime.add(widget.fastingDuration);
    _remainingDuration = endDateTime.difference(DateTime.now());

    // If the calculated duration is negative, set remaining time to zero
    if (_remainingDuration.isNegative) {
      _remainingDuration = Duration.zero;
      _isTimerRunning = false;
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_remainingDuration.inSeconds > 0) {
        // Update the remaining time every second
        setState(() {
          _remainingDuration -= Duration(seconds: 1);
        });
      } else {
        // Stop the timer when the countdown ends
        _timer.cancel();
        setState(() {
          _isTimerRunning = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel(); // Cancel timer when the widget is disposed
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    // Format the duration to display as HH:MM:SS
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String hours = twoDigits(duration.inHours);
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$hours:$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width; // Get screen width

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
                radius: screenWidth * 0.2, // Increased size for better visibility
                lineWidth: 15.0, // Thicker line for appearance
                percent: (_remainingDuration.inSeconds / widget.fastingDuration.inSeconds).clamp(0.0, 1.0),
                center: Text(
                  _formatDuration(_remainingDuration),
                  style: TextStyle(
                    fontSize: 28, // Larger font size
                    fontWeight: FontWeight.bold,
                  ),
                ),
                backgroundColor: Colors.grey[300]!,
                progressColor: Color(0xff6d7ccf), // Custom progress color
                circularStrokeCap: CircularStrokeCap.round, // Rounded ends for aesthetics
              ),
              SizedBox(height: 24),
              Text(
                '${_getFormattedStartAndEndTime()}',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.black),
              ),
              SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isTimerRunning ? () => _showEndFastingConfirmation(context) : null, // Show confirmation dialog
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff6d7ccf),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(33),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
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

  void _showEndFastingConfirmation(BuildContext context) {
    // Show a confirmation dialog before ending fasting early
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('알림'),
          content: Text('지금 단식을 종료하시면\n오늘의 단식은 실패 처리됩니다\n종료하시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('취소'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                Navigator.of(context).pop(); // Navigate back to the previous screen (timer screen)
                Navigator.of(context).pop();
                Navigator.of(context).pop();
                _endFasting(); // End the fasting
              },
              child: Text('확인'),
            ),
          ],
        );
      },
    );
  }

  void _endFasting() {
    // Stop the timer and mark fasting as ended
    setState(() {
      _timer.cancel();
      _isTimerRunning = false;
    });
  }

  String _getFormattedStartAndEndTime() {
    // Format start and end times
    DateTime endDateTime = widget.startDateTime.add(widget.fastingDuration);
    return '${_formatDateTime(widget.startDateTime)} ~ ${_formatDateTime(endDateTime)}\n${widget.fastingDuration.inHours}시간 ${widget.fastingDuration.inMinutes.remainder(60)}분';
  }

  String _formatDateTime(DateTime dateTime) {
    // Format date and time to display
    String period = dateTime.hour >= 12 ? '오후' : '오전';
    int hour = dateTime.hour % 12 == 0 ? 12 : dateTime.hour % 12;
    String minute = dateTime.minute.toString().padLeft(2, '0');
    String second = dateTime.second.toString().padLeft(2, '0');
    return '${_getDayOfWeek(dateTime.weekday)} $period $hour:$minute:$second';
  }

  String _getDayOfWeek(int weekday) {
    // Return the day of the week in Korean
    const days = ['월', '화', '수', '목', '금', '토', '일'];
    return days[weekday - 1];
  }
}
