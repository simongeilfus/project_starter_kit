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

@rem intro
@rem -----------------------------------
echo This script will generate the following commands:
echo:

set mode=print
set git_mode=submodule add

@rem parsing arguments
@rem -----------------------------------
:parse_args
if "%~1" == "" goto end_parse_args
if "%~1" == "clone" (
    set git_mode=clone
) 
if "%~1" == "submodule" (
    set git_mode=submodule add
) 
if "%~1" == "cinder" (
    echo     git !git_mode! https://github.com/cinder/Cinder.git --recursive third_party/cinder
    set cinder=!git_mode!
) 
if "%~1" == "glfw" (
    echo     git !git_mode! https://github.com/glfw/glfw.git third_party/glfw
    set glfw=!git_mode!
) 
if "%~1" == "imgui" (
    echo     git !git_mode! https://github.com/ocornut/ImGui.git third_party/imgui
    set imgui=!git_mode!
) 
if "%~1" == "json" (
    echo     git !git_mode! https://github.com/nlohmann/json.git third_party/json
    set json=!git_mode!
)
if "%~1" == "live++" (
    echo     git !git_mode! https://github.com/simongeilfus/liveplusplus.git third_party/liveplusplus
    set liveplusplus=!git_mode!
)
if "%~1" == "imgui_utils" (
    echo     git !git_mode! https://github.com/simongeilfus/imgui_utils.git third_party/imgui_utils
    set imgui_utils=!git_mode!
) 
shift
goto parse_args
:end_parse_args
echo:

@rem confirm message
@rem -----------------------------------
choice /C YC /M "Confirm with Y or cancel with C : "
echo:
goto option-%errorlevel%
:option-1

@rem execute
@rem -----------------------------------
if defined cinder git !cinder! https://github.com/cinder/Cinder.git --recursive third_party/cinder
if defined glfw git !glfw! https://github.com/glfw/glfw.git third_party/glfw
if defined imgui git !imgui! https://github.com/ocornut/ImGui.git third_party/imgui
if defined json git !json! https://github.com/nlohmann/json.git thid_party/json
if defined liveplusplus !liveplusplus! https://github.com/simongeilfus/liveplusplus.git third_party/liveplusplus
if defined imgui_utils git !imgui_utils! https://github.com/simongeilfus/imgui_utils.git third_party/imgui_utils

:option-2
goto end

@rem cleanup
@rem -----------------------------------
:cleanup
set mode=
set git_mode= 
set cinder=
set glfw=
set imgui=
set json=
set liveplusplus=

:end