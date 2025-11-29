# Live Log Monitor for Laundry App
# Ye script sirf app ke logs monitor karega

Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "  📊 Live Log Monitor" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Monitoring logs for: com.example.dhobigo_app" -ForegroundColor Yellow
Write-Host "Press Ctrl+C to stop" -ForegroundColor Yellow
Write-Host ""

# Clear previous logs
adb logcat -c

# Monitor with filters and color coding
adb logcat -s flutter:V dhobigo:V DartVM:V AndroidRuntime:E | ForEach-Object {
    $line = $_
    
    # Error logs - Red
    if ($line -match "ERROR|Exception|FATAL|Error|🔴|❌") {
        Write-Host $line -ForegroundColor Red
    }
    # Warning logs - Yellow
    elseif ($line -match "WARNING|WARN|⚠️") {
        Write-Host $line -ForegroundColor Yellow
    }
    # Success logs - Green
    elseif ($line -match "✅|SUCCESS|successfully|initialized") {
        Write-Host $line -ForegroundColor Green
    }
    # Loading/Process logs - Cyan
    elseif ($line -match "🔄|Loading|Initializing|Starting") {
        Write-Host $line -ForegroundColor Cyan
    }
    # Info logs - Blue
    elseif ($line -match "🔍|INFO|User|Auth|Storage") {
        Write-Host $line -ForegroundColor Blue
    }
    # Navigation logs - Magenta
    elseif ($line -match "➡️|Navigation|Navigating|Screen") {
        Write-Host $line -ForegroundColor Magenta
    }
    # Default - White
    else {
        Write-Host $line
    }
}
