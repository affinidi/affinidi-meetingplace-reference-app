# iOS Dependencies Setup Guide

This project uses AWS Amplify Face Liveness which requires manual Swift Package Manager setup.

## Setup Steps

### 1. Open Xcode Project
```bash
cd ios
open Runner.xcworkspace
```

### 2. Add AWS Amplify Swift Package
1. In Xcode, go to **File → Add Package Dependencies...**
2. Enter URL: `https://github.com/aws-amplify/amplify-swift`
3. Select version: `2.46.1` or later
4. Choose products: `Amplify`, `AWSCognitoAuthPlugin`
5. Click **Add Package**

### 3. Add AWS Amplify UI Liveness Package
1. Go to **File → Add Package Dependencies...**
2. Enter URL: `https://github.com/aws-amplify/amplify-ui-swift-liveness`
3. Select version: `1.3.5` or later  
4. Choose product: `FaceLiveness`
5. Click **Add Package**

### 4. Verify Setup
1. Build the project (`Cmd+B`)
2. Ensure no compilation errors
3. Dependencies should appear in Project Navigator under "Package Dependencies"

## For CI/CD

Ensure your CI/CD system:
- Uses Xcode 14.0 or later
- Has the project files with Swift Package Manager configuration committed
- Runs `flutter pub get` before building

## Troubleshooting

**If you see "No such module 'FaceLiveness'" errors:**
1. Clean build folder (`Cmd+Shift+K`)
2. Clear derived data
3. Re-add the packages if necessary
4. Ensure both packages are added to the correct target

**Package resolution issues:**
1. Delete `ios/Runner.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/`
2. Re-add packages manually
3. Commit the new resolution files 