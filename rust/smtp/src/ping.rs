use std::{collections::HashMap, net::IpAddr};

use aok::{OK, Result, Void};
use mail_send::SmtpClientBuilder;

use crate::err::Err;

pub async fn conn(
  smtp_host: &str,
  smtp_port: u16,
  smtp_user: &str,
  smtp_password: &str,
  host: &str,
  ip: IpAddr,
) -> Void {
  let smtp = SmtpClientBuilder::new_bind_ip(smtp_host, ip, smtp_port)
    .implicit_tls(false)
    .credentials(mail_send::Credentials::<&str>::Plain {
      username: smtp_user,
      secret: smtp_password,
    });
  let ehlo = smtp.connect().await?.ehlo(smtp_host).await?;
  dbg!(&ehlo);
  let hostname = ehlo.hostname;
  dbg!(hostname);
  // ensure!(
  //   *host == hostname,
  //   format!("smtp {ip}:{port} hostname {hostname} != {host}",)
  // );
  OK
}

pub async fn ping(
  smtp_host: &str,
  smtp_port: u16,
  smtp_user: &str,
  smtp_password: &str,
  host_li: &[&str],
  host_ip: &str,
) -> Void {
  let host_ip: HashMap<String, String> =
    unsafe { sonic_rs::from_slice_unchecked(host_ip.as_bytes()) }?;
  for host in host_li {
    if let Some(ip) = host_ip.get(*host) {
      let ip: IpAddr = ip.parse()?;
      conn(smtp_host, smtp_port, smtp_user, smtp_password, host, ip).await?;
    } else {
      Err(Err::Smtp(host.to_string(), "no ip".into()))?;
    }
  }
  OK
}
