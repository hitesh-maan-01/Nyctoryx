package com.example.nyctoryx.native_services.permission_scanner

import android.content.Context

/**
 * Scanner for camera permissions
 */
class CameraPermissionScanner(private val context: Context) : PermissionCategoryScanner {
    private val permissionUtils = PermissionUtils(context)

    private val cameraPermissions = listOf(
        "android.permission.CAMERA"
    )

    override fun scanPermissions(packageName: String, requestedPermissions: List<String>): Map<String, Any> {
        // Check if any camera permissions are requested by the app
        val hasAnyCameraPermission = cameraPermissions.any { it in requestedPermissions }

        if (!hasAnyCameraPermission) {
            return emptyMap()
        }

        // Check permission status
        val cameraPermsWithStatus = permissionUtils.checkPermissionsWithStatus(packageName, cameraPermissions)

        if (cameraPermsWithStatus.isEmpty()) {
            return emptyMap()
        }

        return mapOf(
            "permissions" to cameraPermsWithStatus,
            "isGranted" to cameraPermsWithStatus.any { it.value }
        )
    }
}