import 'dart:convert'; // JSON 변환을 위해 추가
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // HTTP 요청을 위해 추가

class SignUpPage extends StatefulWidget {
  SignUpPage({super.key});

  @override
  State<StatefulWidget> createState() => _SignUpPage();
}

class _SignUpPage extends State<SignUpPage> {
  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _isButtonEnabled = false;
  String? _passwordError; // 비밀번호 오류 메시지 상태
  String? _signupError; // API 요청 실패 시 오류 메시지 상태

  final String _signupUrl = 'https://signup-4zs2rshoda-uc.a.run.app'; // 회원가입 API URL

  @override
  void initState() {
    super.initState();
    _nicknameController.addListener(_checkInput);
    _usernameController.addListener(_checkInput);
    _passwordController.addListener(_checkInput);
    _confirmPasswordController.addListener(_checkInput);
  }

  void _checkInput() {
    setState(() {
      _isButtonEnabled = _nicknameController.text.isNotEmpty &&
          _usernameController.text.isNotEmpty &&
          _passwordController.text.isNotEmpty &&
          _confirmPasswordController.text.isNotEmpty;
      _passwordError = null; // 입력 중에는 오류 메시지를 초기화
      _signupError = null; // 입력 중에는 API 오류 메시지를 초기화
    });
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _onSignUp() async {
    // 비밀번호와 확인 비밀번호가 일치하는지 검사
    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() {
        _passwordError = '비밀번호가 일치하지 않습니다.'; // 오류 메시지 설정
      });
      return;
    }

    // 가입 데이터 생성
    final Map<String, String> body = {
      "email": _usernameController.text,
      "password": _passwordController.text,
      "name": _nicknameController.text,
    };

    try {
      final response = await http.post(
        Uri.parse(_signupUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 201) {
        final responseBody = jsonDecode(response.body);
        print('회원가입 성공: ${responseBody['userId']}');

        // 가입 성공 후 처리 (예: 로그인 화면으로 이동)
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('회원가입 성공'),
            content: Text('환영합니다, ${_nicknameController.text}!'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // 팝업 닫기
                  Navigator.pop(context); // 로그인 화면으로 돌아가기
                },
                child: Text('확인'),
              ),
            ],
          ),
        );
      } else if (response.statusCode == 400) {
        // 이메일 중복 오류 처리
        setState(() {
          _signupError = '이미 존재하는 이메일입니다.';
        });
      } else {
        // 기타 서버 오류
        setState(() {
          _signupError = '회원가입 중 오류가 발생했습니다. 다시 시도해주세요.';
        });
      }
    } catch (e) {
      // 네트워크 오류 처리
      setState(() {
        _signupError = '서버에 연결할 수 없습니다. 네트워크를 확인해주세요.';
      });
    }
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
                '회원가입',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 25,
                  color: Colors.black,
                  fontFamily: 'Inter-ExtraBold',
                ),
              ),
              SizedBox(height: 32),
              _buildInputField('닉네임', _nicknameController),
              SizedBox(height: 16),
              _buildInputField('아이디', _usernameController),
              SizedBox(height: 16),
              _buildInputField('비밀번호', _passwordController, obscureText: true),
              SizedBox(height: 16),
              _buildInputField('비밀번호 확인', _confirmPasswordController, obscureText: true),
              if (_passwordError != null) // 비밀번호 오류 메시지 출력
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    _passwordError!,
                    style: TextStyle(color: Colors.red, fontSize: 14),
                  ),
                ),
              if (_signupError != null) // 회원가입 API 오류 메시지 출력
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    _signupError!,
                    style: TextStyle(color: Colors.red, fontSize: 14),
                  ),
                ),
              SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isButtonEnabled ? _onSignUp : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isButtonEnabled ? const Color(0xff6d7ccf) : Colors.grey,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 14.0, horizontal: 36.0),
                ),
                child: Text(
                  '가입',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField(String labelText, TextEditingController controller, {bool obscureText = false}) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xff6d7ccf),
        borderRadius: BorderRadius.circular(20),
      ),
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          Text(
            '$labelText: ',
            style: TextStyle(color: Colors.white, fontSize: 16),
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
    );
  }
}
