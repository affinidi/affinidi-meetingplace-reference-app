import Amplify
import AWSCognitoAuthPlugin
import Flutter
import UIKit

public class FaceLivenessDetectorPlugin: NSObject, FlutterPlugin {
    private static var amplifyConfigured = false

    public static func register(with registrar: FlutterPluginRegistrar) {
        configureAmplifyIfNeeded()

        let handler = EventStreamHadler()
        let eventChannel = FlutterEventChannel(
            name: "face_liveness_event",
            binaryMessenger: registrar.messenger()
        )
        eventChannel.setStreamHandler(handler)

        let factory = FaceLivenessViewFactory(
            messenger: registrar.messenger(),
            handler: handler
        )
        registrar.register(factory, withId: "face_liveness_view")
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        result(FlutterMethodNotImplemented)
    }

    private static func configureAmplifyIfNeeded() {
        guard !amplifyConfigured else { return }

        do {
            try Amplify.add(plugin: AWSCognitoAuthPlugin())
        } catch {
            NSLog("FaceLivenessDetectorPlugin: Auth plugin add skipped: \(error)")
        }

        do {
            try Amplify.configure()
            amplifyConfigured = true
            NSLog("FaceLivenessDetectorPlugin: Amplify configured for Face Liveness")
        } catch {
            NSLog("FaceLivenessDetectorPlugin: Amplify configure failed: \(error)")
        }
    }
}

class EventStreamHadler: NSObject, FlutterStreamHandler {
    private var eventSink: FlutterEventSink?

    func onComplete() {
        guard let eventSink = eventSink else {
            return
        }
        eventSink("complete")
    }

    func onError(code: String) {
        guard let eventSink = eventSink else {
            return
        }
        eventSink(code)
    }

    func onListen(
        withArguments arguments: Any?,
        eventSink events: @escaping FlutterEventSink
    ) -> FlutterError? {
        eventSink = events
        return nil
    }

    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        eventSink = nil
        return nil
    }
}
