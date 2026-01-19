# ==========================================================
# Korvex Omni-Synapse | License Generation SDK & HMAC Security
# ==========================================================

# Function to generate a Cryptographic Signature (HMAC-SHA256)
# Used to verify token integrity and prevent tampering.
function Get-HmacSignature {
    param(
        [Parameter(Mandatory=$true)]
        [string]$message, 
        [Parameter(Mandatory=$true)]
        [string]$secret
    )
    
    # Initialize HMACSHA256 with the private secret key
    $hmacsha = New-Object System.Security.Cryptography.HMACSHA256
    $hmacsha.Key = [System.Text.Encoding]::UTF8.GetBytes($secret)
    
    # Compute the hash and convert to a clean hexadecimal string
    $signatureBytes = $hmacsha.ComputeHash([System.Text.Encoding]::UTF8.GetBytes($message))
    return [System.BitConverter]::ToString($signatureBytes).Replace("-", "").ToLower()
}

# ----------------------------------------------------------
# Main License Creation Logic
# ----------------------------------------------------------
$licenseDb = "E:\korvex\licenses.json"
$secretKey = "KORVEX_ULTRA_SECRET_2026_DO_NOT_SHARE"

function New-KorvexLicense {
    param(
        [Parameter(Mandatory=$true)]
        [ValidateSet("BASIC","PRO","ENTERPRISE")]$Tier,
        [Parameter(Mandatory=$true)]
        [string]$ClientName
    )

    # 1. Tier-based Pricing Strategy
    $price = switch ($Tier) {
        "BASIC"      { 49 }
        "PRO"        { 149 }
        "ENTERPRISE" { 499 }
    }

    # 2. Database Initialization (Loads existing or creates new array)
    $db = if (Test-Path $licenseDb) { Get-Content $licenseDb | ConvertFrom-Json } else { @() }

    # 3. Collision-Proof Unique Token Generation
    do {
        # Generates a unique 8-character HEX identifier
        $uniqueId = -join ((48..57)+(65..70) | Get-Random -Count 8 | % {[char]$_})
        $expiryDate = (Get-Date).AddMonths(1)
        $token = "KX-$Tier-$($expiryDate.ToString('yyyy-MM'))-$uniqueId"
    } while ($db.token -contains $token)

    # 4. Usage Limits and Unix Epoch Conversion for Rust Engine
    $epochExpiry = [DateTimeOffset]($expiryDate).ToUnixTimeSeconds()
    $maxRequests = if ($Tier -eq "BASIC") { 10000 } else { [uint64]::MaxValue }

    # 5. Generate Cryptographic Integrity Signature
    $integritySig = Get-HmacSignature -message $token -secret $secretKey

    # 6. License Object Mapping
    $licObject = [PSCustomObject]@{
        token          = $token
        client         = $ClientName
        tier           = $Tier
        price_eur      = $price
        max_requests   = $maxRequests
        expiration     = $epochExpiry
        integrity_sig  = $integritySig
        signature_id   = [guid]::NewGuid().ToString() # Unique internal audit ID
        created_at     = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    }

    # 7. Atomic Write to JSON Storage
    $db += $licObject
    $db | ConvertTo-Json -Depth 10 | Out-File $licenseDb

    # ----------------------------------------------------------
    # Professional Console Output
    # ----------------------------------------------------------
    Write-Host "`n========================================" -ForegroundColor Cyan
    Write-Host " 🛡️  KORVEX LICENSE ISSUED SUCCESSFULLY" -ForegroundColor Green
    Write-Host "========================================"
    Write-Host " Client:      $ClientName"
    Write-Host " Tier:        $Tier"
    Write-Host " Token:       $token" -ForegroundColor Yellow
    Write-Host " Signature:   $integritySig" -ForegroundColor Magenta
    Write-Host " Price:       $price EUR / Month"
    Write-Host " Expiration:  $($expiryDate.ToString('dd/MM/yyyy'))"
    Write-Host " Audit ID:    $($licObject.signature_id)" -ForegroundColor Gray
    Write-Host "========================================`n"
}