@echo off
chcp 65001 >nul
REM ============================================================================
REM  Build Script
REM ============================================================================

echo.
echo ============================================
echo   Building Calculator
echo ============================================
echo.

REM Move to the root directory
pushd %~dp0..

REM Set MSBuild path
set MSBuild="C:\Program Files\Microsoft Visual Studio\2022\Professional\MSBuild\Current\Bin\MSBuild.exe"

REM Build and Restore Calculator project only
echo -Building Calculator...
%MSBuild% "ClassLib\src\Calculator.csproj" /t:Rebuild /p:Configuration=Release /p:Platform=AnyCPU /restore /nodeReuse:False

if %ERRORLEVEL% neq 0 (
    echo.
    echo ============================================
    echo   Build FAILED!
    echo ============================================
    popd
    exit /b 1
)

echo.
echo ============================================
echo   Build Completed Successfully!
echo ============================================

popd
exit /b 0
