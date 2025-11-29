# 🔧 APK Debug Guide

## Problem History
**Issue**: App crash ho raha tha phone me APK install karne ke baad
**Error**: `ClassNotFoundException: MainActivity`
**Root Cause**: MainActivity wrong package path me thi (`com.example.laundry_app` instead of `com.example.dhobigo_app`)

## ✅ Solution Applied
1. ✅ Correct package structure create kiya
2. ✅ MainActivity.kt file correct location pe move kiya
3. ✅ Comprehensive logging add kiya
4. ✅ Error handling improve kiya
5. ✅ Debug scripts create kiye

## 🛠️ Debug Tools

### 1️⃣ Full Build & Test (Recommended)
```powershell
.\test_apk.ps1
```
Ye script automatically:
- APK build karega
- Phone me install karega
- Live logs monitor karega

### 2️⃣ Only Build APK
```powershell
.\test_apk.ps1 -BuildOnly
```

### 3️⃣ Only Install (if APK already built)
```powershell
.\test_apk.ps1 -InstallOnly
```

### 4️⃣ Only Monitor Logs
```powershell
.\test_apk.ps1 -LogsOnly
# OR
.\monitor_logs.ps1
```

### 5️⃣ Complete Debug Flow
```powershell
.\debug_apk.ps1
```
Full process with clean build

## 📊 Log Color Coding

| Color | Type | Example |
|-------|------|---------|
| 🔴 Red | Errors | Exceptions, FATAL errors |
| 🟡 Yellow | Warnings | Deprecation warnings |
| 🟢 Green | Success | "✅ initialized successfully" |
| 🔵 Blue | Info | User data, Auth status |
| 🟣 Magenta | Navigation | Screen changes |
| 🔷 Cyan | Loading | Initialization processes |

## 🔍 Step-by-Step Debugging

### Check 1: Device Connection
```powershell
adb devices
```
Device dikhna chahiye with "device" status

### Check 2: App Installation
```powershell
adb shell pm list packages | Select-String "dhobigo"
```
App installed hona chahiye

### Check 3: Start App Manually
```powershell
adb shell am start -n com.example.dhobigo_app/.MainActivity
```

### Check 4: Real-time Logs
```powershell
adb logcat -c  # Clear logs
adb logcat -s flutter:V dhobigo:V AndroidRuntime:E
```

### Check 5: Check Crash Logs
```powershell
adb logcat -d | Select-String "FATAL|AndroidRuntime"
```

### Check 6: Check App Process
```powershell
adb shell ps | Select-String "dhobigo"
```
App running hona chahiye

## 🐛 Common Issues & Solutions

### Issue 1: "MainActivity not found"
**Solution**: Already fixed! MainActivity ab correct package me hai
```
Location: android/app/src/main/kotlin/com/example/dhobigo_app/MainActivity.kt
Package: com.example.dhobigo_app
```

### Issue 2: "Installation failed"
**Solution**: 
```powershell
adb uninstall com.example.dhobigo_app
.\test_apk.ps1 -InstallOnly
```

### Issue 3: App opens then crashes immediately
**Check logs**:
```powershell
.\monitor_logs.ps1
```
Look for 🔴 red error messages

### Issue 4: Build errors
**Clean and rebuild**:
```powershell
flutter clean
flutter pub get
flutter build apk --debug
```

## 📱 Testing on Phone

### Before Installing:
1. ✅ Enable USB Debugging in Developer Options
2. ✅ Connect phone via USB
3. ✅ Allow USB debugging prompt on phone
4. ✅ File Transfer mode (not charging only)

### After Installing:
1. Check app icon appears
2. Open app from launcher
3. If crash, run `.\monitor_logs.ps1` immediately
4. Check logs for 🔴 errors

## 🔐 Important Files Changed

1. **lib/main.dart**
   - Added error handling
   - Added comprehensive logging
   - Added error widget builder

2. **lib/services/storage_service.dart**
   - Added try-catch blocks
   - Added debug logging
   - Better error messages

3. **android/app/src/main/kotlin/com/example/dhobigo_app/MainActivity.kt**
   - Created in correct package location
   - Fixed package name mismatch

## 📝 Logging Format

App ab detailed logs print karega:
```
✅ App starting...
✅ Flutter binding initialized
🔄 Initializing storage...
✅ Storage initialized
🚀 Running app...
📱 Building MyApp...
🔄 Creating AuthProvider...
🔍 Auth Status - isLoggedIn: false
➡️ Navigating to LoginScreen
```

## 🎯 Next Steps

If app still crashes:
1. Run `.\test_apk.ps1` 
2. Note the exact error message (🔴 red)
3. Check which screen/service is failing
4. Check logs for stack trace

## 🔗 Useful Commands

```powershell
# Force stop app
adb shell am force-stop com.example.dhobigo_app

# Clear app data
adb shell pm clear com.example.dhobigo_app

# Check app info
adb shell dumpsys package com.example.dhobigo_app

# Screenshot (if crash visible)
adb exec-out screencap -p > crash_screenshot.png

# Pull logs to file
adb logcat -d > app_logs.txt
```

---

**Happy Debugging! 🐛🔍**
