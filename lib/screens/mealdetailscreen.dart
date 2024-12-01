import 'package:flutter/material.dart';
import 'dart:io';

class MealDetailScreen extends StatelessWidget {
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

  // 비율 계산 함수
  double calculatePercentage(String nutrient, double maxValue) {
    if (nutritionInfo.containsKey(nutrient)) {
      return (nutritionInfo[nutrient]! / maxValue).clamp(0.0, 1.0);
    }
    return 0.0;
  }

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
        title: Text('$mealType 상세정보'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
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
                child: image == null
                    ? Center(child: Text("등록된 이미지가 없습니다."))
                    : Image.file(
                        image!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: 250,
                      ),
              ),
            ),
            SizedBox(height: 16),

            // 저속노화점수 섹션
            Text(
              '저속 노화 점수: ${(antiAgingScore * 100).toStringAsFixed(1)}점',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            LinearProgressIndicator(
              value: antiAgingScore,
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
            SizedBox(height: 8),
            Expanded(
              child: ListView(
                children: maxNutritionValues.entries.map((entry) {
                  final valueText =
                      '${(nutritionInfo[entry.key] ?? 0.0).toStringAsFixed(1)}';
                  final percentage = (nutritionInfo[entry.key] ?? 0.0) /
                      entry.value.clamp(0.0, 1.0);
                  return ListTile(
                    title: Text(entry.key),
                    subtitle: LinearProgressIndicator(
                      value: percentage,
                      backgroundColor: Colors.grey[300],
                      color: Colors.blueAccent,
                      minHeight: 10,
                    ),
                    trailing: Text(valueText),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
