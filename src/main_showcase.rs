// © 2026 Korvex | Ultra-Low-Latency Core | FREEZE v1.0
// Target: <1000 cycles hot-path (Bare-metal optimization)

mod platform;
mod audit;
mod security;
mod tracking;

use core::arch::x86_64::{_rdtsc, _mm_lfence};
use core::sync::atomic::{AtomicU64, Ordering};
use actix_web::{App, HttpServer, HttpResponse, Responder, post};

// --- DETERMINISTIC STATE ---
static DNA_COUNTER: AtomicU64 = AtomicU64::new(1);
const PLATFORM_VALVES_MASK: usize = 31;

// --- TEMPORAL CORE ---
#[inline(always)]
fn rdtsc_ordered() -> u64 {
    unsafe {
        _mm_lfence();
        let t = _rdtsc();
        _mm_lfence();
        t
    }
}

// --- HOT-PATH INJECTION ---
#[no_mangle]
pub extern "C" fn handle_fire_request(_ptr: *const u8, _len: usize) -> u64 {
    let start = rdtsc_ordered();
    let id = DNA_COUNTER.fetch_add(1, Ordering::Relaxed);
    let valve_idx = (id as usize) & PLATFORM_VALVES_MASK;

    unsafe {
        crate::platform::PLATFORM_VALVES
            .get_unchecked(valve_idx)
            .try_admit(id);
    }

    let end = rdtsc_ordered();
    end - start 
}

// --- NETWORK HANDLER ---
#[post("/fire")]
async fn fire_handler() -> impl Responder {
    // Injects the request into the V8-32 engine core
    let cycles = handle_fire_request(core::ptr::null(), 0);

    HttpResponse::Ok()
        .insert_header(("X-Korvex-Cycles", cycles.to_string()))
        .body("ADMITTED")
}

// --- ENGINE + PORT STARTUP ---
#[actix_web::main]
async fn main() -> std::io::Result<()> {
    println!("==================================================");
    println!("🏁 KORVEX OMNI-SYNAPSE v2.0 | ENGINE + PORT ONLINE");
    println!("📡 Listening on: http://127.0.0.1:8080/fire");
    println!("🛡️  Mode: Zero-Delirium | Threads: 32");
    println!("==================================================");

    HttpServer::new(|| {
        App::new().service(fire_handler)
    })
    .workers(32) // Aligned with the 32-valve architecture
    .bind("0.0.0.0:8080")?
    .run()
    .await
}