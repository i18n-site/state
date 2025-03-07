use aok::{OK, Void};

#[static_init::constructor(0)]
extern "C" fn _loginit() {
  loginit::init();
}

#[tokio::test]
async fn test_async() -> Void {
  ipv6_proxy::run().await?;
  // wait for heartbeat run
  tokio::time::sleep(std::time::Duration::from_secs(120)).await;
  OK
}
