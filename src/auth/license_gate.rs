//  2026 Korvex | License Gate | High-Speed Validation
// Optimized for < 15 cycles overhead

pub enum LicenseTier {
    Basic,
    Pro,
    Enterprise,
    Invalid,
}

pub struct LicenseGate;

impl LicenseGate {
    /// Verifică header-ul X-Korvex-License la viteză de microsecunde.
    /// Format așteptat: KX-[TIER]-[YYYY-MM]-[ID]
    #[inline(always)]
    pub fn validate_token(token: &str) -> LicenseTier {
        if token.len() < 15 { return LicenseTier::Invalid; }

        // Verificăm prefixul "KX-" folosind pointeri pentru viteză maximă
        let bytes = token.as_bytes();
        if bytes[0] != b'K' || bytes[1] != b'X' || bytes[2] != b'-' {
            return LicenseTier::Invalid;
        }

        // Detectăm Tier-ul fără a aloca memorie (Zero-Allocation)
        if token.contains("-PRO-") {
            LicenseTier::Pro
        } else if token.contains("-ENT-") {
            LicenseTier::Enterprise
        } else if token.contains("-BAS-") {
            LicenseTier::Basic
        } else {
            LicenseTier::Invalid
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::audit::measure_latency;

    #[test]
    fn test_license_performance() {
        let token = "KX-PRO-2026-01-ABCD1234";
        
        let cycles = measure_latency(|| {
            let tier = LicenseGate::validate_token(token);
            assert!(matches!(tier, LicenseTier::Pro));
        });

        println!("\n[SECURITY] License Validation Latency: {} cycles", cycles);
        assert!(cycles < 50, "Security check too slow!");
    }
}
