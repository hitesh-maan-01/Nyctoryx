package com.example.nyctoryx.native_services.privacy_score

import com.example.nyctoryx.native_services.permission_scanner.MapConverter

/**
 * Calculator for app privacy scores based on permissions
 */
class PrivacyScoreCalculator {

    private val mapConverter = MapConverter()

    // Base permission penalties (higher value = more privacy intrusive)
    private val basePermissionPenalties = mapOf(
        "Camera" to 15,
        "Microphone" to 15,
        "Location" to 20,
        "Contacts" to 20,
        "Messages" to 25,
        "Storage" to 10,
        "Calls" to 15
    )

    /**
     * Calculate privacy score for a single app based on its permissions
     * @param appPermissions Map of permission categories to their data for this app
     * @return PrivacyScoreData with calculated scores and details
     */
    fun calculateAppPrivacyScore(appName: String, appPermissions: Map<String, Map<String, Any>>): PrivacyScoreData {
        var score = 100 // Start with perfect score
        val permissionDetails = mutableMapOf<String, PermissionDetail>()

        // Process each permission category
        for ((category, categoryData) in appPermissions) {
            val isGranted = categoryData["isGranted"] as? Boolean ?: false

            if (isGranted) {
                // Lookup base penalty for this permission category
                val basePenalty = basePermissionPenalties[category] ?: 0

                // Calculate actual penalty based on permission usage details
                val actualPenalty = calculateAdjustedPenalty(category, categoryData, basePenalty)
                score -= actualPenalty

                // Create permission detail with specific info
                val detail = createPermissionDetail(category, categoryData, actualPenalty)
                permissionDetails[category] = detail
            }
        }

        // Apply combined penalties for high-risk permission combinations
        val combinedPenalty = calculateCombinedPenalties(permissionDetails.keys)
        score -= combinedPenalty

        // Ensure score doesn't go below 0
        if (score < 0) score = 0

        // Risk level calculation
        val riskLevel = when {
            score >= 80 -> "LOW"
            score >= 50 -> "MEDIUM"
            else -> "HIGH"
        }

        return PrivacyScoreData(
            appName = appName,
            score = score,
            riskLevel = riskLevel,
            permissionDetails = permissionDetails
        )
    }

    /**
     * Calculate privacy scores for all apps based on their permissions
     * @param appsPermissions Map of package names to app permission data
     * @return Map of package names to privacy score data
     */
    fun calculateAllAppsPrivacyScores(appsPermissions: Map<String, Map<String, Any>>): Map<String, PrivacyScoreData> {
        val result = mutableMapOf<String, PrivacyScoreData>()

        appsPermissions.forEach { (packageName, appData) ->
            val appName = appData["appName"] as? String ?: packageName
            val permissionCategories = appData["permissionCategories"] as? Map<String, Map<String, Any>> ?: emptyMap()

            val privacyScore = calculateAppPrivacyScore(appName, permissionCategories)
            result[packageName] = privacyScore
        }

        return result
    }

    /**
     * Calculate adjusted penalty based on permission specifics
     */
    private fun calculateAdjustedPenalty(category: String, categoryData: Map<String, Any>, basePenalty: Int): Int {
        return when (category) {
            "Location" -> {
                val precisionLevel = categoryData["precisionLevel"] as? String ?: "UNKNOWN"
                val hasBackground = categoryData["hasBackgroundAccess"] as? Boolean ?: false

                var adjustedPenalty = basePenalty

                // Add extra penalty for background access
                if (hasBackground) {
                    adjustedPenalty += 10
                }

                // Add extra penalty for high precision
                if (precisionLevel == "HIGH_PRECISION") {
                    adjustedPenalty += 5
                }

                adjustedPenalty
            }
            "Contacts" -> {
                val accessLevel = categoryData["accessLevel"] as? String ?: "UNKNOWN"

                // Higher penalty for read-write access
                if (accessLevel == "READ_WRITE") {
                    basePenalty + 5
                } else {
                    basePenalty
                }
            }
            "Storage" -> {
                val canAccessAllFiles = categoryData["canAccessAllFiles"] as? Boolean ?: false

                // Higher penalty if app can access all files
                if (canAccessAllFiles) {
                    basePenalty + 10
                } else {
                    basePenalty
                }
            }
            "Messages" -> {
                val capabilities = categoryData["capabilities"] as? List<*> ?: emptyList<String>()

                // Higher penalty if app can both read and send messages
                if (capabilities.contains("READ") && capabilities.contains("SEND")) {
                    basePenalty + 10
                } else if (capabilities.contains("READ")) {
                    basePenalty + 5
                } else {
                    basePenalty
                }
            }
            else -> basePenalty
        }
    }

    /**
     * Calculate additional penalties for risky permission combinations
     */
    private fun calculateCombinedPenalties(grantedCategories: Set<String>): Int {
        var extraPenalty = 0

        // Location + Storage combination is particularly invasive
        if (grantedCategories.contains("Location") && grantedCategories.contains("Storage")) {
            extraPenalty += 10
        }

        // Camera + Microphone combination indicates potential surveillance
        if (grantedCategories.contains("Camera") && grantedCategories.contains("Microphone")) {
            extraPenalty += 5
        }

        // Location + Contacts is a high privacy risk
        if (grantedCategories.contains("Location") && grantedCategories.contains("Contacts")) {
            extraPenalty += 10
        }

        // Triple threat: Location + Camera + Microphone
        if (grantedCategories.contains("Location") &&
            grantedCategories.contains("Camera") &&
            grantedCategories.contains("Microphone")) {
            extraPenalty += 10
        }

        return extraPenalty
    }

    /**
     * Create detailed information about a specific permission category
     */
    private fun createPermissionDetail(category: String, categoryData: Map<String, Any>, penalty: Int): PermissionDetail {
        val description = when (category) {
            "Camera" -> "Can access your camera"
            "Microphone" -> "Can record audio"
            "Location" -> {
                val precisionLevel = categoryData["precisionLevel"] as? String ?: "UNKNOWN"
                val hasBackground = categoryData["hasBackgroundAccess"] as? Boolean ?: false

                if (hasBackground) {
                    "Can track your precise location in the background"
                } else if (precisionLevel == "HIGH_PRECISION") {
                    "Can access your precise location"
                } else {
                    "Can access your approximate location"
                }
            }
            "Contacts" -> {
                val accessLevel = categoryData["accessLevel"] as? String ?: "UNKNOWN"
                when (accessLevel) {
                    "READ_WRITE" -> "Can read and modify your contacts"
                    "READ_ONLY" -> "Can read your contacts"
                    "WRITE_ONLY" -> "Can modify your contacts"
                    else -> "Can access your contacts"
                }
            }
            "Messages" -> {
                val capabilities = categoryData["capabilities"] as? List<*> ?: emptyList<String>()
                when {
                    capabilities.contains("READ") && capabilities.contains("SEND") ->
                        "Can read and send SMS messages"
                    capabilities.contains("READ") ->
                        "Can read your SMS messages"
                    capabilities.contains("SEND") ->
                        "Can send SMS messages"
                    else ->
                        "Can access your SMS messages"
                }
            }
            "Storage" -> {
                val scopeDescription = categoryData["scopeDescription"] as? String ?: "Unknown storage access"
                "Can access files: $scopeDescription"
            }
            "Calls" -> {
                "Can make and manage phone calls"
            }
            else -> "Unknown permission"
        }

        return PermissionDetail(
            category = category,
            description = description,
            penaltyPoints = penalty
        )
    }

    /**
     * Prepares privacy score data for Flutter by ensuring proper type conversion
     */
    fun prepareForFlutter(privacyScoreData: Map<String, PrivacyScoreData>): Map<String, Any> {
        val flutterCompatibleMap = mutableMapOf<String, Any>()

        privacyScoreData.forEach { (packageName, scoreData) ->
            flutterCompatibleMap[packageName] = scoreData.toMap()
        }

        return mapConverter.convertMapToStringAnyMap(flutterCompatibleMap)
    }
}

/**
 * Data class to hold privacy score information for an app
 */
data class PrivacyScoreData(
    val appName: String,
    val score: Int,
    val riskLevel: String,
    val permissionDetails: Map<String, PermissionDetail>
) {
    /**
     * Convert to a Map for Flutter compatibility
     */
    fun toMap(): Map<String, Any> {
        val detailsMaps = mutableMapOf<String, Any>()
        permissionDetails.forEach { (category, detail) ->
            detailsMaps[category] = detail.toMap()
        }

        return mapOf(
            "appName" to appName,
            "score" to score,
            "riskLevel" to riskLevel,
            "permissionDetails" to detailsMaps
        )
    }
}

/**
 * Data class to hold detailed permission information
 */
data class PermissionDetail(
    val category: String,
    val description: String,
    val penaltyPoints: Int
) {
    /**
     * Convert to a Map for Flutter compatibility
     */
    fun toMap(): Map<String, Any> {
        return mapOf(
            "category" to category,
            "description" to description,
            "penaltyPoints" to penaltyPoints
        )
    }
}