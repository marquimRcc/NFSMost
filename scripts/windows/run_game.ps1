<#
.SYNOPSIS
    Lançador Otimizado para Need for Speed: Most Wanted - Project Hanami v3.0 no Windows.
.DESCRIPTION
    Detecta automaticamente o caminho do jogo, valida pré-requisitos, detecta GPUs AMD Radeon
    e garante que o fix dgVoodoo e as chaves de registro estejam configuradas.
#>

[CmdletBinding()]
param(
    [string]$GamePath = ""
)

$ErrorActionPreference = "Stop"

# 1. Localizar pasta do jogo
$candidates = @(
    $GamePath,
    "$PSScriptRoot\..\..\..\NFS_Most_Wanted_Hanami",
    "$PSScriptRoot\..\..\NFS_Most_Wanted_Hanami",
    "$PSScriptRoot\..\..",
    "$PSScriptRoot\..",
    (Get-Location).Path,
    "D:\Jogos\Outros\NFSMost\NFS_Most_Wanted_Hanami"
)

$resolvedGameDir = $null
foreach ($path in $candidates) {
    if (-not [string]::IsNullOrWhiteSpace($path) -and (Test-Path "$path\speed.exe")) {
        $resolvedGameDir = (Resolve-Path $path).Path
        break
    }
}

if (-not $resolvedGameDir) {
    Write-Error "[ERRO] Não foi possível encontrar a pasta do jogo com speed.exe. Informe o caminho via -GamePath."
    exit 1
}

Write-Host "==============================================================================" -ForegroundColor Cyan
Write-Host " Need for Speed: Most Wanted - Project Hanami v3.0 (Dublado PT-BR)" -ForegroundColor Yellow
Write-Host " Pasta do Jogo: $resolvedGameDir" -ForegroundColor Green
Write-Host "==============================================================================" -ForegroundColor Cyan

# 2. Verificar GPU e AMD Fix
$gpu = Get-CimInstance Win32_VideoController | Select-Object -First 1
Write-Host "[GPU Detectada] $($gpu.Name)" -ForegroundColor Cyan

if ($gpu.Name -match "AMD|Radeon") {
    $hasD3D9 = Test-Path "$resolvedGameDir\d3d9.dll"
    $hasDxgi = Test-Path "$resolvedGameDir\dxgi.dll"
    $hasAmdFix = Test-Path "$resolvedGameDir\AMD FIX\d3d9.dll"

    if (-not $hasD3D9 -and $hasAmdFix) {
        Write-Host "[INFO] Placa AMD Radeon detectada. Aplicando dgVoodoo AMD FIX para evitar asfalto escuro..." -ForegroundColor Yellow
        Copy-Item "$resolvedGameDir\AMD FIX\d3d9.dll" "$resolvedGameDir\" -Force
        Copy-Item "$resolvedGameDir\AMD FIX\dgVoodoo.conf" "$resolvedGameDir\" -Force
        Copy-Item "$resolvedGameDir\AMD FIX\dxgi.dll" "$resolvedGameDir\" -Force
        Write-Host "  -> Fix dgVoodoo aplicado com sucesso!" -ForegroundColor Green
    } elseif ($hasD3D9) {
        Write-Host "  -> Wrapper dgVoodoo D3D9 ativo." -ForegroundColor Green
    }
}

# 3. Aplicar configurações de registro (HKCU e VirtualStore)
$regPaths = @(
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

foreach ($targetKey in $regPaths) {
    if (-not (Test-Path $targetKey)) {
        New-Item -Path $targetKey -Force | Out-Null
    }
    foreach ($entry in $regValues.GetEnumerator()) {
        Set-ItemProperty -Path $targetKey -Name $entry.Key -Value $entry.Value -Type DWord -Force | Out-Null
    }
}
Write-Host "[Registro] Configurações visuais máximas aplicadas com sucesso (World LOD=3)." -ForegroundColor Green

# 4. Validar Saves
$saveProfile = "$resolvedGameDir\SAVA\NFS Most Wanted\marcos"
if (Test-Path $saveProfile) {
    Write-Host "[Save] Perfil de progresso 'marcos' encontrado em SAVA." -ForegroundColor Green
} else {
    Write-Host "[Save] Perfil em SAVA não encontrado. Verificando Documents..." -ForegroundColor Yellow
}

# 5. Iniciar o Jogo
Write-Host "Iniciando speed.exe..." -ForegroundColor Cyan
Start-Process -FilePath "$resolvedGameDir\speed.exe" -WorkingDirectory $resolvedGameDir
