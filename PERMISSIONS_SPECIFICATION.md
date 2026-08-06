# Montager Platform Permissions Specification
## Step 5: iOS Info.plist + Android 13+ Permissions

This document specifies the exact changes needed to the iOS Info.plist and AndroidManifest.xml files to implement the required permissions for the Montager AI Video Editor app, as specified in Step 5 of the development plan from the August 2nd recap.

## 📱 iOS Permissions (Info.plist)

Add the following keys to the `Info.plist` file located at `ios/Runner/Info.plist`:

```xml
<!-- Privacy - Media Library Access Required for Android 13+ equivalent on iOS -->
<key>NSAppleMusicUsageDescription</key>
<string>Montager needs access to your media library to import videos for editing</string>

<!-- Privacy - Photo Library Additions Usage Description -->
<key>NSPhotoLibraryAddUsageDescription</key>
<string>Montager needs to save edited videos to your photo library</string>

<!-- Privacy - Photo Library Usage Description -->
<key>NSPhotoLibraryUsageDescription</key>
<string>Montager needs access to your photo library to import videos for editing</string>

<!-- Privacy - Camera Usage Description (for potential future camera features) -->
<key>NSCameraUsageDescription</key>
<string>Montager may use the camera to capture video directly for editing</string>

<!-- Privacy - Microphone Usage Description (for audio recording) -->
<key>NSMicrophoneUsageDescription</key>
<string>Montager needs access to the microphone to record audio for video projects</string>

<!-- Privacy - Location When In Use Usage Description (optional, for geo-tagging) -->
<key>NSLocationWhenInUseUsageDescription</key>
<string>Montager may use your location to geotag videos (optional feature)</string>

<!-- Privacy - Local Network Usage Description (for potential local network features) -->
<key>NSLocalNetworkUsageDescription</key>
<string>Montager may use local network for device-to-device video sharing</string>
```

### Required iOS Framework Linking
In addition to the Info.plist changes, ensure these frameworks are linked in the Xcode project:
- `Photos.framework` (for photo library access)
- `AVFoundation.framework` (for audio/video processing)
- `AssetsLibrary.framework` (for iOS < 11 compatibility, if needed)

## 🤖 Android Permissions (AndroidManifest.xml)

Add the following permissions to the `AndroidManifest.xml` file located at `android/app/src/main/AndroidManifest.xml` within the `<manifest>` tag:

```xml
<!-- Required for accessing external storage (Android 12 and below) -->
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" 
                 android:maxSdkVersion="28" />

<!-- Required for accessing media files (Android 13+) -->
<uses-permission android:name="android.permission.READ_MEDIA_VIDEO" />
<uses-permission android:name="android.permission.READ_MEDIA_IMAGES" />
<uses-permission android:name="android.permission.READ_MEDIA_AUDIO" />

<!-- Required for saving media files -->
<uses-permission android:name="android.permission.WRITE_MEDIA_VIDEO" />
<uses-permission android:name="android.permission.WRITE_MEDIA_IMAGES" />
<uses-permission android:name="android.permission.WRITE_MEDIA_AUDIO" />

<!-- Required for internet access (needed for AI API calls) -->
<uses-permission android:name="android.permission.INTERNET" />

<!-- Optional: For location-based features -->
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />

<!-- Optional: For Bluetooth or NFC features -->
<uses-permission android:name="android.permission.BLUETOOTH" />
<uses-permission android:name="android.permission.BLUETOOTH_ADMIN" />
```

### Android 13+ Runtime Permission Handling
For Android 13 (API level 33) and above, these permissions are considered "dangerous" and must be requested at runtime. Add the following to your `MainActivity.java` or `MainActivity.kt`:

#### Java Example:
```java
@Override
protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    FlutterEngine flutterEngine = new FlutterEngine(this);
    // ... existing Flutter initialization ...

    // Request runtime permissions for Android 13+
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
        String[] permissions = {
            Manifest.permission.READ_MEDIA_VIDEO,
            Manifest.permission.READ_MEDIA_IMAGES,
            Manifest.permission.READ_MEDIA_AUDIO
        };
        requestPermissions(permissions, PERMISSION_REQUEST_CODE);
    }
}

// Handle permission results
@Override
public void onRequestPermissionsResult(int requestCode, @NonNull String[] permissions,
                                     @NonNull int[] grantResults) {
    super.onRequestPermissionsResult(requestCode, permissions, grantResults);
    if (requestCode == PERMISSION_REQUEST_CODE) {
        // Check if all required permissions were granted
        boolean allGranted = true;
        for (int result : grantResults) {
            if (result != PackageManager.PERMISSION_GRANTED) {
                allGranted = false;
                break;
            }
        }
        if (!allGranted) {
            // Handle permission denial - show explanation or disable features
        }
    }
}
```

#### Kotlin Equivalent:
```kotlin
override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)
    // ... Flutter initialization ...
    
    // Request runtime permissions for Android 13+
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
        val permissions = arrayOf(
            Manifest.permission.READ_MEDIA_VIDEO,
            Manifest.permission.READ_MEDIA_IMAGES,
            Manifest.permission.READ_MEDIA_AUDIO
        )
        requestPermissions(permissions, PERMISSION_REQUEST_CODE)
    }
}

override fun onRequestPermissionsResult(
    requestCode: Int, permissions: Array<String>, grantResults: IntArray
) {
    super.onRequestPermissionsResult(requestCode, permissions, grantResults)
    if (requestCode == PERMISSION_REQUEST_CODE) {
        // Check if all required permissions were granted
        val allGranted = grantResults.all { it == PackageManager.PERMISSION_GRANTED }
        if (!allGranted) {
            // Handle permission denial
        }
    }
}
```

## 🔒 Permission Rationale for App Store Submission

### iOS Justification:
- **NSPhotoLibraryUsageDescription**: Required for importing user videos for editing
- **NSPhotoLibraryAddUsageDescription**: Required for saving edited videos to user's library
- **NSAppleMusicUsageDescription**: Alternative description some Apple reviewers check for media access
- **NSCameraUsageDescription**: Prepares for future camera capture features
- **NSMicrophoneUsageDescription**: Required for audio recording/video narration features
- **NSLocationWhenInUseUsageDescription**: Optional but recommended for potential geo-tagging features

### Android Justification:
- **READ_MEDIA_VIDEO/IMAGES/AUDIO**: Required for Android 13+ (API 33+) to access media files
- **READ_EXTERNAL_STORAGE/WRITE_EXTERNAL_STORAGE**: Required for Android 12- (API 32-) for backward compatibility
- **WRITE_MEDIA_*:** Required for saving processed media files back to storage
- **INTERNET**: Required for API calls to AI services (Together AI, Ollama Cloud)
- **ACCESS_FINE_LOCATION**: Optional for geo-tagging features (include only if actually used)
- **BLUETOOTH:** Optional for future device connectivity features

## ⚠️ Important Implementation Notes

### Testing Requirements:
1. **iOS**: Test on real device (simulator may not accurately reflect permission behavior)
2. **Android**: Test on Android 12 (API 31) and Android 13 (API 33) devices to verify both permission systems work
3. **Denial Handling**: App should gracefully handle when users deny permissions
4. **Rationale Display**: System will show the provided strings when requesting permissions

### Privacy Considerations:
- Only request permissions that are actually used by the app
- Consider using `android:required="false"` for optional permissions if implementing runtime checks
- Provide clear explanations in the permission dialogs why access is needed
- Implement graceful degradation when permissions are denied

### App Store/Play Store Submission:
- Apple App Store: Ensure all purpose strings are locally formatted and truthful
- Google Play Play: Declare permission usage appropriately in the Play Console
- Both platforms may reject apps that request unnecessary permissions

## 🔗 Integration with Existing Montager Features

These permissions support the core Montager functionality:
- **Video Import**: READ_EXTERNAL_STORAGE / READ_MEDIA_* for accessing user videos
- **Video Export**: WRITE_EXTERNAL_STORAGE / WRITE_MEDIA_* for saving edited videos
- **AI Processing**: INTERNET for calling Together AI and Ollama Cloud APIs
- **Enhanced Features**: Optional permissions for location, camera, microphone for future features
- **Audio Processing**: MICROPHONE for voice narration and audio capture features

## ✅ Verification Checklist

Before submitting to app stores, verify:
- [ ] Info.plist contains all required privacy keys with meaningful descriptions
- [ ] AndroidManifest.xml contains all required permissions
- [ ] Runtime permission handling implemented for Android 13+
- [ ] App handles permission denials gracefully
- [ ] Permission dialogs show the provided explanations
- [ ] No unnecessary permissions are requested
- [ ] All permissions are actually used by implemented features

---
*This specification provides the exact implementation needed for Step 5 of the Montager development plan: "iOS Info.plist + Android 13+ permissions"*