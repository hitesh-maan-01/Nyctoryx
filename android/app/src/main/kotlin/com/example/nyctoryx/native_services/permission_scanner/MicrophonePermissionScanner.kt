package com.example.appscannertwo.native_services.permission_scanner

import android.content.Context

/**
 * Scanner for microphone permissions
 */
class MicrophonePermissionScanner(private val context: Context) : PermissionCategoryScanner {
    private val permissionUtils = PermissionUtils(context)

    private val microphonePermissions = listOf(
        "android.permission.RECORD_AUDIO"
    )

    override fun scanPermissions(packageName: String, requestedPermissions: List<String>): Map<String, Any> {
        // Check if any microphone permissions are requested by the app
        val hasAnyMicPermission = microphonePermissions.any { it in requestedPermissions }

        if (!hasAnyMicPermission) {
            return emptyMap()
        }

        // Check permission status
        val micPermsWithStatus = permissionUtils.checkPermissionsWithStatus(packageName, microphonePermissions)

        if (micPermsWithStatus.isEmpty()) {
            return emptyMap()
        }

        return mapOf(
            "permissions" to micPermsWithStatus,
            "isGranted" to micPermsWithStatus.any { it.value }
        )
    }
}