
package com.example.nyctoryx.native_services.permission_scanner

/**
 * Utility class for converting maps to be Flutter-compatible
 */
class MapConverter {
    /**
     * Converts nested maps to ensure they're compatible with Flutter
     * @param map The map to convert
     * @return Flutter-compatible map
     */
    fun convertMapToStringAnyMap(map: Map<String, Any>): Map<String, Any> {
        val result = mutableMapOf<String, Any>()

        map.forEach { (key, value) ->
            when (value) {
                is Map<*, *> -> {
                    // Convert nested maps to ensure they're Map<String, Any>
                    @Suppress("UNCHECKED_CAST")
                    val nestedMap = value as? Map<String, Any> ?: mapOf<String, Any>()
                    result[key] = convertMapToStringAnyMap(nestedMap)
                }
                is List<*> -> {
                    // Handle lists by converting any map elements
                    val newList = value.map { item ->
                        if (item is Map<*, *>) {
                            @Suppress("UNCHECKED_CAST")
                            convertMapToStringAnyMap(item as Map<String, Any>)
                        } else {
                            item
                        }
                    }
                    result[key] = newList
                }
                else -> {
                    result[key] = value
                }
            }
        }

        return result
    }
}
