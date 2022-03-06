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

@rem setup source and destination
set source_url=https://www.python.org/ftp/python/3.10.2/python-3.10.2-amd64.exe
set destination=%temp%\python-3.10.2-amd64.exe
@rem start download
powershell -Command "Invoke-WebRequest %source_url% -OutFile %destination%"
@rem execute installer
start /w %destination%
@rem cleanup
del %destination%
set source=
set destination=