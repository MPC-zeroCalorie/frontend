// fasting_timer_service.dart

import 'dart:async';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class FastingTimerService {
  // 싱글톤 인스턴스 생성
  static final FastingTimerService _instance = FastingTimerService._internal();

  factory FastingTimerService() {
    return _instance;
  }

  FastingTimerService._internal() {
    initializeNotifications();
  }

  DateTime? _startDateTime;
  Duration? _fastingDuration;
  Timer? _timer;
  Duration? _remainingDuration;
  bool _isTimerRunning = false;

  // 남은 시간을 스트림으로 관리
  final StreamController<Duration> _remainingTimeController = StreamController<Duration>.broadcast();

  Stream<Duration> get remainingTimeStream => _remainingTimeController.stream;

  // 알림 플러그인 초기화
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  void initializeNotifications() {
    tz.initializeTimeZones();
    var initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettings = InitializationSettings(android: initializationSettingsAndroid);

    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  void startTimer(DateTime startDateTime, Duration fastingDuration) {
    _startDateTime = startDateTime;
    _fastingDuration = fastingDuration;
    _isTimerRunning = true;
    _initializeTimer();
    _startTimerInternal();
    _scheduleEndNotification();
  }

  void _initializeTimer() {
    DateTime endDateTime = _startDateTime!.add(_fastingDuration!);
    _remainingDuration = endDateTime.difference(DateTime.now());
    if (_remainingDuration!.isNegative) {
      _remainingDuration = Duration.zero;
      _isTimerRunning = false;
    }
    _remainingTimeController.add(_remainingDuration!);
  }

  void _startTimerInternal() {
    _timer?.cancel();
    _updateNotification();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_remainingDuration!.inSeconds > 0) {
        _remainingDuration = _remainingDuration! - Duration(seconds: 1);
        _remainingTimeController.add(_remainingDuration!);
        _updateNotification();
      } else {
        _timer?.cancel();
        _isTimerRunning = false;
        _remainingDuration = Duration.zero;
        _remainingTimeController.add(_remainingDuration!);
        _cancelNotification();
        _showEndNotification();
      }
    });
  }

  void _updateNotification() async {
    var androidDetails = AndroidNotificationDetails(
      'fasting_channel',
      '단식 진행 알림',
      channelDescription: '단식 진행 상황을 알리는 알림입니다.',
      importance: Importance.low,
      priority: Priority.low,
      ongoing: true,
      showWhen: false,
    );
    var notificationDetails = NotificationDetails(android: androidDetails);

    String hours = _remainingDuration!.inHours.toString().padLeft(2, '0');
    String minutes = (_remainingDuration!.inMinutes % 60).toString().padLeft(2, '0');
    String seconds = (_remainingDuration!.inSeconds % 60).toString().padLeft(2, '0');

    await flutterLocalNotificationsPlugin.show(
      0,
      '단식 진행 중',
      '$hours:$minutes:$seconds 남았습니다.',
      notificationDetails,
    );
  }

  void _scheduleEndNotification() async {
    DateTime endTime = _startDateTime!.add(_fastingDuration!);

    await flutterLocalNotificationsPlugin.zonedSchedule(
      1,
      '단식이 종료되었습니다.',
      '단식이 종료되었습니다. 수고하셨습니다!',
      tz.TZDateTime.from(endTime, tz.local),
      NotificationDetails(
        android: AndroidNotificationDetails(
          'fasting_channel',
          '단식 종료 알림',
          channelDescription: '단식 종료를 알리는 알림입니다.',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  void _showEndNotification() async {
    var androidDetails = AndroidNotificationDetails(
      'fasting_channel',
      '단식 종료 알림',
      channelDescription: '단식 종료를 알리는 알림입니다.',
      importance: Importance.high,
      priority: Priority.high,
    );
    var notificationDetails = NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.show(
      1,
      '단식이 종료되었습니다.',
      '단식이 종료되었습니다. 수고하셨습니다!',
      notificationDetails,
    );
  }

  void _cancelNotification() {
    flutterLocalNotificationsPlugin.cancel(0);
  }

  void stopTimer() {
    _timer?.cancel();
    _isTimerRunning = false;
    _remainingDuration = Duration.zero;
    _remainingTimeController.add(_remainingDuration!);
    _cancelNotification();
  }

  bool get isTimerRunning => _isTimerRunning;

  DateTime? get startDateTime => _startDateTime;

  Duration? get fastingDuration => _fastingDuration;

  Duration? get remainingDuration => _remainingDuration;

  void dispose() {
    _timer?.cancel();
    _remainingTimeController.close();
    _cancelNotification();
  }
}
