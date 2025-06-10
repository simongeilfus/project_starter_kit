@echo off

REM Save the current folder path
set CURRENT_PATH=%cd%

REM Add the current folder and rive build folder to the PATH
set PATH=%CURRENT_PATH%;%CURRENT_PATH%\..\..\third_party\rive-runtime\build;%PATH%

REM Navigate to the Premake renderer directory
cd /D ..\..\third_party\rive-runtime\renderer

REM build dependencies
pushd ..\skia\dependencies
call sh make_glfw.sh
popd

REM Make sure MSbuild is available
if exist "C:\Program Files\Microsoft Visual Studio\2022\Enterprise\Common7\Tools\VsDevCmd.bat" (
    CALL "C:\Program Files\Microsoft Visual Studio\2022\Enterprise\Common7\Tools\VsDevCmd.bat"
) else (
    if exist "C:\Program Files\Microsoft Visual Studio\2022\Community\Common7\Tools\VsDevCmd.bat" ( 
        CALL "C:\Program Files\Microsoft Visual Studio\2022\Community\Common7\Tools\VsDevCmd.bat"
    ) else echo "Visual Studio 2022 does not appear to be installed, please install visual studio to C:\Program Files\Microsoft Visual Studio"
)

REM Force the use of C++20 and disable some warnings that are treated as errors
set _CL_=/std:c++20 /wd4996 /wd4711 /wd4706 /Zi /Gm- /FUNCTIONPADMIN

REM Build release version of the rive library
call sh build_rive.sh release --toolset=msc --arch=x64 --with_rive_text --with_rive_layout --with_rive_tools

REM Same as above but force /MTd as the debug build doesn't build a debug lib by default
set _CL_=/std:c++20 /wd4996 /wd4711 /wd4706 /MTd /Zi /Gm- /FUNCTIONPADMIN /DEBUG:FULL

REM Build debug version of the rive library
call sh build_rive.sh debug --toolset=msc --arch=x64 --with_rive_text --with_rive_layout --with_rive_tools