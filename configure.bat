@REM project_starter_kit
@REM https://github.com/simongeilfus/project_starter_kit

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

@rem ----------------------------------------------------
@rem GENERATE A CMAKE COMMAND WITH OPTIONAL PARAMETERS
@rem ----------------------------------------------------

@echo off
setlocal EnableDelayedExpansion

set cmake_args=-UENABLE_LPP

@rem parsing arguments
@rem -----------------------------------
:parse_args
if "%~1" == "" goto end_parse_args
if "%~1" == "live++" set cmake_args=%cmake_args% -DENABLE_LPP=ON
if "%~1" == "liveplusplus" set cmake_args=%cmake_args% -DENABLE_LPP=ON
if "%~1" == "clean" set cmake_args=%cmake_args% --fresh
SHIFT
goto parse_args
:end_parse_args

@rem run cmake
@rem -----------------------------------
cmake -S . -B ./build -G "Visual Studio 17 2022" -A x64 !cmake_args!

@rem end
@rem -----------------------------------
:end
set cmake_args = 