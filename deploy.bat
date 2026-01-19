@echo off
setlocal enabledelayedexpansion
echo 🏁 REPAIRING KORVEX OMNI-SYNAPSE v2.0...

:: 1. Build Folder Structure
if not exist src mkdir src

:: 2. Write Corrected Cargo.toml (FIXED: arc-swap with dash)
(
echo [package]
echo name = "korvex-omni-synapse"
echo version = "2.0.0"
echo edition = "2021"
echo authors = ["Korvex"]
echo description = "International Ultra-Low Latency Admission Standard"
echo.
echo [dependencies]
echo actix-web = "4.4"
echo tokio = { version = "1.32", features = ["full"] }
echo serde = { version = "1.0", features = ["derive"] }
echo serde_yaml = "0.9"
echo arc-swap = "1.6"
echo instant = "0.1"
echo.
echo [profile.release]
echo opt-level = 3
echo lto = "fat"
echo codegen-units = 1
echo panic = "abort"
echo strip = "symbols"
) > Cargo.toml

:: 3. Write Global ECU (_config.yml)
(
echo title: "Korvex Omni-Synapse v2.0 (Global Edition)"
echo tagline: "International Ultra-Low Latency Admission Standard"
echo timezone: "UTC"
echo lang: "en-US"
echo.
echo engine:
echo   valves: 32
echo   capacity_per_valve: 131072
echo   ram_shield_mb: 264
echo   forensic_active: true
echo   geo_distribution: true
) > _config.yml

:: 4. Core Logic Integration (Sync with Global ECU)
(
echo mod security; mod tracking; mod audit; mod platform;
echo use std::sync::Arc; use arc_swap::ArcSwap; use actix_web::{web, App, HttpServer, HttpResponse, Responder}; use serde::Deserialize;
echo #[derive(Debug, Deserialize, Clone^)]
echo pub struct EngineParams { pub valves: usize, pub capacity_per_valve: usize, pub geo_distribution: bool, pub forensic_active: bool }
echo #[derive(Debug, Deserialize, Clone^)]
echo pub struct OmniConfig { pub title: String, pub engine: EngineParams, pub timezone: String }
echo pub struct OmniSynapse { pub config: ArcSwap^<OmniConfig^>, pub platform: crate::platform::Platform, pub audit: Arc^<crate::audit::AuditLog^> }
echo.
echo async fn fire_valve(data: web::Data^<Arc^<OmniSynapse^>^>^) -^> impl Responder {
echo     let start = std::time::Instant::now(^);
echo     let id = crate::tracking::generate_forensic_id(^);
echo     let config = data.config.load(^);
echo     let (idx, engine^) = data.platform.route(id^);
echo     let success = engine.inject(id, ^&crate::security::HyperCore::from_config(^&config^), ^&data.audit, idx^);
echo     HttpResponse::Ok(^).insert_header(("X-Korvex-Nanos", start.elapsed(^).as_nanos(^).to_string(^)^)^).body(if success { "ADMITTED" } else { "REJECTED" }^)
echo }
echo.
echo #[actix_web::main]
echo async fn main(^) -^> std::io::Result^<^(^)^> {
echo     let yml = std::fs::read_to_string("_config.yml"^).expect("YAML missing"^);
echo     let config: OmniConfig = serde_yaml::from_str(^&yml^).expect("YAML error"^);
echo     let state = Arc::new(OmniSynapse { config: ArcSwap::from_pointee(config.clone(^)^), platform: crate::platform::Platform::new(config.engine.valves, 131072^), audit: Arc::new(crate::audit::AuditLog::new(config.engine.valves^)^) }^);
echo     println!("🏁 KORVEX GLOBAL ENGINE ONLINE [UTC MODE]");
echo     HttpServer::new(move ^|^| { App::new(^).app_data(web::Data::new(state.clone(^)^)^).route("/fire", web::post(^).to(fire_valve^)^) }).workers(config.engine.valves^).bind("0.0.0.0:8080"^)?.run(^).await
echo }
) > src\main.rs

:: 5. Security Module
(
echo use crate::OmniConfig;
echo pub struct LicenseKey { pub valid: bool }
echo pub struct AbuseKey { pub level: u8 }
echo pub struct HyperCore { pub identity_key: u64, pub license_key: LicenseKey, pub abuse_key: AbuseKey }
echo impl HyperCore { pub fn from_config(config: ^&OmniConfig^) -^> Self { Self { identity_key: 0, license_key: LicenseKey { valid: config.engine.forensic_active }, abuse_key: AbuseKey { level: 0 } } } }
) > src\security.rs

:: 6. Audit Module
(
echo use std::sync::atomic::{AtomicU64, Ordering};
echo #[repr(align(64^))]
echo pub struct ValveStats { pub admitted: AtomicU64, pub rejected: AtomicU64 }
echo pub struct AuditLog { pub stats: Vec^<ValveStats^> }
echo impl AuditLog {
echo     pub fn new(valves: usize^) -^> Self {
echo         let mut stats = Vec::with_capacity(valves^);
echo         for _ in 0..valves { stats.push(ValveStats { admitted: AtomicU64::new(0^), rejected: AtomicU64::new(0^) }^); }
echo         Self { stats }
echo     }
echo     pub fn log_admission(^&self, idx: usize^) { if let Some(stat^) = self.stats.get(idx^) { stat.admitted.fetch_add(1, Ordering::Relaxed^); } }
echo }
) > src\audit.rs

:: 7. Tracking Module
(
echo use std::time::{SystemTime, UNIX_EPOCH};
echo use std::sync::atomic::{AtomicU64, Ordering};
echo static SEQUENCE: AtomicU64 = AtomicU64::new(0^);
echo pub fn generate_forensic_id(^) -^> u64 {
echo     let now = SystemTime::now(^).duration_since(UNIX_EPOCH^).unwrap(^).as_nanos(^) as u64;
echo     let seq = SEQUENCE.fetch_add(1, Ordering::Relaxed^);
echo     now.wrapping_add(seq^)
echo }
) > src\tracking.rs

:: 8. Platform Module
(
echo use std::sync::Arc;
echo use crate::audit::AuditLog;
echo use crate::security::HyperCore;
echo pub struct SupremeEngine { pub capacity: usize }
echo impl SupremeEngine {
echo     pub fn new(capacity: usize^) -^> Self { Self { capacity } }
echo     pub fn inject(^&self, _id: u64, core: ^&HyperCore, audit: ^&AuditLog, idx: usize^) -^> bool {
echo         if core.license_key.valid { audit.log_admission(idx^); true } else { false }
echo     }
echo }
echo pub struct Platform { pub engines: Vec^<Arc^<SupremeEngine^>^> }
echo impl Platform {
echo     pub fn new(valves: usize, capacity: usize^) -^> Self {
echo         let mut engines = Vec::with_capacity(valves^);
echo         for _ in 0..valves { engines.push(Arc::new(SupremeEngine::new(capacity^)^)^); }
echo         Self { engines }
echo     }
echo     pub fn route(^&self, id: u64^) -^> (usize, ^&Arc^<SupremeEngine^>^) {
echo         let idx = (id as usize^) ^& (self.engines.len(^) - 1^);
echo         (idx, ^&self.engines[idx^]^)
echo     }
echo }
) > src\platform.rs

echo.
echo ✅ Build files reconstructed with correct arc-swap dependency.
echo 🚀 Executing Build...
cargo build --release
pause