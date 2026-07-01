import UIKit
import Flutter
import Firebase
import FirebaseCore
import FirebaseMessaging

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        NSLog("AppDelegate: Starting Firebase configuration...")
        FirebaseApp.configure()
        NSLog("AppDelegate: Firebase configured successfully")
        
        Messaging.messaging().delegate = self
        NSLog("AppDelegate: Firebase Messaging delegate set")
        
        UNUserNotificationCenter.current().delegate = self as UNUserNotificationCenterDelegate
        
        if #available(iOS 10.0, *) {
            DispatchQueue.main.async {
                application.registerForRemoteNotifications()
                NSLog("AppDelegate: Requested remote notifications registration")
            }
        }
        
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
        GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
        NSLog("AppDelegate: Registered plugins with implicit Flutter engine")

        let registrar = engineBridge.pluginRegistry.registrar(
            forPlugin: "DeviceRegionPlugin"
        )
        guard let messenger = registrar?.messenger() else {
            NSLog("AppDelegate: DeviceRegionPlugin - failed to get messenger from registrar")
            return
        }
        let channel = FlutterMethodChannel(
            name: "com.affinidi.mpx.meetingplace/device_region",
            binaryMessenger: messenger
        )
        channel.setMethodCallHandler { (call, result) in
            if call.method == "getRegionCode" {
                result(Locale.current.region?.identifier)
            } else {
                result(FlutterMethodNotImplemented)
            }
        }
    }
    
    override func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
        NSLog("AppDelegate: APNS token set in Firebase Messaging")
        
        super.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
    }
    
    override func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        NSLog("AppDelegate: Failed to register for remote notifications: %@", error.localizedDescription)
        
        super.application(application, didFailToRegisterForRemoteNotificationsWithError: error)
    }
}

// MARK: - MessagingDelegate
extension AppDelegate: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        NSLog("Firebase: Registration token received: %@", String(describing: fcmToken))
        
        guard let fcmToken = fcmToken else {
            return
        }
        
        #if DEBUG
        // In DEBUG mode and on Simulators, there are scenarios where an fcmToken is received even when an APNS token has not yet arrived. 
        // This can lead to issues in testing push notifications. 
        // To mitigate this issue, we set a sample APNS token when the DEBUG flag is active.
        NSLog("DEBUG flag is active")
        if Messaging.messaging().apnsToken == nil {
            let sampleToken = Data([
                0x80, 0xc3, 0x48, 0x12, 0x6e, 0x61, 0x8e, 0x40,
                0xa8, 0xd3, 0x77, 0x3f, 0xf0, 0xa5, 0x97, 0xba,
                0x5b, 0xec, 0xd8, 0x29, 0x52, 0x4a, 0x00, 0x43,
                0x63, 0x7b, 0xa7, 0x86, 0x6f, 0x40, 0x28, 0xba
            ])
            Messaging.messaging().apnsToken = sampleToken
            NSLog("Sample APNS token set for DEBUG")
        } else {
            NSLog("APNS token is already SET")
        }
        #endif
        
        let fcmTokenData: [String: String] = ["token": fcmToken]
        NotificationCenter.default
            .post(name: Notification.Name("FCMToken"), object: nil, userInfo: fcmTokenData)
    }
}
