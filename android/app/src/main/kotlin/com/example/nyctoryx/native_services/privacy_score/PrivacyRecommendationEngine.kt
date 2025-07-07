package com.example.nyctoryx.native_services.privacy_score

/**
 * Generates privacy recommendations based on app permissions
 */
class PrivacyRecommendationEngine {

    /**
     * Generate recommendations for an app based on its privacy score data
     * @param appName Name of the app
     * @param privacyScore Privacy score data for the app
     * @return List of recommendations
     */
    fun generateAppRecommendations(appName: String, privacyScore: PrivacyScoreData): List<PrivacyRecommendation> {
        val recommendations = mutableListOf<PrivacyRecommendation>()

        // Add general recommendation based on risk level
        when (privacyScore.riskLevel) {
            "HIGH" -> {
                recommendations.add(
                    PrivacyRecommendation(
                        title = "Consider alternatives to $appName",
                        description = "This app has a very high privacy risk score (${privacyScore.score}/100). " +
                                "Consider looking for alternative apps with similar functionality but fewer permission requirements.",
                        priority = "HIGH",
                        actionType = "REVIEW_APP"
                    )
                )
            }
            "MEDIUM" -> {
                recommendations.add(
                    PrivacyRecommendation(
                        title = "Review permissions for $appName",
                        description = "This app has several privacy-sensitive permissions. " +
                                "Consider reviewing if all these permissions are necessary for your usage.",
                        priority = "MEDIUM",
                        actionType = "REVIEW_PERMISSIONS"
                    )
                )
            }
        }

        // Add specific recommendations based on permissions
        privacyScore.permissionDetails.forEach { (category, detail) ->
            when (category) {
                "Location" -> {
                    recommendations.add(
                        PrivacyRecommendation(
                            title = "Restrict location access",
                            description = "Consider setting location permission to 'While using the app' instead of 'Always' " +
                                    "to prevent background tracking.",
                            priority = "HIGH",
                            actionType = "MODIFY_PERMISSION"
                        )
                    )
                }
                "Camera" -> {
                    recommendations.add(
                        PrivacyRecommendation(
                            title = "Review camera usage",
                            description = "This app can access your camera. If you don't use features requiring " +
                                    "this permission, consider revoking it in your device settings.",
                            priority = "MEDIUM",
                            actionType = "MODIFY_PERMISSION"
                        )
                    )
                }
                "Microphone" -> {
                    recommendations.add(
                        PrivacyRecommendation(
                            title = "Review microphone usage",
                            description = "This app can record audio. Consider revoking this permission if you don't " +
                                    "use features that require voice recording or calls.",
                            priority = "MEDIUM",
                            actionType = "MODIFY_PERMISSION"
                        )
                    )
                }
                "Contacts" -> {
                    recommendations.add(
                        PrivacyRecommendation(
                            title = "Protect your contacts",
                            description = "This app has access to your contacts. Consider if this is necessary, " +
                                    "as contact information is sensitive personal data.",
                            priority = "HIGH",
                            actionType = "MODIFY_PERMISSION"
                        )
                    )
                }
                "Messages" -> {
                    recommendations.add(
                        PrivacyRecommendation(
                            title = "Review SMS access",
                            description = "This app can access your SMS messages, which may include sensitive information " +
                                    "like 2FA codes. This is a significant privacy risk.",
                            priority = "HIGH",
                            actionType = "MODIFY_PERMISSION"
                        )
                    )
                }
                "Storage" -> {
                    // Check if the app has all files access
                    val canAccessAllFiles = privacyScore.permissionDetails[category]?.description?.contains("All files") == true

                    if (canAccessAllFiles) {
                        recommendations.add(
                            PrivacyRecommendation(
                                title = "Limit complete storage access",
                                description = "This app has access to all your files. Consider limiting it to media-only access " +
                                        "if possible through your device settings.",
                                priority = "HIGH",
                                actionType = "MODIFY_PERMISSION"
                            )
                        )
                    } else {
                        recommendations.add(
                            PrivacyRecommendation(
                                title = "Limit storage access",
                                description = "Consider restricting what files this app can access through your device settings.",
                                priority = "LOW",
                                actionType = "MODIFY_PERMISSION"
                            )
                        )
                    }
                }
                "Calls" -> {
                    recommendations.add(
                        PrivacyRecommendation(
                            title = "Review phone call access",
                            description = "This app can make calls and access call history. Only allow this if you regularly " +
                                    "use the app for call-related features.",
                            priority = "MEDIUM",
                            actionType = "MODIFY_PERMISSION"
                        )
                    )
                }
            }
        }

        // Check for risky permission combinations and add specific recommendation
        val categories = privacyScore.permissionDetails.keys

        if (categories.contains("Location") && categories.contains("Contacts")) {
            recommendations.add(
                PrivacyRecommendation(
                    title = "High-risk permission combination",
                    description = "This app has access to both your location and contacts. This combination could " +
                            "potentially map your social network's physical locations - a significant privacy risk.",
                    priority = "HIGH",
                    actionType = "REVIEW_APP"
                )
            )
        }

        if (categories.contains("Camera") && categories.contains("Microphone") && categories.contains("Storage")) {
            recommendations.add(
                PrivacyRecommendation(
                    title = "Surveillance capability",
                    description = "This app has camera, microphone, and storage access - giving it the capability to " +
                            "record and store audio/video. Use with caution if these features aren't core to the app's function.",
                    priority = "HIGH",
                    actionType = "REVIEW_APP"
                )
            )
        }

        return recommendations
    }

    /**
     * Generate system-wide privacy recommendations
     * @param systemScore Overall system score data
     * @param appScores Map of app scores
     * @return List of system recommendations
     */
    fun generateSystemRecommendations(
        systemScore: Map<String, Any>,
        appScores: Map<String, PrivacyScoreData>
    ): List<PrivacyRecommendation> {
        val recommendations = mutableListOf<PrivacyRecommendation>()

        // Get risk statistics
        val overallScore = systemScore["overallScore"] as? Int ?: 0
        val highRiskApps = systemScore["highRiskApps"] as? Int ?: 0
        val totalApps = systemScore["totalAppsScanned"] as? Int ?: 0

        // Add overall recommendations
        if (highRiskApps > 0) {
            recommendations.add(
                PrivacyRecommendation(
                    title = "Review high-risk apps",
                    description = "Your device has $highRiskApps high-risk apps that have access to sensitive personal data. " +
                            "Consider reviewing or replacing these apps to improve your privacy.",
                    priority = "HIGH",
                    actionType = "REVIEW_APPS"
                )
            )
        }

        // Check for permission patterns
        var appsWithLocationAccess = 0
        var appsWithContactsAccess = 0
        var appsWithStorageAccess = 0
        var appsWithCameraAccess = 0
        var appsWithMicrophoneAccess = 0
        var appsWithMessagesAccess = 0
        var appsWithCallsAccess = 0

        appScores.values.forEach { scoreData ->
            if (scoreData.permissionDetails.containsKey("Location")) {
                appsWithLocationAccess++
            }
            if (scoreData.permissionDetails.containsKey("Contacts")) {
                appsWithContactsAccess++
            }
            if (scoreData.permissionDetails.containsKey("Storage")) {
                appsWithStorageAccess++
            }
            if (scoreData.permissionDetails.containsKey("Camera")) {
                appsWithCameraAccess++
            }
            if (scoreData.permissionDetails.containsKey("Microphone")) {
                appsWithMicrophoneAccess++
            }
            if (scoreData.permissionDetails.containsKey("Messages")) {
                appsWithMessagesAccess++
            }
            if (scoreData.permissionDetails.containsKey("Calls")) {
                appsWithCallsAccess++
            }
        }

        // Add recommendations based on patterns
        if (appsWithLocationAccess > 3) {
            recommendations.add(
                PrivacyRecommendation(
                    title = "Many apps accessing location",
                    description = "You have $appsWithLocationAccess apps with location permission. " +
                            "Consider if all these apps truly need your location data.",
                    priority = "HIGH",
                    actionType = "REVIEW_PERMISSION_CATEGORY"
                )
            )
        }

        if (appsWithContactsAccess > 2) {
            recommendations.add(
                PrivacyRecommendation(
                    title = "Multiple apps accessing contacts",
                    description = "You have $appsWithContactsAccess apps with contact access. " +
                            "This increases the risk of your contact information being shared without your knowledge.",
                    priority = "MEDIUM",
                    actionType = "REVIEW_PERMISSION_CATEGORY"
                )
            )
        }

        if (appsWithMessagesAccess > 0) {
            recommendations.add(
                PrivacyRecommendation(
                    title = "Apps with SMS access",
                    description = "You have $appsWithMessagesAccess apps with SMS access. This is a significant privacy risk " +
                            "as messages may contain 2FA codes or personal information.",
                    priority = "HIGH",
                    actionType = "REVIEW_PERMISSION_CATEGORY"
                )
            )
        }

        if (appsWithCameraAccess > 5) {
            recommendations.add(
                PrivacyRecommendation(
                    title = "Many apps with camera access",
                    description = "You have $appsWithCameraAccess apps with camera access. Consider limiting this permission " +
                            "to only apps you regularly use for photos or video.",
                    priority = "MEDIUM",
                    actionType = "REVIEW_PERMISSION_CATEGORY"
                )
            )
        }

        // Calculate percentage of high-risk apps
        val highRiskPercentage = if (totalApps > 0) (highRiskApps.toFloat() / totalApps.toFloat()) * 100 else 0f

        // Add overall privacy health recommendation
        val healthTitle: String
        val healthDescription: String
        val healthPriority: String

        when {
            overallScore >= 80 -> {
                healthTitle = "Good privacy health"
                healthDescription = "Your device's privacy health is good with an overall score of $overallScore/100. " +
                        "Continue monitoring your app permissions regularly."
                healthPriority = "LOW"
            }
            overallScore >= 50 -> {
                healthTitle = "Moderate privacy concerns"
                healthDescription = "Your device has an overall privacy score of $overallScore/100, indicating moderate " +
                        "privacy concerns. Review the recommended actions to improve your privacy."
                healthPriority = "MEDIUM"
            }
            else -> {
                healthTitle = "Significant privacy risks"
                healthDescription = "Your device has an overall privacy score of $overallScore/100, indicating significant " +
                        "privacy risks. Immediate action is recommended to protect your personal data."
                healthPriority = "HIGH"
            }
        }

        recommendations.add(
            PrivacyRecommendation(
                title = healthTitle,
                description = healthDescription,
                priority = healthPriority,
                actionType = "PRIVACY_HEALTH"
            )
        )

        // Add general privacy practices
        recommendations.add(
            PrivacyRecommendation(
                title = "Regular privacy audit",
                description = "Schedule a monthly review of app permissions to ensure they align with your usage.",
                priority = "LOW",
                actionType = "PRIVACY_PRACTICE"
            )
        )

        recommendations.add(
            PrivacyRecommendation(
                title = "Use privacy-focused alternatives",
                description = "Consider open-source or privacy-focused alternatives for essential apps.",
                priority = "MEDIUM",
                actionType = "PRIVACY_PRACTICE"
            )
        )

        return recommendations
    }
}

/**
 * Data class for privacy recommendations
 */
data class PrivacyRecommendation(
    val title: String,
    val description: String,
    val priority: String,
    val actionType: String
) {
    /**
     * Convert to a Map for Flutter compatibility
     */
    fun toMap(): Map<String, Any> {
        return mapOf(
            "title" to title,
            "description" to description,
            "priority" to priority,
            "actionType" to actionType
        )
    }
}