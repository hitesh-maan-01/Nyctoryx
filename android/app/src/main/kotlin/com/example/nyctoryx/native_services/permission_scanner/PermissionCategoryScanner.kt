package com.example.nyctoryx.native_services.permission_scanner

/**
 * Interface for permission category scanners
 */
interface PermissionCategoryScanner {
    /**
     * Scans the specified package for permissions within this category
     * @param packageName The package name to scan
     * @param requestedPermissions List of permissions requested by the app
     * @return Map containing permission data for this category
     */
    fun scanPermissions(packageName: String, requestedPermissions: List<String>): Map<String, Any>
}