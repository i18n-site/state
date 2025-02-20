use aok::{OK, Result, Void};
use tokio::time::{Duration, sleep};
// use tracing::info;

#[static_init::constructor(0)]
extern "C" fn _loginit() {
  loginit::init();
}

async fn test_ping() -> Result<String> {
  Err(aok::anyhow!("test error"))?;
  Ok("".into())
}

#[tokio::test]
async fn test() -> Void {
  pg_::heartbeat(300, "test_kind", "test_name", test_ping());

  sleep(Duration::from_secs(30)).await;

  OK
}
