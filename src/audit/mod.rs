#![allow(dead_code)]
//  2026 Korvex | Audit Module | FREEZE v1.0
use std::sync::atomic::{AtomicU64, Ordering};
use std::arch::x86_64::{_rdtsc, _mm_lfence};

#[repr(align(64))] 
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

#[inline(always)]
pub fn measure_latency<F>(f: F) -> u64 
where 
    F: FnOnce() 
{
    unsafe {
        _mm_lfence();
        let start = _rdtsc();
        _mm_lfence();
        f();
        _mm_lfence();
        let end = _rdtsc();
        _mm_lfence();
        end - start
    }
}
