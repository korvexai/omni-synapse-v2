// src/security/mod.rs
use actix_web::{App, HttpServer};

pub async fn start_security_service() -> std::io::Result<()> {
    HttpServer::new(|| {
        App::new()
    })
    .workers(32)
    .run()
    .await
}