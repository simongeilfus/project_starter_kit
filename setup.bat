@rem MIT License

@rem Copyright (c) 2022 Simon Geilfus

@rem Permission is hereby granted, free of charge, to any person obtaining a copy
@rem of this software and associated documentation files (the "Software"), to deal
@rem in the Software without restriction, including without limitation the rights
@rem to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
@rem copies of the Software, and to permit persons to whom the Software is
@rem furnished to do so, subject to the following conditions:

@rem The above copyright notice and this permission notice shall be included in all
@rem copies or substantial portions of the Software.

@rem THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
@rem IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
@rem FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
@rem AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
@rem LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
@rem OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
@rem SOFTWARE.

@rem ---------------------------------------------------------------------------
@rem GENERATES GIT COMMANDS TO SETUP PROJECT WITH REPOSITORIES AND/OR SUBMODULES
@rem ---------------------------------------------------------------------------

@echo off
setlocal EnableDelayedExpansion

echo project_starter_kit/script.bat

@rem parse arguments
@rem -----------------------------------
set argc=0
for %%x in (%*) do (
   set /A argc+=1
   set "argv[!argc!]=%%~x"
)

@rem no argument message
@rem -----------------------------------
if %argc% lss 1 goto print_help

@rem build commands
@rem -----------------------------------
set commandc=0
set git_mode=submodule add
for /L %%l in (1,1,%argc%) do (
    if !argv[%%l]! == clone (
        @rem change mode to clone
        set "git_mode=clone"
    ) else (
        if !argv[%%l]! == submodule (
            @rem change mode to submodule
            set "git_mode=submodule add"
        ) else (
            @rem check if this match the name of a library to setup
            for /F "tokens=1,2,3" %%i in (third_party.txt) do (
                @rem if there's a match add the command to the list
                if !argv[%%l]! == %%i (
                    set /A commandc+=1
                    set "commandv[!commandc!]=git !git_mode! %%j %%k third_party/%%i"
                )
            )
        )
    )
)

@rem no commands build warning message
@rem -----------------------------------
if %commandc% lss 1 (
    echo:
    echo   Error: No commands were build
    goto print_help
) else (
    @rem otherwise add default ending commands
    set /A commandc+=1
    set "commandv[!commandc!]=git submodule update --init --recursive"
)

@rem print commands
@rem -----------------------------------
echo This script will generate the following commands:
echo:
for /L %%i in (1,1,%commandc%) do echo      !commandv[%%i]!

@rem confirm message
@rem -----------------------------------
echo:
choice /C YN /M "Do you want to execute those commands? "
echo:
goto option-%errorlevel%

:option-1
@rem execute commands
@rem -----------------------------------
for /L %%i in (1,1,%commandc%) do !commandv[%%i]!

goto end
:print_help
echo:
echo   usage: setup [mode] lib0 lib1 [mode] lib2 lib3
echo   mode defaults to "submodule" but can be set to "clone" or "submodule" in any order
echo   available third party libraries:
for /F "tokens=1,2,3" %%i in (third_party.txt) do echo       %%i 

@rem cleanup
@rem -----------------------------------
:option-2
:end
set argc=
set argv=
set commandc=
set commandv=