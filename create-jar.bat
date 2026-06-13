@echo off

set APP_NAME=framework
set BUILD_DIR=build
set LIB_DIR=lib

if not exist "%BUILD_DIR%" mkdir "%BUILD_DIR%"

dir /s /b *.java > sources.txt

javac -cp "%LIB_DIR%\*" -d "%BUILD_DIR%" @sources.txt

del sources.txt

if not exist "%BUILD_DIR%\lib" mkdir "%BUILD_DIR%\lib"
xcopy "%LIB_DIR%\*" "%BUILD_DIR%\lib\" /E /Y

cd /d "%BUILD_DIR%"
jar -cvf %APP_NAME%.jar *

echo.
echo JAR cree.
echo.
pause