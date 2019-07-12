@echo off
if [%1]==[] goto error
if exist %1\%1.obj del %1\%1.obj
if exist %1\%1.map del %1\%1.map
if exist %1\%1.exe del %1\%1.exe
if [%2]==[s] goto silent
if [%3]==[s] goto silent
tasm %1\%1.asm, %1\%1.obj
tlink %1\%1.obj, %1\%1.exe
goto endSilent
:silent
tasm %1\%1.asm, %1\%1.obj >nul
tlink %1\%1.obj, %1\%1.exe >nul
:endSilent
if [%2]==[c] goto eof
if [%3]==[c] goto eof
%1\%1.exe
goto eof

:error
echo Syntax: %0 source [s/c] [s/c]
echo s - silent		c - compile but don't launch
goto eof

:eof
