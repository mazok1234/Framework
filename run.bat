@echo off
chcp 65001 >nul
title Framework - Test de compilation et Deploiement

echo ============================================
echo   Framework - Test de compilation et Deploiement
echo ============================================
echo.

REM === ETAPE 1: Nettoyage du build ===
echo [1/6] Nettoyage du repertoire build...
if exist "build" (
    rmdir /s /q "build"
)
mkdir build
echo      OK
echo.

REM === ETAPE 2: Compilation des sources ===
echo [2/6] Compilation des sources Java...
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
echo [3/6] Copie des librairies...
if not exist "build\lib" mkdir "build\lib"
xcopy "lib\*" "build\lib\" /E /Y >nul
echo      OK
echo.

REM === ETAPE 4: Creation du JAR ===
echo [4/6] Creation du fichier JAR...
cd /d "build"
jar -cvf framework.jar * >nul
cd ..
echo      JAR cree : build\framework.jar
echo.

REM === ETAPE 5: Creation de l'application de test ===
echo [5/6] Creation de l'application de test...
if exist "build\testapp" rmdir /s /q "build\testapp"
mkdir "build\testapp\WEB-INF\lib"
mkdir "build\testapp\WEB-INF\classes\controller"
copy "build\framework.jar" "build\testapp\WEB-INF\lib\" >nul
xcopy "lib\*" "build\testapp\WEB-INF\lib\" /E /Y >nul

(
echo package controller;
echo.
echo import mg.itu.myframework.annotation.Controller;
echo import mg.itu.myframework.annotation.UrlMapping;
echo.
echo @Controller
echo public class TestController {
echo     @UrlMapping^(url="/hello"^)
echo     public void sayHello^(^) {
echo     }
echo }
) > "build\TestController.java"

javac -cp "build\framework.jar;lib\*" -d "build\testapp\WEB-INF\classes" "build\TestController.java" 2>nul
del "build\TestController.java" 2>nul

(
echo ^<?xml version="1.0" encoding="UTF-8"?^>
echo ^<web-app xmlns="https://jakarta.ee/xml/ns/jakartaee"^>
echo     ^<servlet^>
echo         ^<servlet-name^>FrontController^</servlet-name^>
echo         ^<servlet-class^>mg.itu.myframework.controller.FrontControllerServlet^</servlet-class^>
echo     ^</servlet^>
echo     ^<servlet-mapping^>
echo         ^<servlet-name^>FrontController^</servlet-name^>
echo         ^<url-pattern^>/*^</url-pattern^>
echo     ^</servlet-mapping^>
echo ^</web-app^>
) > "build\testapp\WEB-INF\web.xml"

echo      Application de test creee dans build\testapp.
echo.

REM === ETAPE 6: Deploiement sur Tomcat et Lancement ===
echo [6/6] Deploiement sur Tomcat et lancement...
set "TOMCAT_WEBAPPS=C:\Tomcat10\apache-tomcat-10.1.24\webapps"
if exist "%TOMCAT_WEBAPPS%\testapp" rmdir /s /q "%TOMCAT_WEBAPPS%\testapp"
xcopy "build\testapp" "%TOMCAT_WEBAPPS%\testapp\" /E /I /Y >nul

echo      Demarrage de Tomcat...
call "C:\Tomcat10\apache-tomcat-10.1.24\bin\startup.bat"

echo      Ouverture du navigateur...
timeout /t 3 /nobreak >nul
start http://localhost:8080/testapp/hello
echo      Termine !
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
echo Test de l'application deployee sur : http://localhost:8080/testapp/hello
echo.

pause