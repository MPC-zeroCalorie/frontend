import 'package:flutter/material.dart';
import 'dart:io'; // 이미지 파일을 사용하기 위해 추가
import 'dart:convert'; // JSON 변환을 위해 추가
import 'package:http/http.dart' as http; // HTTP 요청을 위해 추가
import '../platform_channel.dart'; // 네이티브 기능 호출을 위한 platform_channel
import 'package:shared_preferences/shared_preferences.dart'; // SharedPreferences import 추가

class CameraScreen extends StatefulWidget {
  CameraScreen({Key? key}) : super(key: key);

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  bool _isEditing = false; // 텍스트 편집 모드 여부
  bool _isExpanded = false; // 바텀 시트 확장 상태
  String _selectedMeal = '아침'; // 선택한 식사 유형
  TextEditingController _foodController = TextEditingController(
    text: '돈까스, 쌀밥, 양배추샐러드, 간장, 와사비, 피클, 된장국', // 초기 음식 텍스트 설정
  );

  File? _image; // 찍은 이미지를 저장할 변수
  Map<String, double> _nutritionInfo = {}; // 음식 영양 정보를 저장할 변수
  String? _userToken;
  double _antiAgingScore = 0.0; // 저속노화점수 초기값

  // 최대 영양소 값을 설정하여 비율 계산에 사용
  Map<String, double> _maxNutritionValues = {
    "칼슘": 1000.0, // 하루 권장 섭취량 (mg)
    "단백질": 50.0, // 하루 권장 섭취량 (g)
    "식이섬유": 25.0, // 하루 권장 섭취량 (g)
    "탄수화물": 300.0, // 하루 권장 섭취량 (g)
    "비타민C": 90.0, // 하루 권장 섭취량 (mg)
    "지방": 70.0, // 하루 권장 섭취량 (g)
    "비타민D": 20.0, // 하루 권장 섭취량 (µg)
    "당": 50.0, // 하루 권장 섭취량 (g)
  };
  @override
  void initState() {
    super.initState();
    _loadUserToken();
  }
  Future<void> _loadUserToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _userToken = prefs.getString('token');
    });
  }

  final String _saveMealUrl =
      'https://savemealandcalculatescore-4zs2rshoda-uc.a.run.app'; // API URL

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

  // 네이티브 메서드를 호출하여 카메라 실행
  Future<void> _invokeCameraSDK() async {
    var result =
        await MyPlatformChannel.invokeNativeMethod("myNativeMethod");

    // 네이티브에서 받은 결과에 따라 이미지와 음식 정보를 업데이트
    setState(() {
      _foodController.text =
          result["foodName"] ?? "음식 이름을 인식하지 못했습니다.";
      _nutritionInfo = {
        "칼슘": (result["nutritionInfo"]["칼슘"] as num?)?.toDouble() ?? 0.0,
        "단백질":
            (result["nutritionInfo"]["단백질"] as num?)?.toDouble() ?? 0.0,
        "식이섬유":
            (result["nutritionInfo"]["식이섬유"] as num?)?.toDouble() ?? 0.0,
        "탄수화물":
            (result["nutritionInfo"]["탄수화물"] as num?)?.toDouble() ?? 0.0,
        "비타민C":
            (result["nutritionInfo"]["비타민C"] as num?)?.toDouble() ?? 0.0,
        "지방": (result["nutritionInfo"]["지방"] as num?)?.toDouble() ?? 0.0,
        "비타민D":
            (result["nutritionInfo"]["비타민D"] as num?)?.toDouble() ?? 0.0,
        "당": (result["nutritionInfo"]["당"] as num?)?.toDouble() ?? 0.0,
      };

      print("Received nutrition info: $_nutritionInfo"); // << 추가된 로그
      _image = File(result["imagePath"]); // 실제 경로로 이미지 업데이트

      // 저속노화 점수를 업데이트하는 로직 추가
      _updateAntiAgingScore();
    });
  }

  // 저속노화점수 계산 (영양소 정보로 점수 계산)
  void _updateAntiAgingScore() {
    double score = 0.0;
    double totalWeight = _maxNutritionValues.length.toDouble();

    _maxNutritionValues.forEach((key, maxValue) {
      double nutrientValue = _nutritionInfo[key] ?? 0.0;
      score += (nutrientValue / maxValue).clamp(0.0, 1.0); // 비율 계산 및 제한
    });

    setState(() {
      _antiAgingScore =
          (score / totalWeight).clamp(0.0, 1.0); // 평균값으로 저속노화점수 계산
    });
  }

  // 비율 계산 함수
  double calculatePercentage(String nutrient) {
    if (_nutritionInfo.containsKey(nutrient) &&
        _maxNutritionValues.containsKey(nutrient)) {
      return (_nutritionInfo[nutrient]! / _maxNutritionValues[nutrient]!)
          .clamp(0.0, 1.0);
    }
    return 0.0;
  }

  // 저속 노화 점수 저장 및 계산 API 호출
  Future<void> _saveMeal() async {
    // 현재 날짜 및 식사 데이터 준비
    String date = DateTime.now().toIso8601String().split('T')[0];
    String mealType = _selectedMeal;

    // 에너지(칼로리) 계산
    double energy = ((_nutritionInfo["탄수화물"] ?? 0.0) * 4) +
        ((_nutritionInfo["단백질"] ?? 0.0) * 4) +
        ((_nutritionInfo["지방"] ?? 0.0) * 9);

    // 음식 데이터 생성 (여기서는 전체 식사를 하나의 아이템으로 처리)
    Map<String, dynamic> food = {
      "name": _foodController.text,
      "vitaminC": _nutritionInfo["비타민C"] ?? 0.0,
      "protein": _nutritionInfo["단백질"] ?? 0.0,
      "totalDietaryFiber": _nutritionInfo["식이섬유"] ?? 0.0,
      "energy": energy,
    };

    // 요청 Body 생성
    Map<String, dynamic> body = {
      "token": _userToken,
      "date": date,
      "mealType": mealType,
      "foods": [food],
    };

    try {
      final response = await http.post(
        Uri.parse(_saveMealUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        // 성공 처리
        final responseBody = jsonDecode(response.body);
        setState(() {
          _antiAgingScore =
              (responseBody['slowAgingScore'] as num).toDouble() / 100.0;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                '저속 노화 점수 저장 완료: ${responseBody['slowAgingScore']}점'),
          ),
        );
      } else {
        // 오류 처리
        final responseBody = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('오류 발생: ${responseBody['message']}')),
        );
      }
    } catch (e) {
      // 예외 처리
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('네트워크 오류 발생: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final double maxHeight = 120; // 바텀 시트 최대 높이
    final double minHeight = 40; // 바텀 시트 최소 높이
    String today =
        DateTime.now().toIso8601String().split('T')[0].replaceAll('-', '.'); // 현재 날짜
    String timeNow =
        DateTime.now().toLocal().toString().split(' ')[1].substring(0, 5); // 현재 시간

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context); // 홈 화면으로 돌아가기
          },
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        title: DropdownButton<String>(
          value: _selectedMeal,
          items: ['아침', '점심', '저녁']
              .map((meal) => DropdownMenuItem<String>(
                    value: meal,
                    child: Text(meal),
                  ))
              .toList(),
          onChanged: (value) {
            setState(() {
              _selectedMeal = value!;
            });
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.check, color: Colors.black),
            onPressed: _saveMeal, // 등록 버튼 클릭 시 _saveMeal 호출
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 160),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$today / $_selectedMeal', // 선택한 식사 유형 출력
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '$timeNow', // 현재 시간 출력
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
                      child: _image == null
                          ? Center(child: Text("이미지를 등록해주세요"))
                          : Image.file(
                              _image!,
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
                        style:
                            TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: _toggleEditMode,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          minimumSize: Size(80, 30),
                          padding: EdgeInsets.symmetric(horizontal: 12),
                        ),
                        child: Text(
                          '+ 음식 추가하기',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  _isEditing
                      ? TextField(
                          controller: _foodController,
                          maxLines: null,
                          textInputAction: TextInputAction.done,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                          ),
                          style: TextStyle(fontSize: 12),
                          onEditingComplete: () {
                            _toggleEditMode();
                          },
                        )
                      : Text(
                          _foodController.text,
                          style: TextStyle(fontSize: 12),
                        ),
                  SizedBox(height: 16),
                  // 저속노화점수 Progress Bar
                  _buildAntiAgingBar(),
                  SizedBox(height: 16),
                  Text(
                    '영양소 분석: ',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  _buildNutrientAnalysis(),
                ],
              ),
            ),
          ),
          _buildGestureControlledBottomSheet(minHeight, maxHeight),
        ],
      ),
    );
  }

  // 저속노화점수 Progress Bar 위젯
  Widget _buildAntiAgingBar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '저속 노화 점수: ${(_antiAgingScore * 100).toStringAsFixed(1)}점',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        LinearProgressIndicator(
          value: _antiAgingScore,
          backgroundColor: Colors.grey[300],
          color: Colors.blueAccent,
          minHeight: 10,
        ),
      ],
    );
  }

  Widget _buildNutrientAnalysis() {
    return Wrap(
      spacing: 16.0,
      runSpacing: 16.0,
      children: [
        _buildNutrientCircle(
            '${_nutritionInfo["칼슘"] ?? 0.0} mg', calculatePercentage("칼슘"), '칼슘'),
        _buildNutrientCircle(
            '${_nutritionInfo["단백질"] ?? 0.0} g', calculatePercentage("단백질"), '단백질'),
        _buildNutrientCircle(
            '${_nutritionInfo["식이섬유"] ?? 0.0} g', calculatePercentage("식이섬유"), '식이섬유'),
        _buildNutrientCircle('${_nutritionInfo["탄수화물"] ?? 0.0} g',
            calculatePercentage("탄수화물"), '탄수화물'),
        _buildNutrientCircle('${_nutritionInfo["비타민C"] ?? 0.0} mg',
            calculatePercentage("비타민C"), '비타민C'),
        _buildNutrientCircle(
            '${_nutritionInfo["지방"] ?? 0.0} g', calculatePercentage("지방"), '지방'),
        _buildNutrientCircle('${_nutritionInfo["비타민D"] ?? 0.0} µg',
            calculatePercentage("비타민D"), '비타민D'),
        _buildNutrientCircle(
            '${_nutritionInfo["당"] ?? 0.0} g', calculatePercentage("당"), '당'),
      ],
    );
  }

  Widget _buildNutrientCircle(
      String valueText, double value, String nutrient) {
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
                valueColor:
                    AlwaysStoppedAnimation<Color>(const Color(0xff6d7ccf)),
              ),
              Text(
                valueText,
                style:
                    TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(nutrient),
        ],
      ),
    );
  }

  Widget _buildGestureControlledBottomSheet(
      double minHeight, double maxHeight) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: GestureDetector(
        onTap: _toggleBottomSheet,
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
                        onTap: _invokeCameraSDK,
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
}
