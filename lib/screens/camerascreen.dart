import 'package:flutter/material.dart';
import 'dart:io'; // 이미지 파일을 사용하기 위해 추가
import 'dart:convert'; // JSON 변환을 위해 추가
import 'package:http/http.dart' as http; // HTTP 요청을 위해 추가
import '../platform_channel.dart'; // 네이티브 기능 호출을 위한 platform_channel
import 'package:shared_preferences/shared_preferences.dart'; // SharedPreferences import 추가
import 'package:firebase_storage/firebase_storage.dart';

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
    text: '', // 초기 음식 텍스트 설정
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
  Future<String> uploadImageToFirebase(File imageFile) async {
   try {
     String fileName = "image_${DateTime.now().millisecondsSinceEpoch}.jpg";
      Reference storageRef = FirebaseStorage.instance.ref().child("meal_images/$fileName");

      // 이미지 업로드
      UploadTask uploadTask = storageRef.putFile(imageFile);
      TaskSnapshot snapshot = await uploadTask;

      // 다운로드 URL 획득
      String downloadUrl = await snapshot.ref.getDownloadURL();
      print("Image uploaded successfully. URL: $downloadUrl");
      return downloadUrl;
    } catch (e) {
      print("Error uploading image: $e");
      throw Exception("이미지 업로드 실패");
    }
  }
  Future<void> _loadUserToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _userToken = prefs.getString('token');
      print("Loaded user token: $_userToken");
    });
  }

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
  String _generateUniqueFileName() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'image_$timestamp.jpg'; // 예: image_1632964356000.jpg
  }

  // 네이티브 메서드를 호출하여 카메라 실행
  Future<void> _invokeCameraSDK() async {
    try {
      var result = await MyPlatformChannel.invokeNativeMethod("myNativeMethod");
      
      print("Received result from native: $result"); // 결과 출력
      if (result.containsKey("Error")) {
        throw Exception(result["Error"]);
      }
      String originalImagePath = result["imagePath"];
      String uniqueFileName = _generateUniqueFileName();
      String newPath = '/data/user/0/com.example.mpczerocalorie/files/temp/$uniqueFileName';
      
       // 이미지 파일 이름 변경
      File originalFile = File(originalImagePath);
      File renamedFile = await originalFile.rename(newPath);

      // 네이티브에서 받은 결과 처리
      setState(() {
        _foodController.text =
            result["foodName"] ?? "음식 이름을 인식하지 못했습니다.";
        _nutritionInfo = Map<String, double>.from(Map<String, dynamic>.from(result["nutritionInfo"] ?? {}));
        _image = renamedFile; // 고유 이름이 적용된 파일 경로 사용
      });

    // 네이티브 데이터 기반으로 API 호출
    await _calculateMealScoreAndUpdateUI();
    } catch (e) {
      print("Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('네이티브 호출 실패: $e')),
      );
    }
  }

// 식사 점수 계산 API 호출 및 UI 업데이트
Future<void> _calculateMealScoreAndUpdateUI() async {
  // 음식 데이터 생성
  Map<String, dynamic> foodItem = {
    "foodname": _foodController.text,
    "vitaminC": double.parse((_nutritionInfo["비타민C"] ?? 0.0).toStringAsFixed(1)),
    "protein": double.parse((_nutritionInfo["단백질"] ?? 0.0).toStringAsFixed(1)),
    "totalDietaryFiber": double.parse((_nutritionInfo["식이섬유"] ?? 0.0).toStringAsFixed(1)),
    "energy": double.parse(((_nutritionInfo["탄수화물"] ?? 0.0) * 4 +
            (_nutritionInfo["단백질"] ?? 0.0) * 4 +
            (_nutritionInfo["지방"] ?? 0.0) * 9)
        .toStringAsFixed(1)), // 에너지 계산
  };

  // 요청 Body 생성
  Map<String, dynamic> body = {
    "foods": [foodItem],
  };

  try {
    final response = await http.post(
      Uri.parse('https://us-central1-slowaging.cloudfunctions.net/calculateMealScore'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    print("Request body: ${jsonEncode(body)}");
    print("Response status: ${response.statusCode}");
    print("Response body: ${response.body}");

    if (response.statusCode == 200) {
      // 성공 처리
      final responseBody = jsonDecode(response.body);
      setState(() {
        _antiAgingScore = (responseBody['mealScore'] as num).toDouble() / 100.0; // 저속노화점수 업데이트
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('저속 노화 점수 계산 완료: ${responseBody['mealScore']}점'),
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

  // 비율 계산 함수
  double calculatePercentage(String nutrient) {
    if (_nutritionInfo.containsKey(nutrient) &&
        _maxNutritionValues.containsKey(nutrient)) {
      double percentage =
        (_nutritionInfo[nutrient]! / _maxNutritionValues[nutrient]!)
            .clamp(0.0, 1.0);
      return double.parse(percentage.toStringAsFixed(1)); // 소수점 첫째 자리로 제한
    }
    return 0.0;
  }
  String getMealTypeEnglish(String koreanMealType) {
    switch (koreanMealType) {
      case '아침':
        return 'breakfast';
      case '점심':
        return 'lunch';
      case '저녁':
        return 'dinner';
      default:
        return 'unknown';
    }
  }

  // 저속 노화 점수 저장 및 계산 API 호출
Future<void> _saveMeal() async {
  if (_image == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('이미지를 등록해주세요.')),
    );
    return;
  }
  // Firebase Storage에 이미지 업로드
  String? imageUrl;
  try {
    imageUrl = await uploadImageToFirebase(_image!);
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('이미지 업로드 실패: $e')),
    );
    return;
  }
  // 현재 날짜 및 식사 데이터 준비
  String date = DateTime.now().toIso8601String().split('T')[0];
  // 선택한 식사 타입을 영어로 변환
  String mealType = getMealTypeEnglish(_selectedMeal);

  // 에너지(칼로리) 계산
  double energy = ((_nutritionInfo["탄수화물"] ?? 0.0) * 4) +
      ((_nutritionInfo["단백질"] ?? 0.0) * 4) +
      ((_nutritionInfo["지방"] ?? 0.0) * 9);

  // 음식 데이터 생성
  Map<String, dynamic> foodItem = {
    "name": _foodController.text,
    "quantity": 1, // 기본 수량
    "nutritionInfo": {
      "vitaminC": (_nutritionInfo["비타민C"] ?? 0.0).toDouble(),
      "protein": (_nutritionInfo["단백질"] ?? 0.0).toDouble(),
      "fiber": (_nutritionInfo["식이섬유"] ?? 0.0).toDouble(),
      "energy": energy.toDouble(),
    },
    "imageUrl": imageUrl, // 업로드된 이미지의 URL
  };

  // 요청 Body 생성
  Map<String, dynamic> body = {
    "date": date,
    "mealType": mealType,
    "foods": [foodItem],
  };

  // 토큰이 null이거나 빈 문자열인지 확인
  if (_userToken == null || _userToken!.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('로그인이 필요합니다.')),
    );
    return;
  }

  try {
    final response = await http.post(
      Uri.parse('https://us-central1-slowaging.cloudfunctions.net/saveMealAndCalculateDailyScore'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_userToken',
      },
      body: jsonEncode(body),
    );

    print("Request body: ${jsonEncode(body)}");
    print("Response status: ${response.statusCode}");
    print("Response body: ${response.body}");

    if (response.statusCode == 200) {
      // 성공 처리
      final responseBody = jsonDecode(response.body);
      setState(() {
        _antiAgingScore =
            (responseBody['dailySlowAgingScore'] as num).toDouble() / 100.0; // 일간 저속노화점수
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              '저속 노화 점수 저장 완료: ${responseBody['mealScore']}점, 일간 점수: ${responseBody['dailySlowAgingScore']}점'),
        ),
      );
      Map<String, dynamic> resultData = {
            'mealType': _selectedMeal, // 식사 유형
            'imagePath': _image?.path, // 이미지 파일 경로
            'nutritionInfo': _nutritionInfo, // 영양소 정보
            'antiAgingScore': _antiAgingScore, // 저속노화 점수
            'food': _foodController.text, // 음식 이름
            'energy': energy, // 칼로리 값을 포함
        };
        print("Returned result data: $resultData");
        Navigator.pop(context, resultData); // 데이터와 함께 이전 화면으로 이동
      
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
          '${(_nutritionInfo["칼슘"] ?? 0.0).toStringAsFixed(1)} mg',
          calculatePercentage("칼슘"),
          '칼슘',
        ),
        _buildNutrientCircle(
          '${(_nutritionInfo["단백질"] ?? 0.0).toStringAsFixed(1)} g',
          calculatePercentage("단백질"),
          '단백질',
        ),
        _buildNutrientCircle(
          '${(_nutritionInfo["식이섬유"] ?? 0.0).toStringAsFixed(1)} g',
          calculatePercentage("식이섬유"),
          '식이섬유',
        ),
        _buildNutrientCircle(
          '${(_nutritionInfo["탄수화물"] ?? 0.0).toStringAsFixed(1)} g',
          calculatePercentage("탄수화물"),
          '탄수화물',
        ),
        _buildNutrientCircle(
          '${(_nutritionInfo["비타민C"] ?? 0.0).toStringAsFixed(1)} mg',
          calculatePercentage("비타민C"),
          '비타민C',
        ),
        _buildNutrientCircle(
          '${(_nutritionInfo["지방"] ?? 0.0).toStringAsFixed(1)} g',
          calculatePercentage("지방"),
          '지방',
        ),
        _buildNutrientCircle(
          '${(_nutritionInfo["비타민D"] ?? 0.0).toStringAsFixed(1)} µg',
          calculatePercentage("비타민D"),
          '비타민D',
        ),
        _buildNutrientCircle(
          '${(_nutritionInfo["당"] ?? 0.0).toStringAsFixed(1)} g',
          calculatePercentage("당"),
          '당',
        ),
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