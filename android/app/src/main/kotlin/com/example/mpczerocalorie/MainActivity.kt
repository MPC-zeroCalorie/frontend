package com.example.mpczerocalorie

import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel
import com.doinglab.foodlens.sdk.FoodLens
import com.doinglab.foodlens.sdk.UIService
import com.doinglab.foodlens.sdk.UIServiceResultHandler
import com.doinglab.foodlens.sdk.errors.BaseError
import com.doinglab.foodlens.sdk.network.model.UserSelectedResult
import android.util.Log
import com.doinglab.foodlens.sdk.network.model.FoodPosition
import com.doinglab.foodlens.sdk.ui.network.models.Nutrition

class MainActivity: FlutterActivity() {
    private val CHANNEL = "my_sdk_channel"
    private lateinit var uiService: UIService

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        flutterEngine?.dartExecutor?.binaryMessenger?.let {
            MethodChannel(it, CHANNEL).setMethodCallHandler { call, result ->
                Log.d("API_DEBUG", "Method call received: ${call.method}")
                if (call.method == "myNativeMethod") {
                    processImageWithFoodLens(result)
                } else {
                    result.notImplemented()
                }
            }
        }
    }

    private fun startFoodLensCamera() {
        Log.d("API_DEBUG", "Starting FoodLens camera...")
        uiService = FoodLens.createUIService(this)
        uiService.startFoodLensCamera(this, object : UIServiceResultHandler {
            override fun onSuccess(result: UserSelectedResult) {
                Log.d("API_DEBUG", "Camera success, processing results...")
                val foodPositions = result.foodPositions
                val foodName = foodPositions?.firstOrNull()?.foods?.firstOrNull()?.foodName ?: "인식된 음식 없음"
                val nutritionInfo = extractNutritionInfo(foodPositions)
                val imagePath = foodPositions?.firstOrNull()?.foodImagePath ?: ""  // 첫 번째 음식 이미지 경로 가져오기

                Log.d("API_DEBUG", "Food name: $foodName")
                Log.d("API_DEBUG", "Nutrition info: $nutritionInfo")
                Log.d("API_DEBUG", "Image path: $imagePath")

                // 데이터를 JSON 호환 Map으로 전달
                val resultData = mapOf(
                    "foodName" to foodName,
                    "nutritionInfo" to nutritionInfo,
                    "imagePath" to imagePath // 이미지 경로 전달
                )

                // Flutter로 데이터 전달
                flutterEngine?.dartExecutor?.binaryMessenger?.let {
                    MethodChannel(it, CHANNEL)
                        .invokeMethod("onFoodRecognized", resultData)
                }
            }

            override fun onCancel() {
                Log.d("API_DEBUG", "Camera cancelled by user.")
            }

            override fun onError(error: BaseError) {
                Log.e("API_DEBUG", "Camera error occurred: ${error.message}")
            }
        })
    }

    private fun extractNutritionInfo(foodPositions: List<FoodPosition>?): Map<String, Any> {
        val food = foodPositions?.firstOrNull()?.foods?.firstOrNull()
        return if (food != null && food.nutrition != null) {
            val nutrition = food.nutrition
            val nutritionMap = mapOf(
                "칼슘" to nutrition.getCalcium(),
                "단백질" to nutrition.getProtein(),
                "식이섬유" to nutrition.getDietrayFiber(),
                "탄수화물" to nutrition.getCarbonHydrate(),
                "비타민C" to nutrition.getVitaminC(),
                "지방" to nutrition.getFat(),
                "비타민D" to nutrition.getVitaminD(),
                "당" to nutrition.getSugar()
            )
            Log.d("API_DEBUG", "Extracted nutrition info: $nutritionMap")
            nutritionMap
        } else {
            val defaultNutritionMap = mapOf(
                "칼슘" to 0.0f,
                "단백질" to 0.0f,
                "식이섬유" to 0.0f,
                "탄수화물" to 0.0f,
                "비타민C" to 0.0f,
                "지방" to 0.0f,
                "비타민D" to 0.0f,
                "당" to 0.0f
            )
            Log.d("API_DEBUG", "Default nutrition info returned: $defaultNutritionMap")
            defaultNutritionMap
        }
    }

    private fun processImageWithFoodLens(result: MethodChannel.Result) {
        Log.d("API_DEBUG", "Processing image with FoodLens...")
        uiService = FoodLens.createUIService(applicationContext)
        uiService.startFoodLensCamera(this, object : UIServiceResultHandler {
            override fun onSuccess(userSelectedResult: UserSelectedResult) {
                Log.d("API_DEBUG", "Image processing success. Preparing data...")
                val foodName = userSelectedResult.foodPositions?.get(0)?.foods?.get(0)?.foodName ?: "인식 실패"
                val nutritionInfo = extractNutritionInfo(userSelectedResult.foodPositions)
                val imagePath = userSelectedResult.foodPositions?.firstOrNull()?.foodImagePath ?: ""

                Log.d("API_DEBUG", "Food name: $foodName")
                Log.d("API_DEBUG", "Nutrition info: $nutritionInfo")
                Log.d("API_DEBUG", "Image path: $imagePath")

                val resultData = mapOf(
                    "foodName" to foodName,
                    "nutritionInfo" to nutritionInfo,
                    "imagePath" to imagePath
                )
                result.success(resultData)
            }

            override fun onCancel() {
                Log.d("API_DEBUG", "Image processing cancelled by user.")
                result.error("CANCELLED", "카메라 사용 취소됨", null)
            }

            override fun onError(error: BaseError) {
                Log.e("API_DEBUG", "Image processing error: ${error.message}")
                result.error("ERROR", error.message, null)
            }
        })
    }
}
