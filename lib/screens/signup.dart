import 'package:flutter/material.dart';

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

  void _onSignUp() {
    // 비밀번호와 확인 비밀번호가 일치하는지 검사
    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() {
        _passwordError = '비밀번호가 일치하지 않습니다.'; // 오류 메시지 설정
      });
    } else {
      // 가입 처리 로직 추가
      print("회원가입 시도 중...");
      // 오류 메시지를 초기화
      setState(() {
        _passwordError = null;
      });
      
      // 로그인 화면으로 돌아가기
      Navigator.pop(context);
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
              if (_passwordError != null) // 오류 메시지 출력 조건
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    _passwordError!,
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
