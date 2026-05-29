import FaceLiveness
import Flutter
import SwiftUI

class FaceLivenessView: NSObject, FlutterPlatformView {
    private var _view: UIView

    init(
        frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?,
        binaryMessenger messenger: FlutterBinaryMessenger?,
        handler: EventStreamHadler
    ) {
        _view = UIView()
        super.init()

        createNativeView(view: _view, arguments: args, handler: handler)
    }

    func view() -> UIView {
        return _view
    }

    func createNativeView(
        view _view: UIView,
        arguments args: Any?,
        handler: EventStreamHadler
    ) {
        guard let args = args as? [String: Any] else { return }

        let keyWindows = UIApplication.shared.windows.first(where: { $0.isKeyWindow })
            ?? UIApplication.shared.windows.first
        let topController = keyWindows?.rootViewController

        let vc = UIHostingController(
            rootView: NativeView(
                sessionId: args["sessionId"] as! String,
                region: args["region"] as! String,
                handler: handler
            )
        )

        let swiftUiView = vc.view!
        swiftUiView.translatesAutoresizingMaskIntoConstraints = false

        topController?.addChild(vc)
        _view.addSubview(swiftUiView)

        NSLayoutConstraint.activate(
            [
                swiftUiView.leadingAnchor.constraint(equalTo: _view.leadingAnchor),
                swiftUiView.trailingAnchor.constraint(equalTo: _view.trailingAnchor),
                swiftUiView.topAnchor.constraint(equalTo: _view.topAnchor),
                swiftUiView.bottomAnchor.constraint(equalTo: _view.bottomAnchor),
            ])

        vc.didMove(toParent: topController)
    }
}

struct NativeView: View {
    let sessionId: String
    let region: String
    let handler: EventStreamHadler

    @State private var isPresentingLiveness = true

    init(sessionId: String, region: String, handler: EventStreamHadler) {
        self.sessionId = sessionId
        self.region = region
        self.handler = handler
    }

    var body: some View {
        FaceLivenessDetectorView(
            sessionID: self.sessionId,
            region: self.region,
            isPresented: $isPresentingLiveness,
            onCompletion: { result in
                switch result {
                case .success:
                    handler.onComplete()
                case .failure(let error):
                    handler.onError(code: Self.errorCode(for: error))
                }
            }
        )
    }

    private static func errorCode(for error: FaceLivenessDetectionError) -> String {
        switch error {
        case .userCancelled:
            return "userCancelled"
        case .sessionTimedOut:
            return "sessionTimedOut"
        case .sessionNotFound:
            return "sessionNotFound"
        case .accessDenied:
            return "accessDenied"
        case .cameraPermissionDenied:
            return "cameraPermissionDenied"
        case .invalidRegion:
            return "invalidRegion"
        case .cameraNotAvailable:
            return "cameraNotAvailable"
        default:
            return error.message
        }
    }
}
