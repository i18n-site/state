use aok::{OK, Void};

mod route;
mod url;
use route::route;

pub async fn run(port: u16) -> Void {
  use std::net::{IpAddr, Ipv4Addr, SocketAddr};

  use tokio::net::TcpListener;
  use tracing::info;

  let router = axum::Router::new();

  info!("http://0.0.0.0:{}", port);

  if let Ok(tcp) =
    xerr::ok!(TcpListener::bind(SocketAddr::new(IpAddr::V4(Ipv4Addr::new(0, 0, 0, 0)), port)).await)
  {
    axum::serve(tcp, route(router)).await?;
  }
  OK
}

genv::def!(PORT:u16 | 5123);

#[tokio::main]
async fn main() -> Void {
  loginit::init();
  xboot::init().await?;
  run(PORT()).await
}
