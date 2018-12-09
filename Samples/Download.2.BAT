@ECHO OFF
SETLOCAL

::SET SCRIPT_CMD=CScript.EXE //NoLogo "..\Download-mota.ru-ImageHTRC.WSF"
SET SCRIPT_CMD=CScript.EXE //NoLogo "..\Download-mota.ru-ImageWHTC.WSF"

FOR /F %%A IN (Download.LST) DO %SCRIPT_CMD% "%%A"
