param (
    [Parameter(Mandatory=$true)]
    [ValidateSet("BASIC", "PRO", "ENT")]
    $Tier,
    
    [Parameter(Mandatory=$true)]
    $ClientName
)

# Configurare formate
$YearMonth = Get-Date -Format "yyyy-MM"
$FullDate = Get-Date -Format "yyyy-MM-dd_HH-mm"
$RandomID = -join ((65..90) + (48..57) | Get-Random -Count 8 | ForEach-Object {[char]$_})
$Token = "KX-$Tier-$YearMonth-$RandomID"

# Calea către folderul de licențe (Rădăcina proiectului)
$LicenseDir = "E:\korvex\Korvex Omni-Synapse v2.0\EMITTED_LICENSES"
if (!(Test-Path $LicenseDir)) { New-Item -ItemType Directory -Path $LicenseDir }

# Creare conținut fișier
$FileName = "$($LicenseDir)\License_$($ClientName)_$($FullDate).txt"
$FileContent = @"
========================================
  KORVEX OMNI-SYNAPSE OFFICIAL LICENSE
========================================
CLIENT:      $ClientName
TIER:        $Tier
ISSUE DATE:  $(Get-Date -Format "dd MMMM yyyy HH:mm")
TOKEN:       $Token
========================================
STATUS:      ACTIVE
========================================
"@

# Salvare pe PC
$FileContent | Out-File -FilePath $FileName -Encoding utf8

# Afișare în consolă
Write-Host "`n" + "="*40 -ForegroundColor Cyan
Write-Host "  KORVEX LICENSE GENERATOR" -ForegroundColor Cyan
Write-Host "="*40 -ForegroundColor Cyan
Write-Host "CLIENT: $ClientName"
Write-Host "TIER:   $Tier"
Write-Host "TOKEN:  " -NoNewline
Write-Host "$Token" -ForegroundColor Green
Write-Host "-"*40
Write-Host " Fișier salvat la: $FileName" -ForegroundColor Yellow
Write-Host "="*40 -ForegroundColor Cyan
Write-Host "`n"
