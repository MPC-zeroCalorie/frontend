import 'package:flutter/services.dart';

class MyPlatformChannel {
  // 네이티브 채널 설정
  static const MethodChannel _channel = MethodChannel('my_sdk_channel');

  // 네이티브 메서드를 호출하는 함수
  static Future<Map<String, dynamic>> invokeNativeMethod(String param) async {
    try {
      // 로그: 메서드 호출 시작
      print('[MyPlatformChannel] Invoking native method: myNativeMethod with param: $param');

      // 'myNativeMethod'라는 메서드를 호출하고, 'param' 인수를 전달합니다.
      final result = await _channel.invokeMethod('myNativeMethod', {'param': param});

      // 로그: 성공적으로 결과를 수신
      print('[MyPlatformChannel] Native method call succeeded. Result: $result');

      return Map<String, dynamic>.from(result);
    } catch (e) {
      // 로그: 오류 발생 시 메시지 출력
      print('[MyPlatformChannel] Native method call failed. Error: $e');

      // 오류 발생 시 빈 Map을 반환하거나 오류 처리를 위한 방법을 추가할 수 있습니다.
      return {"Error": e.toString()};
    }
  }
}