package com.example.nyctoryx.native_services.permission_scanner

import android.content.Context

/**
 * Scanner for contacts permissions
 */
class ContactsPermissionScanner(private val context: Context) : PermissionCategoryScanner {
    private val permissionUtils = PermissionUtils(context)

    private val contactsPermissions = listOf(
        "android.permission.READ_CONTACTS",
        "android.permission.WRITE_CONTACTS",
        "android.permission.GET_ACCOUNTS"
    )

    override fun scanPermissions(packageName: String, requestedPermissions: List<String>): Map<String, Any> {
        // Check if any contacts permissions are requested by the app
        val hasAnyContactsPermission = contactsPermissions.any { it in requestedPermissions }

        if (!hasAnyContactsPermission) {
            return emptyMap()
        }

        // Check permission status
        val contactsPermsWithStatus = permissionUtils.checkPermissionsWithStatus(packageName, contactsPermissions)

        if (contactsPermsWithStatus.isEmpty()) {
            return emptyMap()
        }

        val canRead = contactsPermsWithStatus["android.permission.READ_CONTACTS"] == true
        val canWrite = contactsPermsWithStatus["android.permission.WRITE_CONTACTS"] == true
        val canAccessAccounts = contactsPermsWithStatus["android.permission.GET_ACCOUNTS"] == true

        // Determine access level
        val accessLevel = when {
            canRead && canWrite -> "READ_WRITE"
            canRead -> "READ_ONLY"
            canWrite -> "WRITE_ONLY"
            else -> "NONE"
        }

        return mapOf(
            "permissions" to contactsPermsWithStatus,
            "isGranted" to contactsPermsWithStatus.any { it.value },
            "accessLevel" to accessLevel,
            "canAccessAccounts" to canAccessAccounts
        )
    }
}