mod auth;
mod audit;

use std::fs;
use sha2::{Sha256, Digest};
use machine_uid; 
use auth::license_gate::{LicenseGate, LicenseTier};
use audit::measure_latency;

fn verify_hard_lock() -> bool {
    let hwid = machine_uid::get().unwrap_or_else(|_| "UNKNOWN_ID".to_string());
    let tier = "GOLD"; 
    let secret_salt = "KORVEX_MASTER_SECRET_KEY_2026";
    let license_path = "license.key";

    if !std::path::Path::new(license_path).exists() {
        println!("\n? EROARE: Licenta lipseste!");
        println!("HWID-ul acestui PC: {}", hwid);
        return false;
    }

    let stored_key = fs::read_to_string(license_path).unwrap_or_default().trim().to_string();
    let mut hasher = Sha256::new();
    hasher.update(format!("{}-{}-{}", hwid, tier, secret_salt));
    let expected_key = format!("{:x}", hasher.finalize());

    if stored_key != expected_key {
        println!("\n? EROARE: Licenta invalida!");
        // ACEASTA LINIE ITI VA SPUNE CODUL CORECT PE ECRAN:
        return false;
    }
    true
}

fn main() {
    if !verify_hard_lock() {
        std::process::exit(1);
    }

    println!("? LICENTA VALIDA - Acces Grantat Omni-Synapse V2.0");

    let mock_token = "KX-PRO-2026-01-ABCD1234";
    for _ in 0..1000 {
        let _ = LicenseGate::validate_token(mock_token);
        let _ = (0..10).fold(0, |acc, x| acc ^ x);
    }

    let total_cycles = measure_latency(|| {
        let tier = LicenseGate::validate_token(mock_token);
        if matches!(tier, LicenseTier::Invalid) { return; }
        let _ = (0..10).fold(0, |acc, x| acc ^ x);
    });

    println!("\n OMNI-SYNAPSE V2.0 FINAL AUDIT (Optimized)");
    println!("----------------------------------------------");
    println!("Total Latency: {} cycles", total_cycles);
}
