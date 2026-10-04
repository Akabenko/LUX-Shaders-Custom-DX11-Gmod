::===================== File of the LUX Shader Project =====================::
::  -   Initial D.	:	29.01.2026                                  ::
::  -	Last Change :	18.08.2026  ( Shader Model 5.0 / DX11 )             ::
::  -   Author      :   Unusuario2(https://github.com/Unusuario2)           ::
::==========================================================================::
@echo off
setlocal EnableDelayedExpansion

echo ===========================================================
echo ======= LUX Build Custom Shaders  --  SM5.0 (DX11) ========
echo ===========================================================

::Source is ALWAYS .\shaders relative to BAT
set "SrcDirBase=%~dp0"
cd /d "%SrcDirBase%"
set "shaderDir=%SrcDirBase%shaders\fxc"

set "targetdir=%SrcDirBase%..\shaders\fxc"

::The file that tells us what shaders to compile
set "inputbase=%SrcDirBase%compile_all_shaders"

::ShaderCompile: the RENDERER PORT's build. Its .vcs output is byte-identical to the set the port
::loads at runtime (verified).
set "SC=%SrcDirBase%devtools\ShaderCompile.exe"

if not exist "%targetdir%" mkdir "%targetdir%"

set "Command=/O 3 -ver 50 -force -threads %NUMBER_OF_PROCESSORS% -shaderpath %shaderDir%"
set "FailCount=0"
echo [Building .fxc files and worklist for %inputbase%.txt]
echo Command: %Command%
echo.

for /f "usebackq delims=" %%F in ("%inputbase%.txt") do (
    set "FileName=%%F"

    ::Skip empty lines and lines starting with //
    if not "!FileName!"=="" if "!FileName:~0,2!" NEQ "//" (
        "%SC%" /O 3 -ver 50 -force -threads %NUMBER_OF_PROCESSORS% -shaderpath "%shaderDir%" "!FileName!"
        if errorlevel 1 (
            set /a FailCount+=1
            echo [FAILED] !FileName!
        )
        echo.
    )
)

::Copy the shader stuff to the addon's shaders\fxc
if not "!FailCount!"=="0" (
    echo.
    echo ==========================================================
    echo  !FailCount! shader^(s^) FAILED to compile. NOT deploying.
    echo  The .vcs already in the addon are left untouched -- fix
    echo  the errors above and re-run, otherwise you would ship the
    echo  previous build and debug stale bytecode.
    echo ==========================================================
    pause
    exit /b 1
)

set "SrcCompiledShaderPath=%shaderDir%\shaders\fxc"
echo [Copy %SrcCompiledShaderPath% folder to %targetdir%]
xcopy "%SrcCompiledShaderPath%"  "%targetdir%" /E /I /Y

::Delete the intermediate shaders/fxc/shaders/fxc folder and the generated .inc folder
echo [Deleting %SrcCompiledShaderPath% folder]
rmdir /s /q "%SrcCompiledShaderPath%"
rmdir /q "%shaderDir%\shaders" 2>nul
set "IncPath=%shaderDir%\include"
rmdir /s /q "%IncPath%"

:end
endlocal

pause
