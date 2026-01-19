// © 2026 Korvex | Tracking Module | FREEZE v1.0
pub const TRACKING_HASH: u64 = 0x9E3779B1;

#[inline(always)]
pub fn generate_forensic_id(current_tsc: u64) -> u64 {
    // Use the already-read TSC to avoid a second hardware call
    current_tsc ^ TRACKING_HASH
}
