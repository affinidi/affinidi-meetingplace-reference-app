package com.example.meetingplace

import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Context
import android.os.Build
import android.os.Bundle
import androidx.activity.enableEdgeToEdge
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.embedding.engine.FlutterEngineCache
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.plugins.GeneratedPluginRegistrant
    
class MainActivity: FlutterFragmentActivity() {
    companion object {
        private const val ENGINE_ID = "mpx"
        var engine: FlutterEngine? = null
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "com.example.meetingplace/device_region"
        ).setMethodCallHandler { call, result ->
            if (call.method == "getRegionCode") {
                result.success(java.util.Locale.getDefault().country)
            } else {
                result.notImplemented()
            }
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        enableEdgeToEdge()
        super.onCreate(savedInstanceState)

        if (engine == null) {
            engine = FlutterEngine(this).apply {
                dartExecutor.executeDartEntrypoint(DartExecutor.DartEntrypoint.createDefault())
                GeneratedPluginRegistrant.registerWith(this)
            }
            FlutterEngineCache.getInstance().put(ENGINE_ID, engine)
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val name = getString(R.string.channel_default_name)
            val description = getString(R.string.channel_default_description)

            val channel = NotificationChannel(
                "default_channel_id",
                name,
                NotificationManager.IMPORTANCE_HIGH
            ).apply {
                this.description = description
            }

            val notificationManager = getSystemService(NotificationManager::class.java)
            notificationManager.createNotificationChannel(channel)
        }
    }

    override fun provideFlutterEngine(context: Context): FlutterEngine? {
        return FlutterEngineCache.getInstance()[ENGINE_ID] ?: engine
    }

    override fun getCachedEngineId(): String? {
        return ENGINE_ID
    }
}
