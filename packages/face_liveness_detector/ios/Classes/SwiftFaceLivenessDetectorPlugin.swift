import Flutter
import UIKit
import face_liveness_detector

public class SwiftFaceLivenessDetectorPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    // Forward registration to our actual plugin implementation
    // The FaceLivenessPlugin class needs to match the class name in the face_liveness_detector module
    let handler = EventStreamHadler()
    let eventChannel = FlutterEventChannel(name: "face_liveness_event", binaryMessenger: registrar.messenger())
    eventChannel.setStreamHandler(handler)
    
    let factory = FaceLivenessViewFactory(messenger: registrar.messenger(), handler: handler)
    registrar.register(factory, withId: "face_liveness_view")
    
    print("FaceLivenessPlugin initialized with custom credentials provider")
  }
  
  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    result(FlutterMethodNotImplemented)
  }
} 