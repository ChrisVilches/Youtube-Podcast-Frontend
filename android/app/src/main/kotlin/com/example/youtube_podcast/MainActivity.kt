package com.example.youtube_podcast

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File


class MainActivity : FlutterActivity() {
    private val channel = "youtube_podcast_methods_channel"

    private fun getFileList(dir: String): List<String> {
        return File(dir).walk().filter { it.path != dir }.map { it.name }.toList()
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger, channel
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "getFileList" -> {
                    val dir: String = call.argument<String>("path")!!
                    val allPaths: List<String> = getFileList(dir)
                    result.success(allPaths)
                }
                else -> result.notImplemented()
            }
        }
    }
}
