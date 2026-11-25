@echo off
setlocal
title Configurar NFS Most Wanted Hanami para Windows

echo ==============================================================================
echo  Configurando Need for Speed: Most Wanted - Project Hanami v3.0
echo ==============================================================================

powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0setup_windows.ps1"

echo.
echo Pressione qualquer tecla para fechar esta janela...
pause >nul
