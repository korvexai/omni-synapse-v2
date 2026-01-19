// © 2026 Korvex | Audit Module | FREEZE v1.0
use std::sync::atomic::{AtomicU64, Ordering};

#[repr(align(64))] // Prevents false sharing – essential for <1000ns
pub struct ValveStats {
    pub admitted: AtomicU64,
    pub rejected: AtomicU64,
}

pub struct AuditLog {
    pub stats: Vec<ValveStats>,
}

impl AuditLog {
    pub fn new(valves: usize) -> Self {
        let mut stats = Vec::with_capacity(valves);
        for _ in 0..valves {
            stats.push(ValveStats {
                admitted: AtomicU64::new(0),
                rejected: AtomicU64::new(0),
            });
        }
        Self { stats }
    }

    #[inline(always)]
    pub fn log_admission(&self, idx: usize) {
        self.stats[idx].admitted.fetch_add(1, Ordering::Relaxed);
    }
}
