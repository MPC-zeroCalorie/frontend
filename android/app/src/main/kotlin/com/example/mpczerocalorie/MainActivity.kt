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
import android.Manifest
import android.content.Intent
import android.content.pm.PackageManager
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat

class MainActivity: FlutterActivity() {
    private val CHANNEL = "my_sdk_channel"
    private lateinit var uiService: UIService
    private lateinit var result: MethodChannel.Result
    private val CAMERA_PERMISSION_REQUEST_CODE = 1001 // 임의의 정수 값

    // checkCameraPermission 메서드 추가
    private fun checkCameraPermission() {
        if (ContextCompat.checkSelfPermission(this, Manifest.permission.CAMERA) != PackageManager.PERMISSION_GRANTED) {
            // 권한이 없으므로 요청
            ActivityCompat.requestPermissions(this, arrayOf(Manifest.permission.CAMERA), CAMERA_PERMISSION_REQUEST_CODE)
        } else {
            // 권한이 있으므로 카메라 실행
            Log.d("API_DEBUG", "Method call start")
            startFoodLensCamera()
        }
    }

    // onRequestPermissionsResult 메서드 추가
    override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<out String>, grantResults: IntArray) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode == CAMERA_PERMISSION_REQUEST_CODE) {
            if (grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                // 권한이 허용되었으므로 카메라 실행
                startFoodLensCamera()
            } else {
                // 권한이 거부됨
                Log.e("API_DEBUG", "Camera permission denied")
                // 필요하다면 Flutter로 에러를 전달할 수 있습니다.
            }
        }
    }

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
            override fun onSuccess(userSelectedResult: UserSelectedResult) {
                Log.d("API_DEBUG", "Camera success, processing results...")
                val foodPositions = userSelectedResult.foodPositions
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
                result.success(resultData)
            }

            override fun onCancel() {
                Log.d("API_DEBUG", "Camera cancelled by user.")
                result.error("CANCELLED", "카메라 사용 취소됨", null)
            }

            override fun onError(error: BaseError) {
                Log.e("API_DEBUG", "Camera error occurred: ${error.message}")
                result.error("ERROR", error.message, null)
            }
        })
    }

    private fun extractNutritionInfo(foodPositions: List<FoodPosition>?): Map<String, Any> {
        val food = foodPositions?.firstOrNull()?.foods?.firstOrNull()
        return if (food != null && food.nutrition != null) {
            val nutrition = food.nutrition
            val nutritionMap = mapOf(
                "칼슘" to nutrition.getCalcium().toDouble(),
                "단백질" to nutrition.getProtein().toDouble(),
                "식이섬유" to nutrition.getDietrayFiber().toDouble(),
                "탄수화물" to nutrition.getCarbonHydrate().toDouble(),
                "비타민C" to nutrition.getVitaminC().toDouble(),
                "지방" to nutrition.getFat().toDouble(),
                "비타민D" to nutrition.getVitaminD().toDouble(),
                "당" to nutrition.getSugar().toDouble()
            )
            Log.d("API_DEBUG", "Extracted nutrition info: $nutritionMap")
            nutritionMap
        } else {
            val defaultNutritionMap = mapOf(
                "칼슘" to 0.0,
                "단백질" to 0.0,
                "식이섬유" to 0.0,
                "탄수화물" to 0.0,
                "비타민C" to 0.0,
                "지방" to 0.0,
                "비타민D" to 0.0,
                "당" to 0.0
            )
            Log.d("API_DEBUG", "Default nutrition info returned: $defaultNutritionMap")
            defaultNutritionMap
        }
    }

     private fun processImageWithFoodLens(result: MethodChannel.Result) {
        Log.d("API_DEBUG", "Processing image with FoodLens...")

        // MethodChannel.Result를 멤버 변수로 저장하여 콜백에서 사용
        this.result = result

        uiService = FoodLens.createUIService(this)

        // 권한 확인 및 카메라 실행
        checkCameraPermission()
    }
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        uiService.onActivityResult(requestCode, resultCode, data)
    }
}