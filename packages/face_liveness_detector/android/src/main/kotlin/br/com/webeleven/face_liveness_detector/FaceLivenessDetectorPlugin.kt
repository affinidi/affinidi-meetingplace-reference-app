package br.com.webeleven.face_liveness_detector

import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.EventChannel
import android.util.Log
import br.com.webeleven.rekognitionFaceLiveness.rekognition_face_liveness.EventStreamHandler
import br.com.webeleven.rekognitionFaceLiveness.rekognition_face_liveness.FaceLivenessDetectorPlugin as OriginalPlugin
import br.com.webeleven.rekognitionFaceLiveness.rekognition_face_liveness.FaceLivenessViewFactory

/** FaceLivenessDetectorPlugin */
class FaceLivenessDetectorPlugin: FlutterPlugin {
  private val TAG = "FaceLivenessDetectorPlugin"
  private val delegate = OriginalPlugin()
  
  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    delegate.onAttachedToEngine(flutterPluginBinding)
    Log.i(TAG, "FaceLivenessDetectorPlugin initialized through the new package path")
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    delegate.onDetachedFromEngine(binding)
  }
} 