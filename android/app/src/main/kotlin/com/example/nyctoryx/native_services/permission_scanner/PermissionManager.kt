package com.example.nyctoryx.native_services.permission_scanner

import android.content.Context
import android.content.pm.ApplicationInfo
import android.content.pm.PackageManager

/**
 * Main class responsible for coordinating permission scanning across the application
 */
class PermissionManager(private val context: Context) {

    // Permission scanners
    private val cameraScanner = CameraPermissionScanner(context)
    private val storageScanner = StoragePermissionScanner(context)
    private val microphoneScanner = MicrophonePermissionScanner(context)
    private val locationScanner = LocationPermissionScanner(context)
    private val contactsScanner = ContactsPermissionScanner(context)
    private val messagesScanner = MessagesPermissionScanner(context)

    // Utility instance for permission checks
    private val permissionUtil = PermissionUtils(context)

    // Utility for Flutter compatibility
    private val mapConverter = MapConverter()

    /**
     * Scans all non-system applications for permission usage
     * @return Map of package names to app information including granted permissions
     */
    fun scanAppPermissions(): Map<String, Map<String, Any>> {
        val pm = context.packageManager
        val apps = pm.getInstalledApplications(PackageManager.GET_META_DATA)
        val result = mutableMapOf<String, Map<String, Any>>()

        // Process each application
        for (appInfo in apps) {
            // Skip system apps
            if ((appInfo.flags and ApplicationInfo.FLAG_SYSTEM) != 0) {
                continue
            }

            val packageName = appInfo.packageName

            // Get app name
            val appName = try {
                pm.getApplicationLabel(appInfo).toString()
            } catch (e: Exception) {
                packageName  // Use package name as fallback
            }

            // Get all requested permissions for this app
            val requestedPermissions = try {
                val packageInfo = pm.getPackageInfo(packageName, PackageManager.GET_PERMISSIONS)
                packageInfo.requestedPermissions?.toList() ?: emptyList()
            } catch (e: Exception) {
                emptyList<String>()
            }

            // Scan all permission categories for this app
            val permissionCategories = mutableMapOf<String, Map<String, Any>>()

            // Add each category's results to the map
            scanAndAddCategory(permissionCategories, "Camera", cameraScanner, packageName, requestedPermissions)
            scanAndAddCategory(permissionCategories, "Storage", storageScanner, packageName, requestedPermissions)
            scanAndAddCategory(permissionCategories, "Microphone", microphoneScanner, packageName, requestedPermissions)
            scanAndAddCategory(permissionCategories, "Location", locationScanner, packageName, requestedPermissions)
            scanAndAddCategory(permissionCategories, "Contacts", contactsScanner, packageName, requestedPermissions)
            scanAndAddCategory(permissionCategories, "Messages", messagesScanner, packageName, requestedPermissions)

            // Only include apps with at least one relevant permission
            if (permissionCategories.isNotEmpty()) {
                result[packageName] = mapOf(
                    "appName" to appName,
                    "permissionCategories" to permissionCategories
                )
            }
        }

        return result
    }

    /**
     * Helper method to scan a permission category and add results to the categories map
     */
    private fun scanAndAddCategory(
        categoriesMap: MutableMap<String, Map<String, Any>>,
        categoryName: String,
        scanner: PermissionCategoryScanner,
        packageName: String,
        requestedPermissions: List<String>
    ) {
        val scanResult = scanner.scanPermissions(packageName, requestedPermissions)
        if (scanResult.isNotEmpty()) {
            categoriesMap[categoryName] = scanResult
        }
    }

    /**
     * Prepares permission data for Flutter by ensuring proper type conversion
     */
    fun prepareForFlutter(permissionsData: Map<String, Map<String, Any>>): Map<String, Any> {
        val flutterCompatibleMap = mutableMapOf<String, Any>()

        permissionsData.forEach { (key, value) ->
            flutterCompatibleMap[key] = mapConverter.convertMapToStringAnyMap(value)
        }

        return flutterCompatibleMap
    }
}