<#
.SYNOPSIS
    Alterna o perfil de entrada (Controle XInput vs Volante Logitech G920) no WidescreenFix.
.DESCRIPTION
    Modifica o arquivo NFSMostWanted.WidescreenFix.ini na pasta do jogo para alternar
    entre o modo Controle (8BitDo/Xbox via XInput) e o modo Volante (Logitech G920 DirectInput).
#>

[CmdletBinding()]
param(
    [ValidateSet("gamepad", "wheel", "status")]
    [string]$Mode = "status",
    [string]$GameDir = "D:\Jogos\Outros\NFSMost\NFS_Most_Wanted_Hanami"
)

$ErrorActionPreference = "Stop"

# Localizar pasta do jogo se o padrao nao existir
if (-not (Test-Path "$GameDir\scripts\NFSMostWanted.WidescreenFix.ini")) {
    $candidates = @(
        "$PSScriptRoot\..\..\..\NFS_Most_Wanted_Hanami",
        "$PSScriptRoot\..\..\NFS_Most_Wanted_Hanami",
        "$PSScriptRoot\..\.."
    )
    foreach ($c in $candidates) {
        if (Test-Path "$c\scripts\NFSMostWanted.WidescreenFix.ini") {
            $GameDir = (Resolve-Path $c).Path
            break
        }
    }
}

$iniPath = "$GameDir\scripts\NFSMostWanted.WidescreenFix.ini"
if (-not (Test-Path $iniPath)) {
    Write-Error "Arquivo NFSMostWanted.WidescreenFix.ini não encontrado em '$iniPath'."
    exit 1
}

$content = Get-Content $iniPath -Raw

# Ler estado atual
$currentSupport = if ($content -match 'ImproveGamepadSupport\s*=\s*(\d+)') { $Matches[1] } else { "?" }
$currentDeadzone = if ($content -match 'LeftStickDeadzone\s*=\s*([\d\.]+)') { $Matches[1] } else { "?" }

if ($Mode -eq "status") {
    $label = switch ($currentSupport) {
        "1" { "Controle XInput (Xbox / 8BitDo)" }
        "2" { "Controle PlayStation" }
        "3" { "Volante / DirectInput Nativo (Logitech G920)" }
        default { "Personalizado ($currentSupport)" }
    }
    Write-Host "==============================================================================" -ForegroundColor Cyan
    Write-Host " Perfil de Entrada Atual: $label" -ForegroundColor Yellow
    Write-Host "   ImproveGamepadSupport = $currentSupport | LeftStickDeadzone = $currentDeadzone" -ForegroundColor Gray
    Write-Host "   Arquivo: $iniPath" -ForegroundColor Gray
    Write-Host "==============================================================================" -ForegroundColor Cyan
    exit 0
}

if ($Mode -eq "wheel") {
    $content = $content -replace '(?m)^ImproveGamepadSupport\s*=\s*\d+', 'ImproveGamepadSupport = 3'
    $content = $content -replace '(?m)^LeftStickDeadzone\s*=\s*[\d\.]+', 'LeftStickDeadzone = 0.0'
    Set-Content -Path $iniPath -Value $content -NoNewline
    Write-Host "[OK] Modo VOLANTE (Logitech G920 / DirectInput) ativado!" -ForegroundColor Green
    Write-Host "     ImproveGamepadSupport = 3 | LeftStickDeadzone = 0.0" -ForegroundColor Gray
    Write-Host "     Lembre-se de configurar o perfil no Logitech G HUB (270°-360° e Pedais Combinados se necessario)." -ForegroundColor Yellow
} elseif ($Mode -eq "gamepad") {
    $content = $content -replace '(?m)^ImproveGamepadSupport\s*=\s*\d+', 'ImproveGamepadSupport = 1'
    $content = $content -replace '(?m)^LeftStickDeadzone\s*=\s*[\d\.]+', 'LeftStickDeadzone = 10.0'
    Set-Content -Path $iniPath -Value $content -NoNewline
    Write-Host "[OK] Modo CONTROLE (8BitDo / Xbox XInput) ativado!" -ForegroundColor Green
    Write-Host "     ImproveGamepadSupport = 1 | LeftStickDeadzone = 10.0" -ForegroundColor Gray
}
