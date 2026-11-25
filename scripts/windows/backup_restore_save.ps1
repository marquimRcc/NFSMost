<#
.SYNOPSIS
    Script de Backup e Sincronização de Saves do NFS Most Wanted.
.DESCRIPTION
    Realiza backup com carimbo de data/hora do perfil 'marcos' ou outro perfil,
    sincronizando entre a pasta SAVA interna do jogo e Meus Documentos.
#>

[CmdletBinding()]
param(
    [string]$GameDir = "D:\Jogos\Outros\NFSMost\NFS_Most_Wanted_Hanami",
    [string]$ProfileName = "marcos",
    [switch]$RestoreFromBackup,
    [string]$BackupZip = ""
)

$savaDir = "$GameDir\SAVA\NFS Most Wanted\$ProfileName"
$docsDir = [System.IO.Path]::Combine([Environment]::GetFolderPath("MyDocuments"), "NFS Most Wanted", $ProfileName)
$backupRoot = "$GameDir\SAVA_BACKUPS"

if (-not (Test-Path $backupRoot)) {
    New-Item -Path $backupRoot -ItemType Directory -Force | Out-Null
}

$timestamp = (Get-Date).ToString("yyyyMMdd_HHmmss")
$targetZip = "$backupRoot\save_${ProfileName}_$timestamp.zip"

if (Test-Path $savaDir) {
    Write-Host "Criando backup do perfil '$ProfileName' de SAVA..." -ForegroundColor Cyan
    Compress-Archive -Path "$savaDir\*" -DestinationPath $targetZip -Force
    Write-Host "Backup salvo em: $targetZip" -ForegroundColor Green
} elseif (Test-Path $docsDir) {
    Write-Host "Criando backup do perfil '$ProfileName' de Documentos..." -ForegroundColor Cyan
    Compress-Archive -Path "$docsDir\*" -DestinationPath $targetZip -Force
    Write-Host "Backup salvo em: $targetZip" -ForegroundColor Green
} else {
    Write-Warning "Nenhum save encontrado para o perfil '$ProfileName'."
}

# Sincronizar entre SAVA e Documents
if (Test-Path $savaDir) {
    if (-not (Test-Path $docsDir)) {
        New-Item -Path $docsDir -ItemType Directory -Force | Out-Null
    }
    Copy-Item "$savaDir\*" "$docsDir\" -Recurse -Force
    Write-Host "Sincronizado: SAVA -> Meus Documentos" -ForegroundColor Green
}
