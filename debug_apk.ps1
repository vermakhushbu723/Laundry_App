# Debug APK Build and Monitor Script
# Ye script APK build karega, install karega aur live logs dikhayega

Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "  🔧 Debug APK Builder & Monitor" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""

# Step 1: Clean previous build
Write-Host "🧹 Cleaning previous build..." -ForegroundColor Yellow
flutter clean
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Clean failed!" -ForegroundColor Red
    exit 1
}
Write-Host "✅ Clean successful" -ForegroundColor Green
Write-Host ""

# Step 2: Get dependencies
Write-Host "📦 Getting dependencies..." -ForegroundColor Yellow
flutter pub get
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Pub get failed!" -ForegroundColor Red
    exit 1
}
Write-Host "✅ Dependencies fetched" -ForegroundColor Green
Write-Host ""

# Step 3: Build debug APK
Write-Host "🔨 Building debug APK..." -ForegroundColor Yellow
flutter build apk --debug
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Build failed!" -ForegroundColor Red
    exit 1
}
Write-Host "✅ Build successful" -ForegroundColor Green
Write-Host ""

# Step 4: Check device connection
Write-Host "📱 Checking device connection..." -ForegroundColor Yellow
$devices = adb devices | Select-String -Pattern "device$"
if ($devices.Count -eq 0) {
    Write-Host "❌ No device connected!" -ForegroundColor Red
    Write-Host "Please connect your device and enable USB debugging" -ForegroundColor Yellow
    exit 1
}
Write-Host "✅ Device connected" -ForegroundColor Green
Write-Host ""

# Step 5: Uninstall old version
Write-Host "🗑️  Uninstalling old version..." -ForegroundColor Yellow
adb uninstall com.example.dhobigo_app 2>$null
Write-Host "✅ Old version removed" -ForegroundColor Green
Write-Host ""

# Step 6: Install new APK
Write-Host "📲 Installing new APK..." -ForegroundColor Yellow
adb install build\app\outputs\flutter-apk\app-debug.apk
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Installation failed!" -ForegroundColor Red
    exit 1
}
Write-Host "✅ APK installed successfully" -ForegroundColor Green
Write-Host ""

# Step 7: Clear logs and start app
Write-Host "🚀 Starting app and monitoring logs..." -ForegroundColor Yellow
adb logcat -c
adb shell am start -n com.example.dhobigo_app/.MainActivity

Write-Host ""
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "  📊 LIVE LOGS (Press Ctrl+C to stop)" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""

# Step 8: Monitor logs with color coding
adb logcat | ForEach-Object {
    if ($_ -match "flutter" -or $_ -match "dhobigo" -or $_ -match "DartVM") {
        if ($_ -match "ERROR|Exception|FATAL|🔴") {
            Write-Host $_ -ForegroundColor Red
        }
        elseif ($_ -match "WARNING|⚠️") {
            Write-Host $_ -ForegroundColor Yellow
        }
        elseif ($_ -match "✅|SUCCESS") {
            Write-Host $_ -ForegroundColor Green
        }
        elseif ($_ -match "🔄|Loading") {
            Write-Host $_ -ForegroundColor Cyan
        }
        else {
            Write-Host $_
        }
    }
}
