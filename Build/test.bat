@echo off
chcp 65001 >nul
REM ============================================================================
REM  Test Script (NUnit)
REM ============================================================================

echo.
echo ============================================
echo   Building NUnit Tests
echo ============================================
echo.

REM Move to the root directory
pushd %~dp0..

REM Set MSBuild path
set MSBuild="C:\Program Files\Microsoft Visual Studio\2022\Professional\MSBuild\Current\Bin\MSBuild.exe"

REM Build and Restore test project only (MSBuild will auto-build Calculator via ProjectReference)
echo -Building TestCalculator with dependencies...
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
echo   Running NUnit Tests via vstest.console.exe
echo ============================================
echo.

REM Set NuGet package versions (align with TestCalculator.csproj versions)
set MicrosoftTestPlatformVer=17.14.1
set Nunit3TestAdapterVer=4.6.0
set JunitXmlTestLoggerVer=7.1.0
set ReportGeneratorVer=5.4.18

REM Set nuget packages tool paths (PackageReference uses global cache)
set PackagesDir=%userprofile%\.nuget\packages
set TestPlatformPath=%PackagesDir%\microsoft.testplatform\%MicrosoftTestPlatformVer%\tools\net462\Common7\IDE\Extensions\TestPlatform
set TestAdapterPath=%PackagesDir%\nunit3testadapter\%Nunit3TestAdapterVer%\build\net462
set JunitXmlTestLoggerPath=%PackagesDir%\junitxml.testlogger\%JunitXmlTestLoggerVer%\build\_common
set ReportGeneratorPath=%PackagesDir%\reportgenerator\%ReportGeneratorVer%\tools\net47

REM Set test result and test coverage directory
set TestResultsDir=%CD%\ClassLib\test\TestResults
if exist "%TestResultsDir%" (rmdir /S /Q "%TestResultsDir%")
mkdir "%TestResultsDir%"

REM Set test output directory
set TestOutputDir=%CD%\ClassLib\test\bin\Debug

REM Copy JunitXml.TestLogger to TestPlatform Extensions
if not exist "%TestPlatformPath%\Extensions\JunitXml.TestLogger.dll" (
    echo -Copying JunitXml.TestLogger to TestPlatform Extensions...
    xcopy "%JunitXmlTestLoggerPath%\*.dll" "%TestPlatformPath%\Extensions\" /E /Y /C /H >nul
)

REM Run tests (generate JUnit format test results for GitLab, Trx format test results for SonarQube, and collect Cobertura format code coverage for GitLab)
echo -Running tests with Code Coverage...
"%TestPlatformPath%\vstest.console.exe" "%TestOutputDir%\TestCalculator.dll" ^
    /InIsolation /Parallel ^
    /TestAdapterPath:"%TestAdapterPath%" ^
    /Logger:"junit;LogFileName=junit_test_results.xml;MethodFormat=Class;FailureBodyFormat=Verbose" ^
    /Logger:"trx;LogFileName=trx_test_results.trx" ^
    /Enablecodecoverage ^
    /Collect:"Code Coverage;Format=cobertura;UseVerifiableInstrumentation=False" ^
    /ResultsDirectory:"%TestResultsDir%"

set TEST_EXIT_CODE=%ERRORLEVEL%

REM Code coverage: Convert cobertura format to SonarQube Generic Format (using ReportGenerator)
echo -Converting code coverage to SonarQube format...
"%ReportGeneratorPath%\ReportGenerator.exe" ^
    "-reports:%TestResultsDir%\*-*-*-*-*\*.cobertura.xml" ^
    "-targetdir:%TestResultsDir%" ^
    "-reporttypes:SonarQube;TeamCitySummary" ^
    "-sourcedirs:%CD%" ^
    "-filefilters:+%CD%\**;-*nunit*" ^
    "-verbosity:Warning"
echo   Done.

if %TEST_EXIT_CODE% neq 0 (
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
