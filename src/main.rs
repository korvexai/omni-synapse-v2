mod auth;
mod audit;

use auth::license_gate::{LicenseGate, LicenseTier};
use audit::measure_latency;

fn main() {
    let mock_token = "KX-PRO-2026-01-ABCD1234";
    
    // Audităm întreg procesul: Securitate + Procesare
    let total_cycles = measure_latency(|| {
        // Step 1: Security Gate (Hard-Lock)
        let tier = LicenseGate::validate_token(mock_token);
        
        if matches!(tier, LicenseTier::Invalid) {
            return; // Block unauthorized access
        }

        // Step 2: Admission Logic (Exemplu: XOR Fold optimizat)
        let _ = (0..10).fold(0, |acc, x| acc ^ x);
    });

    println!("\n OMNI-SYNAPSE V2.0 FINAL AUDIT");
    println!("------------------------------------");
    println!("Total Latency (Auth + Process): {} cycles", total_cycles);
    
    if total_cycles <= 336 {
        println!("STATUS: SUCCESS (HFT Compliant )");
    } else {
        println!("STATUS: PERFORMANCE REGRESSION ");
    }
}
