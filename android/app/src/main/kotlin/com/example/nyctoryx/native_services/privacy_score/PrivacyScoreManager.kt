package com.example.nyctoryx.native_services.privacy_score

import android.content.Context
import com.example.nyctoryx.native_services.permission_scanner.PermissionManager
import com.example.nyctoryx.native_services.permission_scanner.MapConverter

/**
 * Manager class for handling privacy score calculations
 * This integrates with the existing permission scanning system
 */
class PrivacyScoreManager(private val context: Context) {

    private val permissionManager = PermissionManager(context)
    private val privacyScoreCalculator = PrivacyScoreCalculator()
    private val recommendationEngine = PrivacyRecommendationEngine()
    private val mapConverter = MapConverter()

    /**
     * Calculate privacy scores for all apps and prepare for Flutter
     * @return Flutter-compatible map of privacy scores
     */
    fun getAppPrivacyScores(): Map<String, Any> {
        // Get permission data from the permission manager
        val permissionsData = permissionManager.scanAppPermissions()

        // Calculate privacy scores based on permissions
        val privacyScores = privacyScoreCalculator.calculateAllAppsPrivacyScores(permissionsData)

        // Prepare data for Flutter
        return privacyScoreCalculator.prepareForFlutter(privacyScores)
    }

    /**
     * Get an overall system privacy score based on all installed apps
     * @return Overall privacy score information
     */
    fun getSystemPrivacyScore(): Map<String, Any> {
        // Get all app scores first
        val permissionsData = permissionManager.scanAppPermissions()
        val privacyScores = privacyScoreCalculator.calculateAllAppsPrivacyScores(permissionsData)

        // Calculate average score
        var totalScore = 0
        privacyScores.values.forEach { scoreData ->
            totalScore += scoreData.score
        }

        val averageScore = if (privacyScores.isNotEmpty()) {
            totalScore / privacyScores.size
        } else {
            100 // Default to 100 if no apps with permissions
        }

        // Count apps by risk level
        var highRiskApps = 0
        var mediumRiskApps = 0
        var lowRiskApps = 0

        privacyScores.values.forEach { scoreData ->
            when (scoreData.riskLevel) {
                "HIGH" -> highRiskApps++
                "MEDIUM" -> mediumRiskApps++
                "LOW" -> lowRiskApps++
            }
        }

        // Get system recommendations
        val systemOverview = mapOf(
            "overallScore" to averageScore,
            "riskLevel" to when {
                averageScore >= 80 -> "LOW"
                averageScore >= 50 -> "MEDIUM"
                else -> "HIGH"
            },
            "totalAppsScanned" to privacyScores.size,
            "highRiskApps" to highRiskApps,
            "mediumRiskApps" to mediumRiskApps,
            "lowRiskApps" to lowRiskApps
        )

        val recommendations = recommendationEngine.generateSystemRecommendations(
            systemOverview,
            privacyScores
        )

        val recommendationMaps = recommendations.map { it.toMap() }

        // Create result map with recommendations
        val result = mapOf(
            "overallScore" to averageScore,
            "riskLevel" to when {
                averageScore >= 80 -> "LOW"
                averageScore >= 50 -> "MEDIUM"
                else -> "HIGH"
            },
            "totalAppsScanned" to privacyScores.size,
            "highRiskApps" to highRiskApps,
            "mediumRiskApps" to mediumRiskApps,
            "lowRiskApps" to lowRiskApps,
            "recommendations" to recommendationMaps
        )

        return mapConverter.convertMapToStringAnyMap(result)
    }

    /**
     * Get recommendations for a specific app
     * @param packageName The package name of the app
     * @return Map with recommendations for this app
     */
    fun getAppRecommendations(packageName: String): Map<String, Any> {
        // Get permissions and calculate privacy score
        val permissionsData = permissionManager.scanAppPermissions()

        if (!permissionsData.containsKey(packageName)) {
            return mapOf(
                "error" to "App not found",
                "recommendations" to emptyList<Map<String, Any>>()
            )
        }

        val appData = permissionsData[packageName]!!
        val appName = appData["appName"] as? String ?: packageName
        val permissionCategories = appData["permissionCategories"] as? Map<String, Map<String, Any>> ?: emptyMap()

        val privacyScore = privacyScoreCalculator.calculateAppPrivacyScore(appName, permissionCategories)

        // Get recommendations
        val recommendations = recommendationEngine.generateAppRecommendations(appName, privacyScore)
        val recommendationMaps = recommendations.map { it.toMap() }

        val result = mapOf(
            "appName" to appName,
            "score" to privacyScore.score,
            "riskLevel" to privacyScore.riskLevel,
            "recommendations" to recommendationMaps
        )

        return mapConverter.convertMapToStringAnyMap(result)
    }
}