package com.example.money_tracker

import android.content.ContentValues
import android.os.Build
import android.provider.MediaStore
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.money_tracker/export"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "exportToDownloads" -> {
                    val filename = call.argument<String>("filename") ?: "money_tracker_backup.json"
                    val payload = call.argument<String>("payload") ?: ""
                    try {
                        val values = ContentValues().apply {
                            put(MediaStore.MediaColumns.DISPLAY_NAME, filename)
                            put(MediaStore.MediaColumns.MIME_TYPE, "application/json")
                            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                                put(MediaStore.MediaColumns.RELATIVE_PATH, "Download/Money Tracker")
                            }
                        }
                        val resolver = applicationContext.contentResolver
                        // Try to use MediaStore-based insertion when available (API 29+). Fall back to legacy file write on older devices.
                        try {
                            val contentUri = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                                // Prefer Downloads collection. Access via reflection to avoid NoClassDefFoundError on some devices.
                                val downloadsUri = try {
                                    val downloadsClass = Class.forName("android.provider.MediaStore\$Downloads")
                                    val field = downloadsClass.getField("EXTERNAL_CONTENT_URI")
                                    field.get(null) as? android.net.Uri
                                } catch (t: Throwable) {
                                    null
                                }
                                downloadsUri ?: MediaStore.Files.getContentUri("external")
                            } else {
                                null
                            }

                            if (contentUri != null) {
                                val uri = resolver.insert(contentUri, values)
                                    ?: throw Exception("Failed to create file in Downloads")
                                resolver.openOutputStream(uri).use { out ->
                                    out?.write(payload.toByteArray())
                                    out?.flush()
                                }
                                result.success(filename)
                            } else {
                                // Legacy write path for API < 29
                                val downloadsDir = android.os.Environment.getExternalStoragePublicDirectory(android.os.Environment.DIRECTORY_DOWNLOADS)
                                val folder = java.io.File(downloadsDir, "Money Tracker")
                                if (!folder.exists()) folder.mkdirs()
                                val outFile = java.io.File(folder, filename)
                                outFile.outputStream().use { out ->
                                    out.write(payload.toByteArray())
                                    out.flush()
                                }
                                // Make file visible to media scanners
                                android.media.MediaScannerConnection.scanFile(
                                    applicationContext,
                                    arrayOf(outFile.absolutePath),
                                    arrayOf("application/json"),
                                    null,
                                )
                                result.success(outFile.absolutePath)
                            }
                        } catch (e: Exception) {
                            result.error("EXPORT_ERROR", e.message, null)
                        }
                    } catch (e: Exception) {
                        result.error("EXPORT_ERROR", e.message, null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }
}
