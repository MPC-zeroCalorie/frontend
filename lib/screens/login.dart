import 'dart:convert'; // JSON 변환을 위해 추가
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // SharedPreferences import 추가
import 'package:mpczerocalorie/screens/signup.dart';
import 'package:mpczerocalorie/screens/home.dart'; // HomePage import 추가
import 'package:http/http.dart' as http; // HTTP 요청을 위해 추가

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isButtonEnabled = false;
  String? _loginError; // 로그인 실패 메시지 상태

  final String _loginUrl = 'https://login-4zs2rshoda-uc.a.run.app'; // 로그인 API URL

  @override
  void initState() {
    super.initState();
    _usernameController.addListener(_checkInput);
    _passwordController.addListener(_checkInput);
  }

  void _checkInput() {
    setState(() {
      _isButtonEnabled = _usernameController.text.isNotEmpty && _passwordController.text.isNotEmpty;
      _loginError = null; // 입력 중에는 오류 메시지를 초기화
    });
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _onLogin() async {
    if (!_isButtonEnabled) return;

    final Map<String, String> body = {
      "email": _usernameController.text,
      "password": _passwordController.text,
    };

    try {
      final response = await http.post(
        Uri.parse(_loginUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        print('로그인 성공: ${responseBody['token']}');

        // SharedPreferences를 사용하여 토큰 저장
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', responseBody['token']);

        // 로그인 성공 후 HomePage로 이동
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      } else if (response.statusCode == 404) {
        // 사용자 없음
        setState(() {
          _loginError = '사용자를 찾을 수 없습니다.';
        });
      } else if (response.statusCode == 401) {
        // 비밀번호 불일치
        setState(() {
          _loginError = '비밀번호가 일치하지 않습니다.';
        });
      } else {
        // 기타 서버 오류
        setState(() {
          _loginError = '로그인 중 오류가 발생했습니다. 다시 시도해주세요.';
        });
      }
    } catch (e) {
      // 네트워크 오류 처리
      setState(() {
        _loginError = '서버에 연결할 수 없습니다. 네트워크를 확인해주세요.';
      });
    }
  }

  void _onSignUp() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SignUpPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '로그인',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 25,
                  color: Colors.black,
                  fontFamily: 'Inter-ExtraBold',
                ),
              ),
              SizedBox(height: 32),
              Image.asset(
                'assets/26.png',
                width: 167,
                height: 168,
              ),
              SizedBox(height: 32),
              _buildTextField(_usernameController, '아이디'),
              SizedBox(height: 16),
              _buildTextField(_passwordController, '비밀번호', obscureText: true),
              if (_loginError != null) // 로그인 오류 메시지 출력
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    _loginError!,
                    style: TextStyle(color: Colors.red, fontSize: 14),
                  ),
                ),
              SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isButtonEnabled ? _onLogin : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isButtonEnabled ? const Color(0xff6d7ccf) : Colors.grey,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 32),
                  child: Text(
                    'LOGIN',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 32),
              GestureDetector(
                onTap: _onSignUp,
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: '아직 계정이 없으신가요? ',
                        style: TextStyle(
                          fontSize: 13,
                          color: const Color(0xff868686),
                          fontFamily: 'Inter-SemiBold',
                        ),
                      ),
                      TextSpan(
                        text: '회원가입',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                          fontFamily: 'Inter-SemiBold',
                        ),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String labelText, {bool obscureText = false}) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xff6d7ccf),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Text(
              '$labelText: ',
              style: TextStyle(color: Colors.white),
            ),
            Expanded(
              child: TextField(
                controller: controller,
                obscureText: obscureText,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  border: InputBorder.none,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
