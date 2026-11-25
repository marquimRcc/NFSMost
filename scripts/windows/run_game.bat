@echo off
setlocal enabledelayedexpansion
title Need for Speed: Most Wanted - Hanami v3.0

:: Define possiveis diretorios do jogo
set "GAME_DIR="
if exist "%~dp0..\..\..\NFS_Most_Wanted_Hanami\speed.exe" (
    pushd "%~dp0..\..\..\NFS_Most_Wanted_Hanami"
    set "GAME_DIR=!CD!"
    popd
) else if exist "%~dp0..\..\speed.exe" (
    pushd "%~dp0..\.."
    set "GAME_DIR=!CD!"
    popd
) else if exist "%~dp0..\speed.exe" (
    pushd "%~dp0.."
    set "GAME_DIR=!CD!"
    popd
) else if exist "%CD%\speed.exe" (
    set "GAME_DIR=%CD%"
) else if exist "D:\Jogos\Outros\NFSMost\NFS_Most_Wanted_Hanami\speed.exe" (
    set "GAME_DIR=D:\Jogos\Outros\NFSMost\NFS_Most_Wanted_Hanami"
)

if "%GAME_DIR%"=="" (
    echo [ERRO] Nao foi possivel localizar a pasta do jogo contendo speed.exe!
    echo Certifique-se de executar o script na pasta do jogo ou em D:\Jogos\Outros\NFSMost\NFS_Most_Wanted_Hanami.
    pause
    exit /b 1
)

cd /d "%GAME_DIR%"

:: Aplicar registro grafico essencial do usuario silenciosamente
reg add "HKCU\Software\Classes\VirtualStore\MACHINE\SOFTWARE\Wow6432Node\EA Games\Need for Speed Most Wanted" /v "g_WorldLodLevel" /t REG_DWORD /d 3 /f >nul 2>&1
reg add "HKCU\Software\Classes\VirtualStore\MACHINE\SOFTWARE\Wow6432Node\EA Games\Need for Speed Most Wanted" /v "g_VisualTreatment" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKCU\Software\Classes\VirtualStore\MACHINE\SOFTWARE\Wow6432Node\EA Games\Need for Speed Most Wanted" /v "g_RoadReflectionEnable" /t REG_DWORD /d 2 /f >nul 2>&1
reg add "HKCU\Software\Classes\VirtualStore\MACHINE\SOFTWARE\Wow6432Node\EA Games\Need for Speed Most Wanted" /v "g_ShadowDetail" /t REG_DWORD /d 2 /f >nul 2>&1
reg add "HKCU\Software\Classes\VirtualStore\MACHINE\SOFTWARE\Wow6432Node\EA Games\Need for Speed Most Wanted" /v "g_TextureFiltering" /t REG_DWORD /d 2 /f >nul 2>&1

echo ==============================================================================
echo  Iniciando NFS Most Wanted - Project Hanami v3.0 (Dublado PT-BR)
echo  Diretorio: %GAME_DIR%
echo ==============================================================================

start "" "%GAME_DIR%\speed.exe" %*
exit /b 0
