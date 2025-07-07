package com.example.nyctoryx.native_services.permission_scanner

import android.content.Context

/**
 * Scanner for SMS/MMS messages permissions
 */
class MessagesPermissionScanner(private val context: Context) : PermissionCategoryScanner {
    private val permissionUtils = PermissionUtils(context)

    private val messagesPermissions = listOf(
        "android.permission.READ_SMS",
        "android.permission.SEND_SMS",
        "android.permission.RECEIVE_SMS",
        "android.permission.RECEIVE_MMS",
        "android.permission.READ_CELL_BROADCASTS"
    )

    override fun scanPermissions(packageName: String, requestedPermissions: List<String>): Map<String, Any> {
        // Check if any messages permissions are requested by the app
        val hasAnyMessagesPermission = messagesPermissions.any { it in requestedPermissions }

        if (!hasAnyMessagesPermission) {
            return emptyMap()
        }

        // Check permission status
        val messagesPermsWithStatus = permissionUtils.checkPermissionsWithStatus(packageName, messagesPermissions)

        if (messagesPermsWithStatus.isEmpty()) {
            return emptyMap()
        }

        val canReadSms = messagesPermsWithStatus["android.permission.READ_SMS"] == true
        val canSendSms = messagesPermsWithStatus["android.permission.SEND_SMS"] == true
        val canReceiveSms = messagesPermsWithStatus["android.permission.RECEIVE_SMS"] == true
        val canReceiveMms = messagesPermsWithStatus["android.permission.RECEIVE_MMS"] == true

        // Determine capabilities
        val capabilities = mutableListOf<String>()
        if (canReadSms) capabilities.add("READ")
        if (canSendSms) capabilities.add("SEND")
        if (canReceiveSms) capabilities.add("RECEIVE_SMS")
        if (canReceiveMms) capabilities.add("RECEIVE_MMS")

        return mapOf(
            "permissions" to messagesPermsWithStatus,
            "isGranted" to messagesPermsWithStatus.any { it.value },
            "capabilities" to capabilities
        )
    }
}