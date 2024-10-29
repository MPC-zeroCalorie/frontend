import 'package:flutter/material.dart';

class CameraScreen extends StatefulWidget {
  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  bool _isEditing = false; // 텍스트 편집 모드 여부
  bool _isExpanded = false; // 바텀 시트 확장 상태
  TextEditingController _foodController = TextEditingController(
    text: '돈까스, 쌀밥, 양배추샐러드, 간장, 와사비, 피클, 된장국', // 초기 음식 텍스트 설정
  );

  void _toggleEditMode() {
    setState(() {
      _isEditing = !_isEditing; // 편집 모드 토글
    });
  }

  void _toggleBottomSheet() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    final double maxHeight = 120; // 바텀 시트 최대 높이
    final double minHeight = 40; // 바텀 시트 최소 높이

    return Scaffold(
      resizeToAvoidBottomInset: false, // 키보드가 올라와도 바텀 시트가 같이 올라가지 않도록 설정
      appBar: AppBar(
        leading: TextButton(
          onPressed: () {
            Navigator.pop(context, 0); // 0을 전달하여 홈 화면 인덱스로 설정
          },
          child: Text(
            '취소',
            style: TextStyle(color: Colors.black, fontSize: 16),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              // 등록 버튼 기능 구현
            },
            child: Text(
              '등록',
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ],
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // 메인 컨텐츠 스크롤 가능하도록
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 160), // 바텀 시트를 위한 여백
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '2024.10.09 / 저녁',
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '오후 6:30',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  SizedBox(height: 16),
                  // 이미지 공간 설정
                  Container(
                    width: double.infinity,
                    height: 250,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: Colors.grey[300],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Image.asset(
                        'assets/food.png',
                        fit: BoxFit.contain,
                        width: double.infinity,
                        height: 250,
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        '내가 먹은 음식',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: _toggleEditMode, // 편집 모드 토글
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          minimumSize: Size(80, 30), // 크기 조정
                          padding: EdgeInsets.symmetric(horizontal: 12),
                        ),
                        child: Text(
                          '+ 음식 추가하기',
                          style: TextStyle(fontSize: 12), // 폰트 크기 조정
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  // 텍스트 편집 모드 여부에 따라 Text 또는 TextField 표시
                  _isEditing
                      ? TextField(
                          controller: _foodController,
                          maxLines: null, // 여러 줄 입력 가능
                          textInputAction: TextInputAction.done, // "확인" 버튼 표시
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                          style: TextStyle(fontSize: 12),
                          onEditingComplete: () {
                            _toggleEditMode(); // 입력 완료 시 편집 모드 종료
                          },
                        )
                      : Text(
                          _foodController.text,
                          style: TextStyle(fontSize: 12),
                        ),
                  SizedBox(height: 16),
                  _buildProgressBar('저속 노화 점수', 0.45, trailingText: '45점'),
                  SizedBox(height: 8),
                  Text(
                    '탄수화물 부족',
                    style: TextStyle(color: Colors.grey),
                  ),
                  SizedBox(height: 16),
                  Text(
                    '영양소 분석',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  _buildNutrientAnalysis(),
                ],
              ),
            ),
          ),
          // 제스처로 조작 가능한 바텀 시트
          _buildGestureControlledBottomSheet(minHeight, maxHeight),
        ],
      ),
    );
  }

  Widget _buildProgressBar(String label, double progress, {String? trailingText}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 5),
        Stack(
          children: [
            Container(
              height: 18,
              decoration: BoxDecoration(
                color: const Color(0xffbdd6f2),
                borderRadius: BorderRadius.circular(60),
              ),
            ),
            Container(
              height: 18,
              width: MediaQuery.of(context).size.width * progress,
              decoration: BoxDecoration(
                color: const Color(0xff6d7ccf),
                borderRadius: BorderRadius.circular(60),
              ),
            ),
          ],
        ),
        if (trailingText != null)
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text(
              trailingText,
              style: TextStyle(fontSize: 10, color: Colors.black),
            ),
          ),
      ],
    );
  }

  Widget _buildNutrientAnalysis() {
    return Wrap(
      spacing: 16.0,
      runSpacing: 16.0,
      children: [
        _buildNutrientCircle('90%', 0.9, '칼슘'),
        _buildNutrientCircle('57%', 0.57, '단백질'),
        _buildNutrientCircle('40%', 0.4, '식이섬유'),
        _buildNutrientCircle('38%', 0.38, '탄수화물'),
        _buildNutrientCircle('30%', 0.3, '비타민C'),
        _buildNutrientCircle('25%', 0.25, '철분'),
        _buildNutrientCircle('80%', 0.8, '비타민D'),
        _buildNutrientCircle('45%', 0.45, '오메가3'),
      ],
    );
  }

  Widget _buildGestureControlledBottomSheet(double minHeight, double maxHeight) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: GestureDetector(
        onTap: _toggleBottomSheet, // 제스처를 통해 바텀 시트 토글
        child: AnimatedContainer(
          duration: Duration(milliseconds: 300),
          height: _isExpanded ? maxHeight : minHeight,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey[500],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  margin: EdgeInsets.symmetric(vertical: 8),
                ),
                if (_isExpanded)
                  Column(
                    children: [
                      ListTile(
                        title: Center(child: Text('사진 촬영')),
                        onTap: () {
                          // 사진 촬영 기능
                        },
                      ),
                      Divider(height: 1),
                      ListTile(
                        title: Center(child: Text('사진 등록')),
                        onTap: () {
                          // 사진 등록 기능
                        },
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNutrientCircle(String percentage, double value, String nutrient) {
    return SizedBox(
      width: MediaQuery.of(context).size.width / 4 - 24,
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              CircularProgressIndicator(
                value: value,
                strokeWidth: 6.0,
                backgroundColor: const Color(0xffbdd6f2),
                valueColor: AlwaysStoppedAnimation<Color>(const Color(0xff6d7ccf)),
              ),
              Text(
                percentage,
                style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(nutrient),
        ],
      ),
    );
  }
}

