use aok::{OK, Void};

pub async fn cron() -> Void {
  loop {
    println!("cron");
    tokio::time::sleep(std::time::Duration::from_secs(60)).await;
  }
  OK
}
