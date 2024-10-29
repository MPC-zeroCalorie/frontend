import 'package:flutter/material.dart';
import 'package:mpczerocalorie/screens/signup.dart';
import 'package:mpczerocalorie/screens/home.dart'; // HomePage import 추가

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isButtonEnabled = false;

  @override
  void initState() {
    super.initState();
    _usernameController.addListener(_checkInput);
    _passwordController.addListener(_checkInput);
  }

  void _checkInput() {
    setState(() {
      _isButtonEnabled = _usernameController.text.isNotEmpty && _passwordController.text.isNotEmpty;
    });
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLogin() {
    if (_isButtonEnabled) {
      // HomePage로 이동
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
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
