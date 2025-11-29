# 🚀 Quick Start - APK Testing

## ⚡ Fastest Way to Test

```powershell
.\test_apk.ps1
```

Ye automatically:
1. ✅ APK build karega
2. ✅ Phone me install karega  
3. ✅ App launch karega
4. ✅ Live logs show karega

## 📋 What was Fixed?

### Problem
- App phone me crash ho raha tha
- Error: "MainActivity not found"

### Solution
- ✅ MainActivity correct package me move kiya
- ✅ Comprehensive logging add kiya
- ✅ Error handling improve kiya
- ✅ Debug scripts create kiye

## 🔍 Check Current Status

Pehle ye command run karo to check if app is working:

```powershell
# Device connected hai?
adb devices

# Phone connected dikhna chahiye
```

## 📱 Test Karne ke Steps

### Step 1: Phone Connect Karo
- USB cable se phone connect karo
- USB Debugging enable karo
- File Transfer mode select karo

### Step 2: Build aur Install Karo
```powershell
.\test_apk.ps1
```

### Step 3: Logs Monitor Karo
Agar app crash ho rahi hai to logs me 🔴 red errors dikhenge

## 🎯 Different Options

```powershell
# Sirf build karo (install nahi)
.\test_apk.ps1 -BuildOnly

# Sirf install karo (build nahi)
.\test_apk.ps1 -InstallOnly

# Sirf logs dekho
.\test_apk.ps1 -LogsOnly
```

## 🔴 Agar Ab Bhi Crash Ho Raha Hai?

1. **Logs save karo**:
```powershell
adb logcat -d > crash_logs.txt
```

2. **Error dhundho**:
```powershell
adb logcat -d | Select-String "ERROR|FATAL|Exception"
```

3. **App clear karke retry karo**:
```powershell
adb shell pm clear com.example.dhobigo_app
.\test_apk.ps1 -InstallOnly
```

## 📊 Log Samajhna

| Symbol | Meaning |
|--------|---------|
| ✅ | Success - Sab theek hai |
| 🔴 | Error - Yahan problem hai |
| 🔄 | Loading - Process chal raha hai |
| 🔍 | Info - General information |
| ➡️ | Navigation - Screen change |

## 💡 Tips

- **Local me chal raha hai?** `flutter run` se check karo
- **APK size dekho**: build/app/outputs/flutter-apk/app-debug.apk
- **Screenshot lena hai?**: `adb exec-out screencap -p > screenshot.png`

---

**For detailed debugging**: Check `DEBUG_GUIDE.md`
