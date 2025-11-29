# Quick Test Script
# APK ko phone me test karne ke liye

param(
    [switch]$BuildOnly,
    [switch]$InstallOnly,
    [switch]$LogsOnly
)

$AppPackage = "com.example.dhobigo_app"
$ApkPath = "build\app\outputs\flutter-apk\app-debug.apk"

function Write-Step {
    param($Message, $Color = "Cyan")
    Write-Host ""
    Write-Host "═══════════════════════════════════" -ForegroundColor $Color
    Write-Host " $Message" -ForegroundColor $Color
    Write-Host "═══════════════════════════════════" -ForegroundColor $Color
}

function Write-Success {
    param($Message)
    Write-Host "✅ $Message" -ForegroundColor Green
}

function Write-Error-Custom {
    param($Message)
    Write-Host "❌ $Message" -ForegroundColor Red
}

function Write-Info {
    param($Message)
    Write-Host "ℹ️  $Message" -ForegroundColor Yellow
}

# Check device
function Test-Device {
    Write-Step "Checking Device Connection"
    $devices = adb devices | Select-String -Pattern "device$"
    if ($devices.Count -eq 0) {
        Write-Error-Custom "No device connected!"
        Write-Info "Connect your phone via USB and enable USB debugging"
        return $false
    }
    Write-Success "Device connected"
    return $true
}

# Build APK
function Build-APK {
    Write-Step "Building Debug APK" "Yellow"
    flutter build apk --debug
    if ($LASTEXITCODE -eq 0) {
        Write-Success "APK built successfully"
        Write-Info "APK location: $ApkPath"
        return $true
    } else {
        Write-Error-Custom "Build failed!"
        return $false
    }
}

# Install APK
function Install-APK {
    if (-not (Test-Path $ApkPath)) {
        Write-Error-Custom "APK not found at: $ApkPath"
        Write-Info "Run build first: .\test_apk.ps1"
        return $false
    }

    Write-Step "Installing APK" "Yellow"
    
    # Uninstall old version
    Write-Info "Removing old version..."
    adb uninstall $AppPackage 2>$null
    
    # Install new version
    Write-Info "Installing new version..."
    adb install $ApkPath
    
    if ($LASTEXITCODE -eq 0) {
        Write-Success "APK installed successfully"
        return $true
    } else {
        Write-Error-Custom "Installation failed!"
        return $false
    }
}

# Start app and monitor
function Start-AppWithLogs {
    Write-Step "Starting App & Monitoring Logs" "Green"
    
    # Clear logs
    adb logcat -c
    
    # Start app
    Write-Info "Launching app..."
    adb shell am start -n $AppPackage/.MainActivity
    Start-Sleep -Seconds 2
    
    Write-Step "📊 LIVE LOGS (Ctrl+C to stop)" "Cyan"
    
    # Show logs
    adb logcat -s flutter:V dhobigo:V DartVM:V AndroidRuntime:E | ForEach-Object {
        if ($_ -match "ERROR|Exception|FATAL|🔴") {
            Write-Host $_ -ForegroundColor Red
        }
        elseif ($_ -match "✅|SUCCESS|successfully") {
            Write-Host $_ -ForegroundColor Green
        }
        elseif ($_ -match "🔄|Loading|Initializing") {
            Write-Host $_ -ForegroundColor Cyan
        }
        else {
            Write-Host $_
        }
    }
}

# Main execution
Write-Host ""
Write-Host "╔════════════════════════════════════╗" -ForegroundColor Magenta
Write-Host "║   🧪 APK Test & Debug Tool 🧪      ║" -ForegroundColor Magenta
Write-Host "╚════════════════════════════════════╝" -ForegroundColor Magenta

if (-not (Test-Device)) {
    exit 1
}

if ($LogsOnly) {
    Start-AppWithLogs
    exit 0
}

if ($InstallOnly) {
    if (Install-APK) {
        Start-AppWithLogs
    }
    exit 0
}

if ($BuildOnly) {
    Build-APK
    exit 0
}

# Full flow: Build -> Install -> Monitor
if (Build-APK) {
    if (Install-APK) {
        Start-AppWithLogs
    }
}
