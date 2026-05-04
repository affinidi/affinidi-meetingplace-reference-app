# iOS Build Configuration

## Required Build Settings for ZKP Support

The ZKP proof generation features (using `flutter_rapidsnark` and `circom_witnesscalc`) require C++ standard library linkage. 

### One-Time Setup Required

**You must configure these build settings once** in your Xcode project:

1. Open your Xcode project (`Runner.xcodeproj` or your renamed project file)
2. Select your app target in the left sidebar
3. Go to **Build Settings** tab
4. Search for **Other Linker Flags** (or `OTHER_LDFLAGS`)
5. Double-click to edit and add: `-lc++`
6. Search for **C++ Standard Library** (or `CLANG_CXX_LIBRARY`)
7. Set it to: `libc++`

**Important:** This is a one-time setup. You need to configure this before building the app for iOS.

These settings ensure that the native ZKP libraries can properly link against the C++ standard library.

## SQLCipher Configuration

The app uses SQLCipher for encrypted database storage with Drift. The Podfile automatically removes the system SQLite linker flag to prevent conflicts with SQLCipher.

**Note:** After making changes to Pod configuration, verify that:
- Drift database operations work correctly
- SQLCipher encryption is functioning
- No linker errors occur during build
