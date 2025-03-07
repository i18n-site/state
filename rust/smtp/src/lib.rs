use std::{net::IpAddr, sync::Arc};

use aok::{OK, Result, Void};
use smtptls::smtptls;
use tracing::info;

genv::s!(
  PING_SMTP_HOST_LI,
  PING_SMTP_USER,
  PING_SMTP_PASSWORD,
  PING_SMTP_PORT
);

pub struct HostIpLi {
  host: String,
  ip_li: Vec<IpAddr>,
}

#[derive(Default)]
pub struct Conf {
  port: u16,
  user: String,
  password: String,
  domain: String,
}

#[derive(Default)]
pub struct SmtpTls {
  host_li: Vec<HostIpLi>,
  conf: Arc<Conf>,
}

async fn ping(host: impl AsRef<str>, ip: IpAddr, conf: impl AsRef<Conf>) -> Result<&'static str> {
  let host = host.as_ref();
  let conf = conf.as_ref();
  let port = conf.port;
  let user = &conf.user;
  let password = &conf.password;
  let domain = &conf.domain;
  let remain_days = smtptls(domain, (ip, port), user, password, 30).await? / 86400;
  info!("smtp {host} {ip} tls remain days {remain_days}");
  Ok("")
}

impl SmtpTls {
  pub async fn run(&self) -> Void {
    for i in self.host_li.iter() {
      let host = &i.host;
      for ip in i.ip_li.iter() {
        let conf = self.conf.clone();
        let host = host.to_owned();

        let name = format!(
          "{host}/{}",
          match ip {
            IpAddr::V4(_) => "ipv4",
            _ => "ipv6",
          }
        );

        pg_::heartbeat(300, "smtp", name, ping(host, *ip, conf));
      }
    }

    OK
  }
}

pub fn from_env() -> SmtpTls {
  let mut host_li = vec![];

  for host in PING_SMTP_HOST_LI.split(" ") {
    let mut ip_li = Vec::with_capacity(2);
    if let Some(ip) = host_ip::IPV4.get(host) {
      ip_li.push(IpAddr::V4(*ip));
    }
    if let Some(ip) = host_ip::IPV6.get(host) {
      ip_li.push(IpAddr::V6(*ip));
    }
    if ip_li.is_empty() {
      tracing::warn!("{} HAS NO IP", host);
    } else {
      host_li.push(HostIpLi {
        host: host.into(),
        ip_li,
      });
    }
  }

  let user: String = (&*PING_SMTP_USER).into();

  SmtpTls {
    host_li,
    conf: Conf {
      domain: user.split('@').next_back().unwrap().into(),
      user,
      password: (&*PING_SMTP_PASSWORD).into(),
      port: PING_SMTP_PORT.parse().unwrap(),
    }
    .into(),
  }
}
