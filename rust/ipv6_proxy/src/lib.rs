use aok::{OK, Result, Void, ensure};
use v6proxy::{HOST_LI, Host};

const IPV6_PROXY_TEST_URL: &str =
  "https://translate.google.com/translate_a/t?client=gtx&tl=zh&sl=en";

const EXCEPT: &str = "[\"我\"]";

pub async fn ping(host: &Host) -> Void {
  let r = host
    .client
    .post(&*IPV6_PROXY_TEST_URL)
    .form(&[("q", "I")])
    .send()
    .await?
    .text()
    .await?;
  // dbg!((&host.name, &r));
  ensure!(r == EXCEPT, format!("{} : {} != {}", host.name, r, EXCEPT));

  OK
}

pub async fn run() -> Result<()> {
  for i in &*HOST_LI {
    pg_::heartbeat(300, "ipv6_proxy", i.name.clone(), ping(i));
  }
  OK
}
