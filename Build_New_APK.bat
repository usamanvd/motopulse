@echo off
echo ========================================================
echo   Building Ride Khaata Android Release APK...
echo ========================================================
echo.

set JAVA_HOME=C:\Program Files\Microsoft\jdk-17.0.20.101-hotspot
set PATH=%JAVA_HOME%\bin;%PATH%

call flutter build apk --release

if exist "build\app\outputs\flutter-apk\app-release.apk" (
    if not exist "app" mkdir app
    copy /Y "build\app\outputs\flutter-apk\app-release.apk" "app\ride_khaata.apk"
    copy /Y "build\app\outputs\flutter-apk\app-release.apk" "app\app-release.apk"
    echo.
    echo ========================================================
    echo   SUCCESS! Release APK generated at:
    echo   app\ride_khaata.apk
    echo ========================================================
) else (
    echo.
    echo [ERROR] Build failed. Please inspect the log output above.
)

echo.
pause
