import 'package:flutter/material.dart';
import 'dart:io';

class MealDetailScreen extends StatefulWidget {
  final String mealType;
  final File? image;
  final Map<String, double> nutritionInfo;
  final double antiAgingScore;

  MealDetailScreen({
    required this.mealType,
    this.image,
    required this.nutritionInfo,
    required this.antiAgingScore,
  });

  @override
  _MealDetailScreenState createState() => _MealDetailScreenState();
}

class _MealDetailScreenState extends State<MealDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final Map<String, double> maxNutritionValues = {
      "칼슘": 1000.0,
      "단백질": 50.0,
      "식이섬유": 25.0,
      "탄수화물": 300.0,
      "비타민C": 90.0,
      "지방": 70.0,
      "비타민D": 20.0,
      "당": 50.0,
    };

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.mealType} 상세정보'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 이미지 섹션
              Container(
                width: double.infinity,
                height: 250,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: Colors.grey[300],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: widget.image == null
                      ? Center(child: Text("등록된 이미지가 없습니다."))
                      : Image.file(
                          widget.image!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: 250,
                        ),
                ),
              ),
              SizedBox(height: 16),

              // 음식 정보 텍스트
              Text(
                '음식 정보',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),

              // 저속노화점수 섹션
              Text(
                '저속 노화 점수: ${(widget.antiAgingScore * 100).toStringAsFixed(1)}점',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              LinearProgressIndicator(
                value: widget.antiAgingScore,
                backgroundColor: Colors.grey[300],
                color: Colors.blueAccent,
                minHeight: 10,
              ),
              SizedBox(height: 16),

              // 영양소 분석 섹션
              Text(
                '영양소 분석:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4, // 한 줄에 4개씩
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 1, // 아이템 비율
                ),
                itemCount: maxNutritionValues.keys.length,
                itemBuilder: (context, index) {
                  final nutrient = maxNutritionValues.keys.elementAt(index);
                  final value = widget.nutritionInfo[nutrient] ?? 0.0;
                  final percentage =
                      (value / maxNutritionValues[nutrient]!).clamp(0.0, 1.0);

                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          CircularProgressIndicator(
                            value: percentage,
                            strokeWidth: 6.0,
                            backgroundColor: Colors.grey[300],
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.blueAccent,
                            ),
                          ),
                          Text(
                            '${value.toStringAsFixed(1)}',
                            style: TextStyle(
                                fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text(
                        nutrient,
                        style: TextStyle(fontSize: 12),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
