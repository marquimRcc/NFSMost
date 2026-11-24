#!/usr/bin/env bash
# ==============================================================================
# Need for Speed: Most Wanted (2005) - Project Hanami v3.0 (Dublado PT-BR)
# Script de Inicialização Otimizado para Linux (Wine / DXVK / AMD Radeon)
# ==============================================================================

set -e

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
if [ -f "$DIR/speed.exe" ]; then
    GAME_DIR="$DIR"
elif [ -f "$(pwd)/speed.exe" ]; then
    GAME_DIR="$(pwd)"
elif [ -d "$HOME/Games/NFS_Most_Wanted_Hanami" ]; then
    GAME_DIR="$HOME/Games/NFS_Most_Wanted_Hanami"
else
    echo "Erro: Diretório do jogo não encontrado. Execute este script a partir da pasta do jogo."
    exit 1
fi

cd "$GAME_DIR"

# 1. Configurar Prefixo do Wine
export WINEPREFIX="${WINEPREFIX:-$HOME/.wine}"
export WINEARCH="${WINEARCH:-win64}"

# 2. Desabilitar DLLs de proxy antigas (ex: x360ce) que conflitam com o Winebus/SDL
if [ -f "$GAME_DIR/xinput1_3.dll" ]; then
    echo "[INFO] Renomeando xinput1_3.dll para evitar conflito com controle..."
    mv -f "$GAME_DIR/xinput1_3.dll" "$GAME_DIR/xinput1_3.dll.bak"
fi

# 3. Overrides de DLLs essenciais:
# - dinput8: Ultimate ASI Loader (deve ser nativa 'n,b')
# - d3d9, dxgi, d3d11: DXVK Vulkan layer (nativos 'n,b')
# - d3dx9_36, d3dx9_43: Runtimes DirectX June 2010 oficiais da Microsoft ('n,b')
# - d3dcompiler_43, d3dcompiler_47: Compiladores HLSL nativos da Microsoft ('n,b')
# - xinput1_3, xinput1_4, xinput9_1_0: Built-in do Wine ('b') para SDL2/evdev
# - winemenubuilder, winedbg: Desabilitados ('d') para evitar travamentos de tela cheia
export WINEDLLOVERRIDES="dinput8=n,b;d3d9=n,b;dxgi=n,b;d3d11=n,b;d3dx9_36=n,b;d3dx9_43=n,b;d3dcompiler_43=n,b;d3dcompiler_47=n,b;xinput1_3=b;xinput1_4=b;xinput9_1_0=b;winemenubuilder=d;winedbg.exe=d;winedbg=d"

# 4. Suporte a Controles (8BitDo, Xbox, DualShock/DualSense) via SDL2 / Winebus
export SDL_JOYSTICK_HIDAPI=1
export WINE_JOYSTICK_AXES="0,1,2,3,4,5"

# 5. Otimizações de GPU (AMD Radeon / DXVK / Mesa RADV)
export DXVK_ASYNC=1
export DXVK_STATE_CACHE=1
export mesa_glthread=true
export RADV_PERFTEST=gpl

# 6. Selecionar o melhor runner Wine disponível no sistema
if command -v wine-gcs &>/dev/null; then
    WINE_BIN="wine-gcs"
elif [ -x "/opt/wine-gcs/bin/wine" ]; then
    WINE_BIN="/opt/wine-gcs/bin/wine"
elif command -v wine64 &>/dev/null; then
    WINE_BIN="wine"
elif command -v wine &>/dev/null; then
    WINE_BIN="wine"
else
    echo "Erro: Wine não encontrado no sistema!"
    exit 1
fi

echo "=============================================================================="
echo " Iniciando NFS Most Wanted - Project Hanami v3.0 (Dublado PT-BR)"
echo " Runner: $WINE_BIN | Prefixo: $WINEPREFIX"
echo "=============================================================================="

exec "$WINE_BIN" speed.exe "$@"
