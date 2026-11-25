<#
.SYNOPSIS
    Script de Preparação e Configuração Completa do NFS Most Wanted Hanami v3.0 no Windows.
.DESCRIPTION
    Realiza o setup automatizado:
    - Validação de Runtimes (DirectX 9.0c e Visual C++ 2015-2022 x86)
    - Aplicação de chaves de registro gráficas e de compatibilidade
    - Aplicação do AMD FIX (dgVoodoo D3D11) para placas Radeon RX
    - Restauração dos plugins .asi de mods visuais (NextGenGraphics, CustomShaders, etc.)
    - Espelhamento preventivo de savefiles (SAVA -> Documents)
    - Criação de atalho com ícone personalizado na Área de Trabalho
#>

[CmdletBinding()]
param(
    [string]$GameDir = "D:\Jogos\Outros\NFSMost\NFS_Most_Wanted_Hanami",
    [switch]$SkipDesktopShortcut,
    [switch]$KeepModsDisabled
)

$ErrorActionPreference = "Stop"

Write-Host "==============================================================================" -ForegroundColor Cyan
Write-Host " Setup e Otimização para Windows - NFS Most Wanted (Project Hanami v3.0)" -ForegroundColor Yellow
Write-Host "==============================================================================" -ForegroundColor Cyan

# 1. Localizar pasta do jogo
if (-not (Test-Path "$GameDir\speed.exe")) {
    $candidates = @(
        "$PSScriptRoot\..\..\..\NFS_Most_Wanted_Hanami",
        "$PSScriptRoot\..\..\NFS_Most_Wanted_Hanami",
        "$PSScriptRoot\..\.."
    )
    foreach ($c in $candidates) {
        if (Test-Path "$c\speed.exe") {
            $GameDir = (Resolve-Path $c).Path
            break
        }
    }
}

if (-not (Test-Path "$GameDir\speed.exe")) {
    Write-Error "Não foi possível localizar 'speed.exe' em '$GameDir'. Verifique o caminho."
    exit 1
}

$GameDir = (Resolve-Path $GameDir).Path
Write-Host "[1/6] Pasta do Jogo: $GameDir" -ForegroundColor Green

# 2. Checagem de Runtimes
Write-Host "`n[2/6] Verificando Runtimes do Windows (DirectX 9.0c e Visual C++ x86)..." -ForegroundColor Cyan
$syswow64 = "$env:WINDIR\SysWOW64"
$dxFiles = @("d3dx9_36.dll", "d3dx9_43.dll", "d3dcompiler_43.dll", "d3dcompiler_47.dll")
$vcFiles = @("vcruntime140.dll", "msvcp140.dll")

$allDxOk = $true
foreach ($f in $dxFiles) {
    if (Test-Path "$syswow64\$f") {
        Write-Host "  -> DirectX: $f [OK]" -ForegroundColor Green
    } else {
        Write-Host "  -> DirectX: $f [AUSENTE]" -ForegroundColor Yellow
        $allDxOk = $false
    }
}

$allVcOk = $true
foreach ($f in $vcFiles) {
    if (Test-Path "$syswow64\$f") {
        Write-Host "  -> VC++ x86: $f [OK]" -ForegroundColor Green
    } else {
        Write-Host "  -> VC++ x86: $f [AUSENTE]" -ForegroundColor Yellow
        $allVcOk = $false
    }
}

if (-not $allDxOk -or -not $allVcOk) {
    Write-Host "[AVISO] Há runtimes ausentes. Encontre os instaladores em:" -ForegroundColor Yellow
    Write-Host "        $GameDir\..\Instaladores_e_Downloads\NFS\_Redist.zip" -ForegroundColor Yellow
}

# 3. Aplicar Registro Gráfico Máximo
Write-Host "`n[3/6] Aplicando configurações visuais máximas no Registro..." -ForegroundColor Cyan
$regKeys = @(
    "HKCU:\Software\Classes\VirtualStore\MACHINE\SOFTWARE\Wow6432Node\EA Games\Need for Speed Most Wanted",
    "HKCU:\Software\EA Games\Need for Speed Most Wanted"
)

$regValues = @{
    "FirstTime"                     = 1
    "g_CarEnvironmentMapEnable"     = 1
    "g_CarEnvironmentMapUpdateData" = 1
    "g_CarLodLevel"                 = 1
    "g_FSAALevel"                   = 0
    "g_MotionBlurEnable"            = 1
    "g_OverBrightEnable"            = 1
    "g_ParticleSystemEnable"        = 1
    "g_PerformanceLevel"            = 1
    "g_RacingResolution"            = 0
    "g_RainEnable"                  = 1
    "g_RoadReflectionEnable"        = 2
    "g_ShadowDetail"                = 2
    "g_TextureFiltering"            = 2
    "g_VisualTreatment"             = 1
    "g_VSyncOn"                     = 0
    "g_WorldLodLevel"               = 3
    "SIZE"                          = 0x84
    "VERSION"                       = 1
}

foreach ($targetKey in $regKeys) {
    if (-not (Test-Path $targetKey)) {
        New-Item -Path $targetKey -Force | Out-Null
    }
    foreach ($entry in $regValues.GetEnumerator()) {
        Set-ItemProperty -Path $targetKey -Name $entry.Key -Value $entry.Value -Type DWord -Force | Out-Null
    }
}
Write-Host "  -> Chaves HKCU / VirtualStore atualizadas com sucesso." -ForegroundColor Green

# Tentar HKLM se elevado
try {
    $hklmKey = "HKLM:\Software\Wow6432Node\EA Games\Need for Speed Most Wanted"
    if (-not (Test-Path $hklmKey)) {
        New-Item -Path $hklmKey -Force -ErrorAction Stop | Out-Null
    }
    foreach ($entry in $regValues.GetEnumerator()) {
        Set-ItemProperty -Path $hklmKey -Name $entry.Key -Value $entry.Value -Type DWord -Force -ErrorAction Stop | Out-Null
    }
    Write-Host "  -> Chaves HKLM atualizadas com sucesso." -ForegroundColor Green
} catch {
    Write-Host "  -> Nota: HKLM nao foi alterado (requer administrador). A chave HKCU/VirtualStore ja e suficiente." -ForegroundColor Gray
}

# 4. AMD Radeon dgVoodoo Fix
Write-Host "`n[4/6] Verificando placa de vídeo para AMD Fix..." -ForegroundColor Cyan
$gpu = Get-CimInstance Win32_VideoController | Select-Object -First 1
Write-Host "  -> Adaptador: $($gpu.Name)" -ForegroundColor Cyan

if ($gpu.Name -match "AMD|Radeon") {
    $amdFixDir = "$GameDir\AMD FIX"
    if (-not (Test-Path "$GameDir\d3d9.dll") -and (Test-Path "$amdFixDir\d3d9.dll")) {
        Copy-Item "$amdFixDir\d3d9.dll" "$GameDir\" -Force
        Copy-Item "$amdFixDir\dgVoodoo.conf" "$GameDir\" -Force
        Copy-Item "$amdFixDir\dxgi.dll" "$GameDir\" -Force
        Write-Host "  -> AMD FIX (dgVoodoo D3D11 wrapper) instalado na raiz do jogo com sucesso!" -ForegroundColor Green
    } elseif (Test-Path "$GameDir\d3d9.dll") {
        Write-Host "  -> AMD FIX (dgVoodoo D3D11 wrapper) ja esta presente e ativo na raiz do jogo." -ForegroundColor Green
    } else {
        Write-Host "  -> [AVISO] Pasta AMD FIX não encontrada em $amdFixDir." -ForegroundColor Yellow
    }
} else {
    Write-Host "  -> GPU não-AMD detectada. O fix dgVoodoo não é estritamente necessário." -ForegroundColor Gray
}

# 5. Restauração de Plugins ASI (Mods Hanami)
Write-Host "`n[5/6] Gerenciando plugins ASI de mods visuais..." -ForegroundColor Cyan
$scriptsDir = "$GameDir\scripts"
if (-not $KeepModsDisabled -and (Test-Path $scriptsDir)) {
    $testBakFiles = Get-ChildItem "$scriptsDir" -Filter "*.test_bak"
    foreach ($item in $testBakFiles) {
        $destName = $item.Name -replace '\.test_bak$', ''
        $destPath = Join-Path $scriptsDir $destName
        Move-Item -Path $item.FullName -Destination $destPath -Force
        Write-Host "  -> Restaurado plugin: $destName" -ForegroundColor Green
    }
    # Checar XenonEffects
    if (Test-Path "$scriptsDir\NFSMW_XenonEffects.asi.bak") {
        Move-Item "$scriptsDir\NFSMW_XenonEffects.asi.bak" "$scriptsDir\NFSMW_XenonEffects.asi" -Force
        Write-Host "  -> Restaurado plugin: NFSMW_XenonEffects.asi" -ForegroundColor Green
    }
} else {
    Write-Host "  -> Plugins mantidos no estado atual." -ForegroundColor Gray
}

# 6. Espelhamento de Save e Atalho na Área de Trabalho
Write-Host "`n[6/6] Sincronização de Saves e Atalho..." -ForegroundColor Cyan

# Espelhar save profile marcos
$savaPath = "$GameDir\SAVA\NFS Most Wanted"
$docsSavePath = [System.IO.Path]::Combine([Environment]::GetFolderPath("MyDocuments"), "NFS Most Wanted")

if (Test-Path "$savaPath\marcos") {
    if (-not (Test-Path "$docsSavePath\marcos")) {
        New-Item -Path "$docsSavePath\marcos" -ItemType Directory -Force | Out-Null
    }
    Copy-Item "$savaPath\marcos\*" "$docsSavePath\marcos\" -Recurse -Force
    Write-Host "  -> Perfil 'marcos' espelhado com sucesso para Meus Documentos:\NFS Most Wanted\marcos" -ForegroundColor Green
}

# Criar Atalho na Área de Trabalho
if (-not $SkipDesktopShortcut) {
    try {
        $desktop = [Environment]::GetFolderPath("Desktop")
        $shortcutPath = "$desktop\Need for Speed Most Wanted - Hanami.lnk"
        $wshShell = New-Object -ComObject WScript.Shell
        $shortcut = $wshShell.CreateShortcut($shortcutPath)
        
        $launcherBat = "$GameDir\..\NFSMost\scripts\windows\run_game.bat"
        if (-not (Test-Path $launcherBat)) {
            $launcherBat = "$PSScriptRoot\run_game.bat"
        }
        
        $shortcut.TargetPath = "$GameDir\speed.exe"
        $shortcut.WorkingDirectory = $GameDir
        if (Test-Path "$GameDir\icon.ico") {
            $shortcut.IconLocation = "$GameDir\icon.ico,0"
        }
        $shortcut.Description = "Need for Speed: Most Wanted (2005) - Project Hanami v3.0"
        $shortcut.Save()
        Write-Host "  -> Atalho criado na Área de Trabalho: $shortcutPath" -ForegroundColor Green
    } catch {
        Write-Host "  -> Não foi possível criar o atalho automaticamente: $_" -ForegroundColor Yellow
    }
}

Write-Host "`n==============================================================================" -ForegroundColor Cyan
Write-Host " Setup concluído com sucesso! Agora você pode rodar o jogo." -ForegroundColor Yellow
Write-Host "==============================================================================" -ForegroundColor Cyan
