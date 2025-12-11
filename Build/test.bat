@echo off
chcp 65001 >nul
REM ============================================================================
REM  Test Script (NUnit)
REM ============================================================================

echo.
echo ============================================
echo   Building and Running NUnit Tests
echo ============================================
echo.

REM Move to the root directory
pushd %~dp0..

REM Set MSBuild path
set MSBuild="C:\Program Files\Microsoft Visual Studio\2022\Professional\MSBuild\Current\Bin\MSBuild.exe"
set VSTest="C:\Program Files\Microsoft Visual Studio\2022\Professional\Common7\IDE\CommonExtensions\Microsoft\TestWindow\vstest.console.exe"

REM Build test project (MSBuild will auto-build Calculator via ProjectReference)
echo -Building test project...
%MSBuild% "ClassLib\test\TestCalculator.csproj" /t:Rebuild /p:Configuration=Debug /p:Platform=AnyCPU /restore /nodeReuse:False

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
echo   Running Tests
echo ============================================
echo.

REM Run tests using vstest.console.exe
%VSTest% "ClassLib\test\bin\Debug\TestCalculator.dll" /Logger:trx;LogFileName=TestResults.trx

if %ERRORLEVEL% neq 0 (
    echo.
    echo ============================================
    echo   Some Tests FAILED!
    echo ============================================
    popd
    exit /b 1
)

echo.
echo ============================================
echo   All Tests PASSED!
echo ============================================

popd
exit /b 0
