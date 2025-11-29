# DhobiGo App Icon Setup Guide

This guide will help you replace the Flutter default icons with your DhobiGo logo across all platforms.

## Prerequisites
- Have your `logo.png` file ready (1024x1024 pixels, PNG format)
- Place it in: `Laundry_App/assets/images/logo.png`

## Method 1: Using flutter_launcher_icons (Recommended)

### Step 1: Add flutter_launcher_icons to pubspec.yaml

Add this to your `pubspec.yaml` under `dev_dependencies`:

```yaml
dev_dependencies:
  flutter_launcher_icons: ^0.13.1
```

### Step 2: Configure flutter_launcher_icons

Add this configuration at the bottom of your `pubspec.yaml`:

```yaml
flutter_launcher_icons:
  android: true
  ios: true
  image_path: "assets/images/logo.png"
  min_sdk_android: 21
  
  # Optional: Different icons for different platforms
  # android: "launcher_icon"
  # ios: true
  
  # Adaptive icon (Android 8.0+)
  adaptive_icon_background: "#87CEEB"  # Sky blue color
  adaptive_icon_foreground: "assets/images/logo.png"
  
  # Web
  web:
    generate: true
    image_path: "assets/images/logo.png"
    background_color: "#87CEEB"
    theme_color: "#87CEEB"
  
  # Windows
  windows:
    generate: true
    image_path: "assets/images/logo.png"
    icon_size: 48
  
  # macOS
  macos:
    generate: true
    image_path: "assets/images/logo.png"
```

### Step 3: Run the generator

```powershell
# Install the package
flutter pub get

# Generate icons
flutter pub run flutter_launcher_icons
```

---

## Method 2: Manual Setup (Alternative)

### Android Icons

1. Generate icons using online tools like:
   - https://icon.kitchen/
   - https://www.appicon.co/
   - https://makeappicon.com/

2. Place the generated icons in:
   ```
   android/app/src/main/res/mipmap-hdpi/ic_launcher.png (72x72)
   android/app/src/main/res/mipmap-mdpi/ic_launcher.png (48x48)
   android/app/src/main/res/mipmap-xhdpi/ic_launcher.png (96x96)
   android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png (144x144)
   android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png (192x192)
   ```

3. For adaptive icons (Android 8.0+):
   ```
   android/app/src/main/res/mipmap-*/ic_launcher_foreground.png
   android/app/src/main/res/drawable/ic_launcher_background.xml
   ```

### iOS Icons

1. Open Xcode: `ios/Runner.xcworkspace`

2. Navigate to: Runner > Assets.xcassets > AppIcon.appiconset

3. Replace all icon sizes:
   - 20x20 @2x, @3x
   - 29x29 @2x, @3x
   - 40x40 @2x, @3x
   - 60x60 @2x, @3x
   - 1024x1024

### Web Icons

Replace these files in `web/icons/`:
```
Icon-192.png (192x192)
Icon-512.png (512x512)
Icon-maskable-192.png (192x192)
Icon-maskable-512.png (512x512)
```

Update `web/manifest.json`:
```json
{
  "name": "DhobiGo",
  "short_name": "DhobiGo",
  "icons": [
    {
      "src": "icons/Icon-192.png",
      "sizes": "192x192",
      "type": "image/png"
    },
    {
      "src": "icons/Icon-512.png",
      "sizes": "512x512",
      "type": "image/png"
    }
  ]
}
```

### Windows Icons

Generate a `.ico` file from your logo and replace:
```
windows/runner/resources/app_icon.ico
```

### macOS Icons

Open Xcode: `macos/Runner.xcworkspace`

Navigate to: Runner > Assets.xcassets > AppIcon.appiconset

Replace all icon sizes similar to iOS.

---

## Quick Commands

```powershell
# After setting up flutter_launcher_icons in pubspec.yaml:

# Get dependencies
flutter pub get

# Generate all icons
flutter pub run flutter_launcher_icons

# Clean and rebuild
flutter clean
flutter pub get

# Run on device to see new icon
flutter run
```

---

## Verification

After generating icons, verify them by:

1. **Android**: Build and install the app
   ```powershell
   flutter build apk
   flutter install
   ```

2. **iOS**: Build and run in simulator
   ```powershell
   flutter build ios
   flutter run -d ios
   ```

3. Check the app icon on the home screen

---

## Troubleshooting

### Icons not updating:
```powershell
flutter clean
flutter pub get
flutter pub run flutter_launcher_icons
flutter run
```

### For Android:
```powershell
cd android
./gradlew clean
cd ..
flutter run
```

### For iOS:
- Open Xcode and clean build folder: Product > Clean Build Folder
- Or use: `cd ios && rm -rf Pods Podfile.lock && pod install`

---

## Notes

- Always use high-resolution source images (1024x1024 or higher)
- PNG format with transparency is recommended
- Background color can be customized in the configuration
- Test on multiple devices to ensure proper display
- For production apps, consider different icons for different platforms

---

Generated for DhobiGo App
