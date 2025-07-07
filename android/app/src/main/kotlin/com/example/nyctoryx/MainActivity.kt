package com.example.nyctoryx 

import android.content.Context
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import com.example.nyctoryx.native_services.permission_scanner.PermissionManager
import com.example.nyctoryx.native_services.privacy_score.PrivacyScoreManager

class MainActivity: FlutterActivity() {
    private val PERMISSIONS_CHANNEL = "com.example.nyctoryx/permissions"
    private val PRIVACY_SCORE_CHANNEL = "com.example.nyctoryx/privacy_score"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Method channel for app permissions
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, PERMISSIONS_CHANNEL).setMethodCallHandler {
                call, result ->

            when (call.method) {
                "getAppPermissions" -> {
                    try {
                        // Create an instance of our new PermissionManager
                        val permissionManager = PermissionManager(context)

                        // Get the raw permissions data using the new manager
                        val permissionsData = permissionManager.scanAppPermissions()

                        // Convert to Flutter-compatible format using the manager's utility method
                        val flutterCompatibleMap = permissionManager.prepareForFlutter(permissionsData)

                        // Transform the map into a List<Map<String, Any>> under "appPermissions"
                        val appList = (flutterCompatibleMap as Map<String, Map<String, Any>>).map { (pkg, data) ->
                            val appName = data["appName"] as? String ?: pkg
                            val categories = data["permissionCategories"] as? Map<String, Map<String, Any>> ?: emptyMap()
                            val permsList = categories.map { (category, catData) ->
                                mapOf(
                                    "permissionName" to category,
                                    "isGranted" to (catData["isGranted"] as? Boolean ?: false),
                                    "riskLevel" to (catData["riskLevel"] as? String ?: "MEDIUM")
                                )
                            }
                            mapOf(
                                "packageName" to pkg,
                                "appName" to appName,
                                "permissions" to permsList
                            )
                        }

                        // Return wrapped under appPermissions key
                        result.success(mapOf("appPermissions" to appList))
                    } catch (e: Exception) {
                        result.error("PERMISSIONS_ERROR", "Failed to get app permissions", e.message)
                    }
                }
                else -> {
                    result.notImplemented()
                }
            }
        }

        // Method channel for privacy scores
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, PRIVACY_SCORE_CHANNEL).setMethodCallHandler {
                call, result ->

            when (call.method) {
                "getAppPrivacyScores" -> {
                    try {
                        val privacyScoreManager = PrivacyScoreManager(context)
                        val appPrivacyScores = privacyScoreManager.getAppPrivacyScores()
                        result.success(appPrivacyScores)
                    } catch (e: Exception) {
                        result.error("PRIVACY_SCORE_ERROR", "Failed to calculate privacy scores", e.message)
                    }
                }
                "getSystemPrivacyScore" -> {
                    try {
                        val privacyScoreManager = PrivacyScoreManager(context)
                        val systemPrivacyScore = privacyScoreManager.getSystemPrivacyScore()
                        result.success(systemPrivacyScore)
                    } catch (e: Exception) {
                        result.error("PRIVACY_SCORE_ERROR", "Failed to calculate system privacy score", e.message)
                    }
                }
                "getAppRecommendations" -> {
                    try {
                        val packageName = call.argument<String>("packageName")
                        if (packageName == null) {
                            result.error("ARGUMENT_ERROR", "Package name is required", null)
                            return@setMethodCallHandler
                        }

                        val privacyScoreManager = PrivacyScoreManager(context)
                        val recommendations = privacyScoreManager.getAppRecommendations(packageName)
                        result.success(recommendations)
                    } catch (e: Exception) {
                        result.error("PRIVACY_SCORE_ERROR", "Failed to get recommendations", e.message)
                    }
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }
}
