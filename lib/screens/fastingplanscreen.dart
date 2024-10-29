import 'package:flutter/material.dart';

class FastingPlanScreen extends StatefulWidget {
  @override
  _FastingPlanScreenState createState() => _FastingPlanScreenState();
}

class _FastingPlanScreenState extends State<FastingPlanScreen> {
  DateTime? _selectedDate;
  TimeOfDay? _startTime;
  Duration? _fastingDuration;

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
      backgroundColor: Color.fromARGB(255, 255, 254, 254),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '단식 계획을 설정해 주세요',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 24),
            _buildDateField('시작 날짜', _selectedDate),
            SizedBox(height: 16),
            _buildTimeField('시작 시간', _startTime),
            SizedBox(height: 16),
            _buildDurationField('단식 유지 시간', _fastingDuration),
            SizedBox(height: 16),
            Center(
              child: Text(
                _selectedDate != null && _startTime != null && _fastingDuration != null
                    ? '단식 종료 시간은\n${_getEndTime()}입니다'
                    : '단식 종료 시간을 계산하려면 모든 값을 입력하세요',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.black),
              ),
            ),
            Spacer(),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // 단식 시작 기능 구현
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff6d7ccf),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(33),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                ),
                child: Text(
                  '단식 시작',
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
        DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (pickedDate != null) {
          setState(() {
            _selectedDate = pickedDate;
          });
        }
      },
      child: _buildTextField(label, selectedDate != null ? '${selectedDate.year}-${selectedDate.month}-${selectedDate.day}' : '날짜를 선택하세요'),
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
      child: _buildTextField(label, selectedTime != null ? '${selectedTime.format(context)}' : '시간을 선택하세요'),
    );
  }

  Widget _buildDurationField(String label, Duration? duration) {
    return GestureDetector(
      onTap: () {
        _showDurationPicker();
      },
      child: _buildTextField(label, duration != null ? '${duration.inHours}시간 ${duration.inMinutes % 60}분' : '유지 시간을 선택하세요'),
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

  String _getEndTime() {
    if (_selectedDate == null || _startTime == null || _fastingDuration == null) return '';
    DateTime startDateTime = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _startTime!.hour,
      _startTime!.minute,
    );
    DateTime endDateTime = startDateTime.add(_fastingDuration!);
    return '${endDateTime.month}월 ${endDateTime.day}일 ${endDateTime.hour > 12 ? '오후' : '오전'} ${endDateTime.hour % 12}:${endDateTime.minute}';
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
}

// Simple NumberPicker implementation (or use a package)
class NumberPicker extends StatelessWidget {
  final int initialValue;
  final int minValue;
  final int maxValue;
  final Function(int) onChanged;

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
        return DropdownMenuItem(
          value: value,
          child: Text(value.toString()),
        );
      }),
      onChanged: (value) {
        if (value != null) onChanged(value);
      },
    );
  }
}
