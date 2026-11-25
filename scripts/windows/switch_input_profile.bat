@echo off
setlocal
title Alternar Perfil de Entrada - NFS Most Wanted Hanami

echo ==============================================================================
echo  Alternar Perfil de Entrada (Controle 8BitDo/Xbox vs Volante Logitech G920)
echo ==============================================================================
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0switch_input_profile.ps1" -Mode status
echo.
echo  [1] Modo Controle (8BitDo / Xbox - XInput)
echo  [2] Modo Volante (Logitech G920 - DirectInput)
echo  [0] Sair sem alterar
echo.
set /p choice="Escolha uma opcao (1, 2 ou 0): "

if "%choice%"=="1" (
    powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0switch_input_profile.ps1" -Mode gamepad
) else if "%choice%"=="2" (
    powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0switch_input_profile.ps1" -Mode wheel
) else (
    echo Nenhuma alteracao realizada.
)

echo.
pause
