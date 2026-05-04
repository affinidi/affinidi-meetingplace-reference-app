# iOS Build Configuration

## Required Build Settings for ZKP Support

The ZKP proof generation features (using `flutter_rapidsnark` and `circom_witnesscalc`) require C++ standard library linkage. 

### Manual Configuration

If you need to manually configure the build settings (e.g., if you've renamed the `Runner.xcodeproj` file or prefer manual setup), add the following to your project's build settings:

1. Open your Xcode project
2. Select your target (e.g., `Runner`)
3. Go to **Build Settings**
4. Find **Other Linker Flags** (`OTHER_LDFLAGS`)
5. Add `-lc++` to the flags
6. Find **C++ Standard Library** (`CLANG_CXX_LIBRARY`)  
7. Set it to `libc++`

These settings ensure that the native ZKP libraries can properly link against the C++ standard library.

## SQLCipher Configuration

The app uses SQLCipher for encrypted database storage with Drift. The Podfile automatically removes the system SQLite linker flag to prevent conflicts with SQLCipher.

**Note:** After making changes to Pod configuration, verify that:
- Drift database operations work correctly
- SQLCipher encryption is functioning
- No linker errors occur during build
