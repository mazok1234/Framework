@echo off
chcp 65001 >nul
title Framework - Test de compilation

echo ============================================
echo   Framework - Test de compilation et JAR
echo ============================================
echo.

REM === ETAPE 1: Nettoyage du build ===
echo [1/4] Nettoyage du repertoire build...
if exist "build" (
    rmdir /s /q "build"
)
mkdir build
echo      OK
echo.

REM === ETAPE 2: Compilation des sources ===
echo [2/4] Compilation des sources Java...
dir /s /b "src\*.java" > sources.txt
javac -cp "lib\*" -d "build" @sources.txt 2> build_errors.txt

if %ERRORLEVEL% NEQ 0 (
    echo      ERREUR de compilation !
    echo.
    echo      --- Erreurs ---
    type build_errors.txt
    echo.
    echo      --- Fin des erreurs ---
    del sources.txt 2>nul
    del build_errors.txt 2>nul
    pause
    exit /b 1
)
del sources.txt
del build_errors.txt 2>nul
echo      Compilation reussie !
echo.

REM === ETAPE 3: Copie des librairies ===
echo [3/4] Copie des librairies...
if not exist "build\lib" mkdir "build\lib"
xcopy "lib\*" "build\lib\" /E /Y >nul
echo      OK
echo.

REM === ETAPE 4: Creation du JAR ===
echo [4/4] Creation du fichier JAR...
cd /d "build"
jar -cvf framework.jar * >nul
cd ..
echo      JAR cree : build\framework.jar
echo.

echo ============================================
echo   RESULTAT : SUCCES
echo ============================================
echo.
echo Fichiers compiles :
dir /s /b "build\*.class" 2>nul
echo.
echo Librairies incluses :
dir /b "lib\*.jar"
echo.
echo JAR genere :
dir "build\framework.jar"
echo.

pause