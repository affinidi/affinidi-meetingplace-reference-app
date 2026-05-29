#import "FaceLivenessDetectorPlugin.h"
#if __has_include(<face_liveness_detector/face_liveness_detector-Swift.h>)
#import <face_liveness_detector/face_liveness_detector-Swift.h>
#elif __has_include(<face-liveness-detector/face-liveness-detector-Swift.h>)
#import <face-liveness-detector/face-liveness-detector-Swift.h>
#else
#import "face_liveness_detector-Swift.h"
#endif

@implementation FaceLivenessDetectorPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFaceLivenessDetectorPlugin registerWithRegistrar:registrar];
}
@end 