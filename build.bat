@echo off
setlocal enabledelayedexpansion

set "SCRIPT_DIR=%~dp0"

REM --- Read solution name from options.cmake: set(PROJECT <name>) ---
set "PROJECT="
for /f "tokens=3 delims=() " %%A in ('findstr /b /c:"set(PROJECT " "%SCRIPT_DIR%options.cmake"') do set "PROJECT=%%A"

if not defined PROJECT (
    echo ERROR: Could not parse PROJECT from options.cmake
    exit /b 1
)

set "SOLUTION=%SCRIPT_DIR%build\%PROJECT%.sln"

if not exist "%SOLUTION%" (
    echo ERROR: Solution not found: %SOLUTION%
    exit /b 1
)

REM --- Locate MSBuild via vswhere ---
set "MSBUILD="
set "VSWHERE=%ProgramFiles(x86)%\Microsoft Visual Studio\Installer\vswhere.exe"
if exist "%VSWHERE%" (
    for /f "usebackq tokens=*" %%I in (`"%VSWHERE%" -latest -requires Microsoft.Component.MSBuild -find MSBuild\**\Bin\MSBuild.exe`) do set "MSBUILD=%%I"
)

if not defined MSBUILD (
    echo ERROR: MSBuild.exe not found via vswhere
    exit /b 1
)

REM --- Parse args: Configuration (Debug/Release) + verbose flag (-v / --verbose) ---
set "CONFIG="
set "VERBOSE="
:parse_args
if "%~1"=="" goto args_done
if /i "%~1"=="-v" (
    set "VERBOSE=1"
) else if /i "%~1"=="--verbose" (
    set "VERBOSE=1"
) else (
    set "CONFIG=%~1"
)
shift
goto parse_args
:args_done

if not defined CONFIG set "CONFIG=Debug"

if defined VERBOSE (
    set "MSBUILD_FLAGS=-verbosity:normal -nologo"
) else (
    set "MSBUILD_FLAGS=-clp:ErrorsOnly -verbosity:quiet -nologo"
)

"%MSBUILD%" "%SOLUTION%" -p:Configuration=%CONFIG% %MSBUILD_FLAGS%
exit /b %ERRORLEVEL%
