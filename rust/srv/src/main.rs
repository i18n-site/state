use aok::{OK, Void};
mod route;
use std::fmt::Display;
mod url;
use boxleak::boxleak;
use route::route;

pub async fn run(port: u16) -> Void {
  use std::net::{IpAddr, Ipv4Addr, SocketAddr};

  use tokio::net::TcpListener;
  use tracing::info;

  let router = axum::Router::new();
  let router = token_send::route(router);

  info!("http://0.0.0.0:{}", port);

  if let Ok(tcp) =
    xerr::ok!(TcpListener::bind(SocketAddr::new(IpAddr::V4(Ipv4Addr::new(0, 0, 0, 0)), port)).await)
  {
    axum::serve(tcp, axum_layer::layer(route(router))).await?;
  }
  OK
}

genv::def!(PORT:u16 | 5123);

use tokio::task::JoinHandle;

pub fn spawn<F, R, E, T>(run: T) -> JoinHandle<F::Output>
where
  T: Fn() -> F + Send + 'static,
  F: Future<Output = Result<R, E>> + Send,
  E: Display + Send + 'static,
  R: Send + 'static,
{
  tokio::spawn(async move {
    loop {
      match run().await {
        Ok(_) => {}
        Err(err) => {
          tracing::error!("{}", err);
        }
      }
      tokio::time::sleep(std::time::Duration::from_secs(60)).await;
    }
  })
}

#[tokio::main]
async fn main() -> Void {
  loginit::init();
  xboot::init().await?;
  spawn(|| ipv6_proxy::run());
  let smtp = boxleak(smtp::from_env());
  spawn(|| smtp.run());

  run(PORT()).await?;

  unreachable!()
}
