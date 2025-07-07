package com.example.nyctoryx.native_services.permission_scanner

import android.content.Context

/**
 * Scanner for location permissions
 */
class LocationPermissionScanner(private val context: Context) : PermissionCategoryScanner {
    private val permissionUtils = PermissionUtils(context)

    private val locationPermissions = listOf(
        "android.permission.ACCESS_FINE_LOCATION",
        "android.permission.ACCESS_COARSE_LOCATION",
        "android.permission.ACCESS_BACKGROUND_LOCATION"
    )

    override fun scanPermissions(packageName: String, requestedPermissions: List<String>): Map<String, Any> {
        // Check if any location permissions are requested by the app
        val hasAnyLocationPermission = locationPermissions.any { it in requestedPermissions }

        if (!hasAnyLocationPermission) {
            return emptyMap()
        }

        // Check permission status
        val locationPermsWithStatus = permissionUtils.checkPermissionsWithStatus(packageName, locationPermissions)

        if (locationPermsWithStatus.isEmpty()) {
            return emptyMap()
        }

        val hasFineLocation = locationPermsWithStatus["android.permission.ACCESS_FINE_LOCATION"] == true
        val hasCoarseLocation = locationPermsWithStatus["android.permission.ACCESS_COARSE_LOCATION"] == true
        val hasBackgroundLocation = locationPermsWithStatus["android.permission.ACCESS_BACKGROUND_LOCATION"] == true

        // Determine location precision level
        val precisionLevel = when {
            hasFineLocation -> "HIGH_PRECISION"
            hasCoarseLocation -> "APPROXIMATE"
            else -> "NONE"
        }

        return mapOf(
            "permissions" to locationPermsWithStatus,
            "isGranted" to locationPermsWithStatus.any { it.value },
            "precisionLevel" to precisionLevel,
            "hasBackgroundAccess" to hasBackgroundLocation
        )
    }
}