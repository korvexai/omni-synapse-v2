$Client = Read-Host "Enter Client Name (e.g., HedgeFund_London)"
$Tier = Read-Host "Enter Tier (BASIC, PRO, ENT)"

# Generăm licența automat
.\generate_client_token.ps1 -Tier $Tier -ClientName $Client

# Creăm arhiva ZIP profesională pentru livrare
$Date = Get-Date -Format "yyyy-MM-dd"
$ZipName = "Korvex_OmniSynapse_v2_$($Client)_$($Date).zip"

Write-Host " Archiving RELEASE_KIT for client..." -ForegroundColor Cyan
if (Test-Path $ZipName) { Remove-Item $ZipName }
Compress-Archive -Path ".\RELEASE_KIT\*" -DestinationPath $ZipName

Write-Host "`n" + "="*50 -ForegroundColor Green
Write-Host "  READY TO SEND!" -ForegroundColor Green
Write-Host " 1. Attach this file: E:\korvex\Korvex Omni-Synapse v2.0\$ZipName" -ForegroundColor White
Write-Host " 2. Copy the Token from EMITTED_LICENSES folder." -ForegroundColor White
Write-Host "="*50 -ForegroundColor Green
Explore .
