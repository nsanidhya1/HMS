package com.example.untitled

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.media.MediaScannerConnection
import android.util.Log

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.yourapp/mediaScanner"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Setup platform channel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "scanFile") {
                val filePath = call.argument<String>("path")
                if (filePath != null) {
                    scanFile(filePath)
                    result.success(true)
                } else {
                    result.error("INVALID_PATH", "File path cannot be null", null)
                }
            } else {
                result.notImplemented()
            }
        }
    }

    // Method to scan a file so it appears in file explorer
    private fun scanFile(path: String) {
        Log.d("MediaScanner", "Scanning file: $path")

        try {
            // Use MediaScannerConnection to scan the file
            MediaScannerConnection.scanFile(
                context,
                arrayOf(path),
                null
            ) { path, uri ->
                Log.d("MediaScanner", "Scan completed: $path, URI: $uri")
            }

            // For older devices, broadcast an additional intent
            if (Build.VERSION.SDK_INT < Build.VERSION_CODES.N) {
                val mediaScanIntent = Intent(Intent.ACTION_MEDIA_SCANNER_SCAN_FILE)
                val contentUri = Uri.fromFile(java.io.File(path))
                mediaScanIntent.data = contentUri
                context.sendBroadcast(mediaScanIntent)
            }
        } catch (e: Exception) {
            Log.e("MediaScanner", "Error scanning file: ${e.message}")
        }
    }
}