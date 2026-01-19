// File: src/platform.rs

#[derive(Copy, Clone)] // Required for array initialization
pub struct Valve;

impl Valve {
    #[inline(always)]
    pub fn try_admit(&self, _id: u64) {
        // High-speed logic
    }
}

// THIS IS THE CRITICAL LINE
// It must be 'pub' so 'main.rs' can find it.
pub static PLATFORM_VALVES: [Valve; 32] = [Valve; 32];