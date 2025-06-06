@echo off

echo - Liberation_RX PBO build script -
del /f *.pbo  > nul 2>&1

set GRLIB_file="..\core.liberation\build_info.sqf"
echo // Liberation_RX build info:> %GRLIB_file%
echo GRLIB_build_date = "%DATE%";>> %GRLIB_file%
echo GRLIB_build_time = "%TIME:~0,8%";>> %GRLIB_file%
for /f "delims=" %%i in ('git describe --tags') do set GRLIB_version=%%i
echo GRLIB_build_version = "%GRLIB_version%";>> %GRLIB_file%

for /f %%i in ('dir /B /A:D ..\maps\liberation_RX*') do (
	echo.
	echo Building PBO for map %%i 
	xcopy /Q /E /Y ..\core.liberation .\%%i\
	xcopy /Q /E /Y ..\maps\%%i .\%%i\
	if exist .\custom\ xcopy /Q /E /Y .\custom .\%%i\
	bin\PBOConsole.exe -pack %%i .\%%i.pbo  > nul 2>&1
	rmdir /S /Q %%i
	echo Done.
)

pause