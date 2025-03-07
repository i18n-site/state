use std::{collections::HashMap, time::Duration};

use aok::{OK, Result, Void, ensure};
use reqwest::{Client, Proxy};

genv::s!(
  IPV6_PROXY_USER,
  IPV6_PROXY_PASSWD,
  IPV6_PROXY_PORT:u16,
  IPV6_PROXY_IP_LI
);

const IPV6_PROXY_TEST_URL: &str =
  "https://translate.google.com/translate_a/t?client=gtx&tl=zh&sl=en";

const TIMEOUT: Duration = Duration::from_secs(60);

pub fn proxy(proxy: Proxy) -> reqwest::Client {
  Client::builder()
        .proxy(proxy)
        .zstd(true)
        // .http3_prior_knowledge()
        .timeout(TIMEOUT)
        .danger_accept_invalid_certs(true)
        .connect_timeout(TIMEOUT).build().unwrap()
}

pub struct Host {
  pub name: String,
  pub client: reqwest::Client,
}

pub fn from_env() -> Result<Vec<Host>> {
  let url = format!("http://{}:{}@", *IPV6_PROXY_USER, *IPV6_PROXY_PASSWD,);
  let port: u16 = *IPV6_PROXY_PORT;

  let name_ip: HashMap<String, String> = sonic_rs::from_str(&*IPV6_PROXY_IP_LI)?;

  let li = name_ip
    .into_iter()
    .map(|(name, ip)| {
      Ok(Host {
        name,
        client: proxy(reqwest::Proxy::https(format!("{url}{ip}:{port}"))?),
      })
    })
    .collect::<Result<_, aok::Error>>()?;

  Ok(li)
}

#[static_init::dynamic]
static HOST_LI: Vec<Host> = from_env().unwrap();

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
  dbg!((&host.name, &r));
  ensure!(r == EXCEPT, format!("{} : {} != {}", host.name, r, EXCEPT));

  OK
}

pub async fn run() -> Result<()> {
  for i in &*HOST_LI {
    pg_::heartbeat(300, "ipv6_proxy", i.name.clone(), ping(i));
  }
  OK
}
