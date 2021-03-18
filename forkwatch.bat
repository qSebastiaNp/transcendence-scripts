@ECHO OFF
REM forkwatch.bat v1.0.4 - qSebastiaNp
SETLOCAL EnableExtensions EnableDelayedExpansion

REM config
REM use hash of (blockheight - $SAFEMARGIN) to rule out orphan hashes
SET SAFEMARGIN=50
SET TRANSCENDENCE=transcendence-cli.exe
SET IFTTTKEY=none

REM no need to change anything from here --->

REM check if transcendence-cli file exists
IF NOT EXIST %TRANSCENDENCE% (
	ECHO * Could not find %TRANSCENDENCE%. Please check the configuration at the top of this script.
	PAUSE
	EXIT /b 1
)

REM check if wallet is running
tasklist /FI "IMAGENAME eq transcendence-qt.exe" 2>NUL | find /I /N "transcendence-qt.exe">NUL
IF NOT "%ERRORLEVEL%" == "0" (
	tasklist /FI "IMAGENAME eq transcendenced.exe" 2>NUL | find /I /N "transcendenced.exe">NUL
	IF NOT "%ERRORLEVEL%" == "0" (
		ECHO * transcendenced is not running. Please start it. Exiting...
		PAUSE
		EXIT /b 1
	)
)

FOR /F "Delims=" %%A IN ('"CALL curl -s https://explorer.teloscoin.org/ext/getmasternodecount"') DO SET "MNCOUNT=%%~A"
FOR /F "Delims=" %%B IN ('"CALL %TRANSCENDENCE% masternode count"') DO SET "LOCALMNCOUNT=!LOCALMNCOUNT!%%B"
SET LOCALMNCOUNT=%LOCALMNCOUNT:"=%
SET "LOCALMNCOUNT=%LOCALMNCOUNT:~2,-2%"
SET "LOCALMNCOUNT=%LOCALMNCOUNT:: ==%"
SET "%LOCALMNCOUNT:, =" & SET "%"
SET LOCALMNCOUNT=%stable%

REM check if explorer knows enough masternodes, ELSE it may be forked
SET /A "x=%LOCALMNCOUNT% / 2"
IF %MNCOUNT% LSS %x% (
	ECHO "* Explorer reports %MNCOUNT% MNs, which is much lower than your %LOCALMNCOUNT%. It may have forked. Exiting..."
	PAUSE
	EXIT /b 1
)

REM output blockhash overview
FOR /F "Delims=" %%C IN ('"CALL curl -s https://explorer.teloscoin.org/api/getblockcount"') DO SET "BLOCKHEIGHT=%%~C"
SET /A "SAFEBLOCKHEIGHT=%BLOCKHEIGHT% - %SAFEMARGIN%"

FOR /F "Delims=" %%D IN ('"CALL %TRANSCENDENCE% getblockhash %SAFEBLOCKHEIGHT%"') DO SET "LOCALHASH=%%~D"
ECHO Local   : %LOCALHASH%

@ping -n 2 localhost> nul
FOR /F "Delims=" %%E IN ('"CALL curl -s https://explorer.teloscoin.org/api/getblockhash?index=%SAFEBLOCKHEIGHT%"') DO SET "EXPLORERHASH=%%~E"
ECHO Explorer: %EXPLORERHASH%

FOR /F "Delims=" %%F IN ('"CALL curl -s https://telos.polispay.com/api/block-index/%SAFEBLOCKHEIGHT%"') DO SET "POLISHASH=%%~F"
SET "POLISHASH=%POLISHASH:~14,64%"

ECHO PolisPay: %POLISHASH%
ECHO.

REM output blockheight information
FOR /F "Delims=" %%G IN ('"%TRANSCENDENCE% getblockcount"') DO SET "LOCALBLOCKHEIGHT=%%~G"
IF %LOCALBLOCKHEIGHT% GTR %BLOCKHEIGHT% (
	SET /A "INFRONT=%LOCALBLOCKHEIGHT% - %BLOCKHEIGHT%"
	ECHO * You are !INFRONT! blocks in front of the explorer.
) ELSE (
	IF %LOCALBLOCKHEIGHT% == %BLOCKHEIGHT% (
		ECHO * You are at the same blockheight as the explorer.
	) ELSE (
		SET /A "LAGGING=%BLOCKHEIGHT% - %LOCALBLOCKHEIGHT%"
		ECHO * You are lagging !LAGGING! blocks behind the explorer.
	)
)

REM compare the blockhash with explorer
IF "%EXPLORERHASH%" == "%LOCALHASH%" (
	ECHO * Your blockhash for block %SAFEBLOCKHEIGHT% equals explorer's.

	REM check if polis and explorer have consensus
	IF "%EXPLORERHASH%" == "%POLISHASH%" (
		ECHO * Explorer and PolisPay have consensus.
		ECHO * You are NOT FORKED. Everything is fine. Exiting...
	) ELSE (
		ECHO * Explorer and PolisPay don't have consensus. Network is agitated.
		ECHO * You SHOULD be NOT FORKED. Maybe run the test again in a few minutes. Not immediately.
	)
	PAUSE
	EXIT /b 0
) ELSE (
	ECHO Your blockhash for block %SAFEBLOCKHEIGHT% differs from explorer's.
	ECHO It seems YOU ARE FORKED. Exiting...

	REM send push notification - read README.MD
	IF NOT "%IFTTTKEY%" == "none" (
		FOR /F "Delims=" %%G IN ('"hostname"') DO SET "HOSTNAME=%%~G"
		CALL curl -X POST -H "Content-Type: application/json" -d "{\"value1\":\"It seems %HOSTNAME% is FORKED.\"}" https://maker.ifttt.com/trigger/notify/with/key/%IFTTTKEY% >NUL
	)
	PAUSE
	EXIT /b 1
)
