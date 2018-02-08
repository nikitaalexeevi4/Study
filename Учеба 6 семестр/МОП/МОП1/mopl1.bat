@echo off
mount c c:/tasm/

:start
tasm mopl1 /l
if errorlevel 1 goto mopl1e

tasm mopl1l
if errorlevel 1 goto mopl1le

tlink mopl1+mopl1l
if errorlevel 1 goto tle

td mopl1
goto exit	

:mopl1e
td mopl1.asm
pause
goto start

:mopl1le
td mopl1l.asm
pause
goto start

:tle
echo ошибка в tlink
goto exit

:exit
pause
exit