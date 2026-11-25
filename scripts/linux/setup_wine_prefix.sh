#!/usr/bin/env bash
# ==============================================================================
# Script de Configuração e Preparação do Prefixo Wine para NFS Most Wanted
# ==============================================================================

set -e

WINEPREFIX="${WINEPREFIX:-$HOME/.wine}"
export WINEPREFIX

if command -v wine-gcs &>/dev/null; then
    WINE_CMD="wine-gcs"
elif [ -x "/opt/wine-gcs/bin/wine" ]; then
    WINE_CMD="/opt/wine-gcs/bin/wine"
else
    WINE_CMD="wine"
fi

echo "=============================================================================="
echo " Configurando Prefixo Wine para Need for Speed: Most Wanted"
echo " Prefixo: $WINEPREFIX"
echo " Wine:    $WINE_CMD"
echo "=============================================================================="

# 1. Desabilitar AeDebug / winedbg no registro (evita travamentos de tela em caso de exceção)
echo "[1/4] Desabilitando auto-debugger do Wine (AeDebug)..."
"$WINE_CMD" reg add "HKLM\Software\Microsoft\Windows NT\CurrentVersion\AeDebug" /v Auto /d 0 /f >/dev/null 2>&1 || true

# 2. Configurar gráficos no máximo no registro do jogo
echo "[2/4] Aplicando configurações gráficas no registro do jogo..."
"$WINE_CMD" reg add "HKLM\Software\Wow6432Node\EA Games\Need for Speed Most Wanted" /v "FirstTime" /t REG_DWORD /d 1 /f >/dev/null 2>&1
"$WINE_CMD" reg add "HKLM\Software\Wow6432Node\EA Games\Need for Speed Most Wanted" /v "g_WorldLodLevel" /t REG_DWORD /d 3 /f >/dev/null 2>&1
"$WINE_CMD" reg add "HKLM\Software\Wow6432Node\EA Games\Need for Speed Most Wanted" /v "g_RoadReflectionEnable" /t REG_DWORD /d 2 /f >/dev/null 2>&1
"$WINE_CMD" reg add "HKLM\Software\Wow6432Node\EA Games\Need for Speed Most Wanted" /v "g_ShadowDetail" /t REG_DWORD /d 2 /f >/dev/null 2>&1
"$WINE_CMD" reg add "HKLM\Software\Wow6432Node\EA Games\Need for Speed Most Wanted" /v "g_TextureFiltering" /t REG_DWORD /d 2 /f >/dev/null 2>&1
"$WINE_CMD" reg add "HKLM\Software\Wow6432Node\EA Games\Need for Speed Most Wanted" /v "g_OverBrightEnable" /t REG_DWORD /d 1 /f >/dev/null 2>&1
"$WINE_CMD" reg add "HKLM\Software\Wow6432Node\EA Games\Need for Speed Most Wanted" /v "g_VisualTreatment" /t REG_DWORD /d 1 /f >/dev/null 2>&1
"$WINE_CMD" reg add "HKLM\Software\Wow6432Node\EA Games\Need for Speed Most Wanted" /v "g_CarLodLevel" /t REG_DWORD /d 1 /f >/dev/null 2>&1
"$WINE_CMD" reg add "HKLM\Software\Wow6432Node\EA Games\Need for Speed Most Wanted" /v "g_MotionBlurEnable" /t REG_DWORD /d 1 /f >/dev/null 2>&1
"$WINE_CMD" reg add "HKLM\Software\Wow6432Node\EA Games\Need for Speed Most Wanted" /v "g_ParticleSystemEnable" /t REG_DWORD /d 1 /f >/dev/null 2>&1
"$WINE_CMD" reg add "HKLM\Software\Wow6432Node\EA Games\Need for Speed Most Wanted" /v "g_RainEnable" /t REG_DWORD /d 1 /f >/dev/null 2>&1
"$WINE_CMD" reg add "HKLM\Software\Wow6432Node\EA Games\Need for Speed Most Wanted" /v "g_CarEnvironmentMapEnable" /t REG_DWORD /d 1 /f >/dev/null 2>&1
"$WINE_CMD" reg add "HKLM\Software\Wow6432Node\EA Games\Need for Speed Most Wanted" /v "g_CarEnvironmentMapUpdateData" /t REG_DWORD /d 1 /f >/dev/null 2>&1

# 3. Verificar instalação do DXVK
echo "[3/4] Verificando DXVK..."
if [ -f "$WINEPREFIX/drive_c/windows/syswow64/d3d9.dll" ]; then
    echo "  -> d3d9.dll (DXVK 32-bit) encontrado em syswow64."
else
    echo "  [AVISO] d3d9.dll não encontrado em syswow64. Recomenda-se instalar DXVK 2.x 32-bit."
fi

# 4. Verificar Runtimes do DirectX June 2010
echo "[4/4] Verificando Runtimes do DirectX..."
MISSING_DLLS=0
for dll in d3dx9_36.dll d3dx9_43.dll d3dcompiler_43.dll d3dcompiler_47.dll; do
    if [ -f "$WINEPREFIX/drive_c/windows/syswow64/$dll" ]; then
        echo "  -> $dll presente."
    else
        echo "  [AVISO] $dll ausente em syswow64."
        MISSING_DLLS=1
    fi
done

if [ "$MISSING_DLLS" -eq 1 ]; then
    echo "Dica: Execute 'winetricks d3dx9 d3dcompiler_43 d3dcompiler_47' para instalar automaticamente."
fi

echo ""
echo "Configuração do prefixo Wine concluída com sucesso!"
