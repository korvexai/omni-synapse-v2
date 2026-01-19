cd "E:\korvex\Korvex Omni-Synapse v2.0"
copy Cargo_commercial.toml Cargo.toml -Force
copy Cargo_commercial.lock Cargo.lock -Force
copy src\main_commercial.rs src\main.rs -Force
Write-Host "Activata varianta COMERCIALA" -ForegroundColor Yellow
