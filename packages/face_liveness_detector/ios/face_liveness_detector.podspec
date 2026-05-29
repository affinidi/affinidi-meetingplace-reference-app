#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint face_liveness_detector.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'face_liveness_detector'
  s.version          = '0.2.3'
  s.summary          = 'AWS Rekognition Face Liveness detection for Flutter'
  s.description      = <<-DESC
A Flutter plugin for AWS Rekognition Face Liveness detection, allowing secure face biometric verification through AWS's Rekognition service.
Note: This plugin requires manual setup of AWS Amplify Face Liveness dependencies in Xcode.
                       DESC
  s.homepage         = 'https://github.com/raichandramohan27ca/amplify-flutter-face-liveness'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'raichandramohan27ca' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'face_liveness_detector/Sources/face_liveness_detector/**/*.swift'
  s.dependency 'Flutter'
  s.platform = :ios, '11.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
  
  # This is essential for proper module naming in Swift
  s.module_name = 'face_liveness_detector'
  s.static_framework = true
end