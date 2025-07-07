package com.example.nyctoryx.native_services.permission_scanner

import android.content.Context
import android.content.pm.PackageManager

/**
 * Utility class for permission checks
 */
class PermissionUtils(private val context: Context) {
    private val packageManager = context.packageManager

    /**
     * Checks which permissions from the provided list are granted for a package
     * @param packageName The package name to check permissions for
     * @param permissionsList List of permissions to check
     * @return Map of permission names to their grant status
     */
    fun checkPermissionsWithStatus(packageName: String, permissionsList: List<String>): Map<String, Boolean> {
        val result = mutableMapOf<String, Boolean>()

        for (permission in permissionsList) {
            try {
                val requestedPerms = packageManager.getPackageInfo(packageName, PackageManager.GET_PERMISSIONS)
                    .requestedPermissions ?: emptyArray()

                // Only check if the app has requested this permission
                if (permission in requestedPerms) {
                    val permissionStatus = packageManager.checkPermission(permission, packageName)
                    result[permission] = permissionStatus == PackageManager.PERMISSION_GRANTED
                }
            } catch (e: Exception) {
                // Skip if we can't check
            }
        }

        return result
    }

    /**
     * Gets the target SDK version for a package
     * @param packageName The package name to check
     * @return Target SDK version or 0 if it can't be determined
     */
    fun getTargetSdkVersion(packageName: String): Int {
        return try {
            packageManager.getApplicationInfo(packageName, 0).targetSdkVersion
        } catch (e: Exception) {
            0 // Default value if we can't determine
        }
    }
}