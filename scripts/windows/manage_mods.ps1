<#
.SYNOPSIS
    Gerenciador de Mods .ASI para NFS Most Wanted - Hanami v3.0.
.DESCRIPTION
    Permite listar, habilitar ou desabilitar módulos ASI específicos para
    diagnosticar problemas de compatibilidade no Windows.
#>

[CmdletBinding()]
param(
    [string]$GameDir = "D:\Jogos\Outros\NFSMost\NFS_Most_Wanted_Hanami",
    [string]$ToggleMod = "",
    [switch]$EnableAll,
    [switch]$DisableAll,
    [switch]$List
)

$scriptsDir = "$GameDir\scripts"
if (-not (Test-Path $scriptsDir)) {
    Write-Error "Diretório de scripts não encontrado em $scriptsDir"
    exit 1
}

function Get-ModStatus {
    $files = Get-ChildItem $scriptsDir | Where-Object { $_.Name -match '\.(asi|test_bak|bak)$' }
    return $files
}

if ($EnableAll) {
    Write-Host "Habilitando todos os mods (.bak/.test_bak -> .asi)..." -ForegroundColor Cyan
    Get-ChildItem $scriptsDir | Where-Object { $_.Name -match '\.asi\.(test_bak|bak)$' } | ForEach-Object {
        $newName = $_.Name -replace '\.(test_bak|bak)$', ''
        Move-Item $_.FullName (Join-Path $scriptsDir $newName) -Force
        Write-Host "  [ATIVADO] $newName" -ForegroundColor Green
    }
} elseif ($DisableAll) {
    Write-Host "Desabilitando mods visuais adicionais..." -ForegroundColor Yellow
    $targets = @("NextGenGraphics.MostWanted.asi", "NFSMWCustomShaders.asi", "NFSMW_XenonEffects.asi", "XNFS-ShaderLoader-MW.asi")
    foreach ($t in $targets) {
        if (Test-Path "$scriptsDir\$t") {
            Move-Item "$scriptsDir\$t" "$scriptsDir\$t.bak" -Force
            Write-Host "  [DESATIVADO] $t" -ForegroundColor Yellow
        }
    }
} elseif ($ToggleMod) {
    $exactAsi = "$scriptsDir\$ToggleMod.asi"
    $exactBak = "$scriptsDir\$ToggleMod.asi.bak"
    $exactTestBak = "$scriptsDir\$ToggleMod.asi.test_bak"
    
    if (Test-Path $exactAsi) {
        Move-Item $exactAsi "$exactAsi.bak" -Force
        Write-Host "Mod '$ToggleMod' DESATIVADO (.asi.bak)" -ForegroundColor Yellow
    } elseif (Test-Path $exactBak) {
        Move-Item $exactBak $exactAsi -Force
        Write-Host "Mod '$ToggleMod' ATIVADO (.asi)" -ForegroundColor Green
    } elseif (Test-Path $exactTestBak) {
        Move-Item $exactTestBak $exactAsi -Force
        Write-Host "Mod '$ToggleMod' ATIVADO (.asi)" -ForegroundColor Green
    } else {
        Write-Warning "Mod '$ToggleMod' não encontrado em $scriptsDir."
    }
}

Write-Host "`nStatus atual dos plugins em $scriptsDir:" -ForegroundColor Cyan
Get-ChildItem $scriptsDir | Where-Object { $_.Name -match '\.asi' } | Sort-Object Name | ForEach-Object {
    if ($_.Extension -eq ".asi") {
        Write-Host "  [x] $($_.Name) (Ativo)" -ForegroundColor Green
    } else {
        Write-Host "  [ ] $($_.Name) (Inativo)" -ForegroundColor Gray
    }
}
