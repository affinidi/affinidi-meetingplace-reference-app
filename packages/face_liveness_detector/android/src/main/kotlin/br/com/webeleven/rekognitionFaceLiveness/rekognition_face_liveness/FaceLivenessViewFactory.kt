package br.com.webeleven.rekognitionFaceLiveness.rekognition_face_liveness

import android.content.Context
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory

class FaceLivenessViewFactory(private val handler: EventStreamHandler) : PlatformViewFactory(StandardMessageCodec.INSTANCE) {
    override fun create(context: Context?, viewId: Int, args: Any?): PlatformView {
        val creationParams = args as Map<String?, Any?>?
        return FaceLivenessView(context!!, viewId, creationParams, handler)
    }
}