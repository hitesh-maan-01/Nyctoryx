package com.example.nyctoryx.native_services.permission_scanner

import android.content.Context
import android.os.Build
import android.os.Environment

/**
 * Scanner for storage permissions
 */
class StoragePermissionScanner(private val context: Context) : PermissionCategoryScanner {
    private val permissionUtils = PermissionUtils(context)

    private val filePermissions = listOf(
        "android.permission.READ_EXTERNAL_STORAGE",
        "android.permission.WRITE_EXTERNAL_STORAGE",
        "android.permission.MANAGE_EXTERNAL_STORAGE",
        "android.permission.READ_MEDIA_IMAGES",
        "android.permission.READ_MEDIA_VIDEO",
        "android.permission.READ_MEDIA_AUDIO"
    )

    override fun scanPermissions(packageName: String, requestedPermissions: List<String>): Map<String, Any> {
        // Check if any storage permissions are requested by the app
        val hasAnyStoragePermission = filePermissions.any { it in requestedPermissions }

        if (!hasAnyStoragePermission) {
            return emptyMap()
        }

        // Check permission status
        val filePermsWithStatus = permissionUtils.checkPermissionsWithStatus(packageName, filePermissions)

        if (filePermsWithStatus.isEmpty()) {
            return emptyMap()
        }

        // Determine storage scope and permission level
        val storagePermInfo = determineStoragePermissionInfo(packageName, filePermsWithStatus)

        return mapOf(
            "permissions" to filePermsWithStatus,
            "isGranted" to storagePermInfo.isGranted,
            "scopeDescription" to storagePermInfo.scopeDescription,
            "permissionLevel" to storagePermInfo.permissionLevel,
            "canAccessAllFiles" to storagePermInfo.canAccessAllFiles
        )
    }

    // Data class to hold storage permission information
    data class StoragePermissionInfo(
        val isGranted: Boolean,
        val scopeDescription: String,
        val permissionLevel: String,
        val canAccessAllFiles: Boolean
    )

    // Determine detailed storage permission information
    private fun determineStoragePermissionInfo(packageName: String, permissions: Map<String, Boolean>): StoragePermissionInfo {
        // Check if the app has all files access (MANAGE_EXTERNAL_STORAGE) on Android 11+
        val hasAllFilesAccess = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            Environment.isExternalStorageManager() && permissions["android.permission.MANAGE_EXTERNAL_STORAGE"] == true
        } else {
            false
        }

        // Check for legacy storage permissions (pre-Android 11)
        val hasReadStorage = permissions["android.permission.READ_EXTERNAL_STORAGE"] == true
        val hasWriteStorage = permissions["android.permission.WRITE_EXTERNAL_STORAGE"] == true

        // Check for media-specific permissions (Android 10+)
        val hasMediaImages = permissions["android.permission.READ_MEDIA_IMAGES"] == true
        val hasMediaVideo = permissions["android.permission.READ_MEDIA_VIDEO"] == true
        val hasMediaAudio = permissions["android.permission.READ_MEDIA_AUDIO"] == true

        // Determine if any storage permission is granted
        val isAnyGranted = hasAllFilesAccess || hasReadStorage || hasWriteStorage ||
                hasMediaImages || hasMediaVideo || hasMediaAudio

        // Get app's target SDK version to understand how permissions are interpreted
        val targetSdkVersion = permissionUtils.getTargetSdkVersion(packageName)

        // Determine actual effective permissions based on Android version and app's target SDK
        val actualAccessLevel = determineActualPermissionLevel(
            targetSdkVersion,
            hasAllFilesAccess,
            hasReadStorage,
            hasWriteStorage,
            hasMediaImages,
            hasMediaVideo,
            hasMediaAudio
        )

        // Determine permission level and scope description based on effective permissions
        val (permLevel, scopeDesc, canAccessAll) = when (actualAccessLevel) {
            "ALL_FILES_ACCESS" -> Triple(
                "ALL_FILES_ACCESS",
                "All files (Allows accessing, modifying and deleting all files)",
                true
            )
            "LEGACY_FULL_STORAGE" -> Triple(
                "FULL_EXTERNAL_STORAGE",
                "All files (via legacy permissions)",
                true
            )
            "LEGACY_MEDIA_ONLY" -> Triple(
                "MEDIA_ONLY_LEGACY",
                "Media only (via legacy permissions)",
                false
            )
            "MEDIA_ONLY" -> Triple(
                "MEDIA_ACCESS",
                "Media files (Photos, videos, and audio)",
                false
            )
            "IMAGES_AND_VIDEOS" -> Triple(
                "IMAGES_AND_VIDEOS",
                "Media files (Images and videos only)",
                false
            )
            "IMAGES_ONLY" -> Triple(
                "IMAGES_ONLY",
                "Media files (Images only)",
                false
            )
            "AUDIO_ONLY" -> Triple(
                "AUDIO_ONLY",
                "Media files (Audio only)",
                false
            )
            "READ_ONLY" -> Triple(
                "READ_ONLY_EXTERNAL_STORAGE",
                "External storage (Read only)",
                false
            )
            else -> Triple(
                "NO_STORAGE_ACCESS",
                "No storage access",
                false
            )
        }

        return StoragePermissionInfo(
            isGranted = isAnyGranted,
            scopeDescription = scopeDesc,
            permissionLevel = permLevel,
            canAccessAllFiles = canAccessAll
        )
    }

    // Helper method to determine actual permission level considering target SDK and Android version
    private fun determineActualPermissionLevel(
        targetSdkVersion: Int,
        hasAllFilesAccess: Boolean,
        hasReadStorage: Boolean,
        hasWriteStorage: Boolean,
        hasMediaImages: Boolean,
        hasMediaVideo: Boolean,
        hasMediaAudio: Boolean
    ): String {
        // If app has special all files access, that overrides everything
        if (hasAllFilesAccess) {
            return "ALL_FILES_ACCESS"
        }

        // Check Android version - API 29 (Android 10) introduced scoped storage
        val currentAndroidVersion = Build.VERSION.SDK_INT

        // Special case for apps targeting pre-scoped storage but running on newer Android
        if (targetSdkVersion < 29 && currentAndroidVersion >= 29) {
            // Legacy apps with read/write permissions get media access only on Android 10+
            // unless they've been granted special compatibility
            if (hasReadStorage && hasWriteStorage) {
                // On Android 10+ without special permission, this is now "Media only"
                return "LEGACY_MEDIA_ONLY"
            } else if (hasReadStorage) {
                return "READ_ONLY"
            }
        } else if (targetSdkVersion < 29) {
            // Apps targeting pre-Android 10 with both read/write get full access on older devices
            if (hasReadStorage && hasWriteStorage) {
                return "LEGACY_FULL_STORAGE"
            } else if (hasReadStorage) {
                return "READ_ONLY"
            }
        }

        // For apps targeting Android 10+ or running on Android 10+ without legacy permissions
        if (hasMediaImages && hasMediaVideo && hasMediaAudio) {
            return "MEDIA_ONLY"
        } else if (hasMediaImages && hasMediaVideo) {
            return "IMAGES_AND_VIDEOS"
        } else if (hasMediaImages) {
            return "IMAGES_ONLY"
        } else if (hasMediaAudio) {
            return "AUDIO_ONLY"
        } else if (hasReadStorage && !hasWriteStorage) {
            return "READ_ONLY"
        }

        return "NO_STORAGE_ACCESS"
    }
}