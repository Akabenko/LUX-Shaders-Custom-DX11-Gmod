::===================== File of the LUX Shader Project =====================::
::  -   Initial D.	:	29.01.2026                                          ::
::  -	Last Change :	29.01.2026                                          ::
::  -   Author      :   Unusuario2(https://github.com/Unusuario2)           ::              
::==========================================================================::
@echo off
setlocal EnableDelayedExpansion

echo ===========================================================
echo =============== LUX Build Custom Shaders ==================
echo ===========================================================

::Source is ALWAYS .\shaders relative to BAT
set "SrcDirBase=%~dp0"
cd /d "%SrcDirBase%"
set "shaderDir=%SrcDirBase%shaders\fxc"

::Game directory is ALWAYS ..\game
set "GAMEDIR=..\game"
set "targetdir=%GAMEDIR%\shaders\fxc"

::The file that tells us what shaders to compile
set "inputbase=%SrcDirBase%compile_all_shaders"

::Safety check: ..\game must NOT be a file
if exist "%GAMEDIR%" (
    if not exist "%GAMEDIR%\." (
        echo ERROR: "%GAMEDIR%" exists but is NOT a directory.
        echo Delete or rename that file and try again.
        goto end
    )
)

::Run shader processing
set "Command=-ver 50 -threads %NUMBER_OF_PROCESSORS% -shaderpath %shaderDir%"
echo [Building .fxc files and worklist for %inputbase%.txt]
echo Command: %Command%
echo.

for /f "usebackq delims=" %%F in ("%inputbase%.txt") do (
    set "FileName=%%F"

    ::Skip empty lines and lines starting with //
    if not "!FileName!"=="" if "!FileName:~0,2!" NEQ "//" (
        "%SrcDirBase%\devtools\ShaderCompile2" ^
            -ver 50 ^
            -threads %NUMBER_OF_PROCESSORS% ^
            -shaderpath "%shaderDir%" ^
            "!FileName!"
        echo.
    )
)

::Copy the shader stuff to the gamedir
set "SrcCompiledShaderPath=%shaderDir%\shaders\fxc"
echo [Copy %SrcCompiledShaderPath% folder to %targetdir%]
xcopy %SrcCompiledShaderPath%  %targetdir% /E /I /Y

::Delete .inc files and the shaders/fxc/shaders/fxc folder
echo [Deleting %SrcCompiledShaderPath% folder]
rmdir /s /q %SrcCompiledShaderPath%
set "IncPath=%shaderDir%\include"
rmdir /s /q %IncPath%

:end
endlocal
